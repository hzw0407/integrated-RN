//
//  SCAlertView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/14.
//

import UIKit

typealias SCAlertViewCancelBlock = () -> Void
typealias SCAlertViewConfirmBlock = () -> Void
typealias SCAlertViewTextConfirmBlock = (_ text: String) -> Void

class SCAlertView: NSObject {
    private var title: String?
    private var message: String?
    private var supplement: String?
    private var cancelTitle: String?
    private var confirmTitle: String?
    private var textRange: NSRange = NSRange(location: 1, length: 12)
    private var placeholder: String?
    private var content: String?
    private var cancelBlock: SCAlertViewCancelBlock?
    private var confirmBlock: SCAlertViewConfirmBlock?
    private var textConfirmBlock: SCAlertViewTextConfirmBlock?
    private var confirmTitleColor: UIColor?
    private var customView: UIView?
    
    private var isTextField: Bool = false
    private var isNeedManualHide: Bool = false {
        willSet {
            if self.isNeedManualHide && !newValue {
                self.clearBlocks()
            }
        }
    }
    
    fileprivate static let sharedInstance = SCAlertView()
    
    private lazy var alertView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
//        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        view.theme_backgroundColor = "Global.AlertView.backgroundColor"
        return view
    }()
    
    private lazy var container: UIView = {
        let view = UIView()
        view.theme_backgroundColor = "Global.AlertView.containerColor"
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: kSCScreenWidth, height: kSCScreenHeight), byRoundingCorners: UIRectCorner(rawValue: UIRectCorner.topLeft.rawValue | UIRectCorner.topRight.rawValue), cornerRadii: CGSize(width: 24, height: 24))
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        view.layer.mask = shape
        return view
    }()
    
    private lazy var titleLabel: UILabel = UILabel(textColor: "Global.AlertView.titleLabel.textColor", font: "Global.AlertView.titleLabel.font", numberLines: 0, alignment: .center)
    
    private lazy var messageLabel: UILabel = UILabel(textColor: "Global.AlertView.messageLabel.textColor", font: "Global.AlertView.messageLabel.font", numberLines: 0, alignment: .center)
    
    /// 补充说明
    private lazy var supplementLabel: UILabel = UILabel(textColor: "Global.AlertView.supplementLabel.textColor", font: "Global.AlertView.supplementLabel.font", numberLines: 0, alignment: .center)
    
    private lazy var cancelButton: UIButton = UIButton(tempLocalize("取消"), titleColor: "Global.AlertView.cancelButton.textColor", font: "Global.AlertView.cancelButton.font", target: self, action: #selector(cancelButtonAction), backgroundColor: "Global.AlertView.cancelButton.backgroundColor", cornerRadius: 12)
    
    private lazy var confirmButton: UIButton = UIButton(tempLocalize("取消"), titleColor: "Global.AlertView.confirmButton.textColor", font: "Global.AlertView.confirmButton.font", target: self, action: #selector(confirmButtonAction), backgroundColor: "Global.AlertView.confirmButton.backgroundColor", cornerRadius: 12)
    
    private lazy var textField: SCTextField = {
        let textField = SCTextField(textDidChangeHandle:  { [weak self] _ in
            self?.textFieldTextChange()
        })
        return textField
    }()
    
    override init() {
        super.init()
        self.alertView.addSubview(self.container)
        self.container.addSubview(self.titleLabel)
        self.container.addSubview(self.messageLabel)
        self.container.addSubview(self.supplementLabel)
        self.container.addSubview(self.cancelButton)
        self.container.addSubview(self.confirmButton)
        self.container.addSubview(self.textField)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFiledEditChanged(notification:)), name: UITextField.textDidChangeNotification, object: self.textField)
        
        self.hide()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrameNotification(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func show() {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        keyWindow.addSubview(self.alertView)
        self.alertView.isHidden = false
        
        let horizontalMargin: CGFloat = 24
        
        var topView: UIView = self.confirmButton
        if self.cancelTitle != nil && self.confirmTitle != nil {
            self.cancelButton.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(horizontalMargin)
                make.height.equalTo(56)
                make.bottom.equalToSuperview().offset(-36)
            }
            self.confirmButton.snp.remakeConstraints { make in
                make.right.equalToSuperview().offset(-horizontalMargin)
                make.left.equalTo(self.cancelButton.snp.right).offset(12)
                make.width.equalTo(self.cancelButton)
                make.height.equalTo(56)
                make.bottom.equalToSuperview().offset(-36)
            }
            
            self.cancelButton.isHidden = false
            self.confirmButton.isHidden = false
            self.cancelButton.setTitle(self.cancelTitle, for: .normal)
            self.confirmButton.setTitle(self.confirmTitle, for: .normal)
        }
        else if self.confirmTitle != nil {
            self.confirmButton.snp.remakeConstraints { make in
                make.right.equalToSuperview().offset(-horizontalMargin)
                make.left.equalToSuperview().offset(horizontalMargin)
                make.height.equalTo(56)
                make.bottom.equalToSuperview().offset(-36)
            }
            
            self.confirmButton.isHidden = false
            self.confirmButton.setTitle(self.confirmTitle, for: .normal)
        }
        else if self.cancelTitle != nil {
            self.cancelButton.snp.remakeConstraints { make in
                make.right.equalToSuperview().offset(-horizontalMargin)
                make.left.equalToSuperview().offset(horizontalMargin)
                make.height.equalTo(56)
                make.bottom.equalToSuperview().offset(-36)
            }
            
            self.cancelButton.isHidden = false
            self.cancelButton.setTitle(self.cancelTitle, for: .normal)
            
            topView = self.cancelButton
        }
        
        if self.isTextField {
            self.textField.text = content
            self.textField.placeholder = self.placeholder
            self.textField.isHidden = false
            self.textField.snp.remakeConstraints { make in
                make.bottom.equalTo(topView.snp.top).offset(-40)
                make.left.right.equalToSuperview().inset(horizontalMargin)
                make.height.equalTo(56)
            }
            topView = self.textField
        }
        else {
            self.textField.isHidden = true
        }
        
        if self.message != nil {
            self.messageLabel.isHidden = false
            self.messageLabel.text = self.message
            self.messageLabel.snp.remakeConstraints { make in
                make.left.right.equalToSuperview().inset(horizontalMargin)
                make.bottom.equalTo(topView.snp.top).offset(-40)
            }
            topView = self.messageLabel
        }
        else {
            self.messageLabel.isHidden = true
        }
        
        if self.customView != nil {
            let height: CGFloat = self.customView?.bounds.height ?? 0
            self.alertView.addSubview(self.customView!)
            self.customView?.snp.remakeConstraints { make in
                make.left.right.equalToSuperview().inset(horizontalMargin)
                make.bottom.equalTo(topView.snp.top).offset(-40)
                if height > 0 {
                    make.height.equalTo(height)
                }
            }
            topView = self.customView!
        }
        
        if self.title != nil {
            self.titleLabel.isHidden = false
            self.titleLabel.text = self.title
            self.titleLabel.snp.remakeConstraints { make in
                make.left.right.equalToSuperview().inset(horizontalMargin)
                make.bottom.equalTo(topView.snp.top).offset(-28)
            }
            topView = self.titleLabel
        }
        
        self.container.snp.remakeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(topView.snp.top).offset(-28)
        }
    }
    
    func hide() {
        if self.isTextField {
            self.container.endEditing(true)
        }
        
        self.confirmTitleColor = nil
        self.title = nil
        self.message = nil
        self.supplement = nil
        self.cancelTitle = nil
        self.confirmTitle = nil
//        self.cancelBlock = nil
//        self.confirmBlock = nil
//        self.textConfirmBlock = nil
        self.isTextField = false
        
        self.titleLabel.isHidden = true
        self.messageLabel.isHidden = true
        self.supplementLabel.isHidden = true
        self.textField.isHidden = true
        self.cancelButton.isHidden = true
        self.confirmButton.isHidden = true
        
        self.textField.text = nil
        self.customView?.removeFromSuperview()
        self.customView = nil
        
        self.alertView.isHidden = true
        self.alertView.removeFromSuperview()
    }
    
    private func clearBlocks() {
        if self.cancelTitle == nil {
            self.cancelBlock = nil
        }
        if self.confirmTitle == nil {
            self.confirmBlock = nil
            self.textConfirmBlock = nil
        }
        else {
            if self.isTextField {
                self.confirmBlock = nil
            }
            else {
                self.textConfirmBlock = nil
            }
        }
        
    }
    
    @objc private func textFiledEditChanged(notification: Notification) {
        guard let textField = notification.object as? UITextField else { return }
        let toBeString = textField.text ?? ""
        if toBeString.count > self.textRange.length {
            textField.text = (toBeString as NSString).substring(to: self.textRange.length)
        }
    }
    
    private func textFieldTextChange() {
        let toBeString = self.textField.text ?? ""
        if toBeString.count > self.textRange.length {
            self.textField.text = (toBeString as NSString).substring(to: self.textRange.length)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func alertTip(message: String, confirmTitle: String = tempLocalize("确定")) {
        SCAlertView.sharedInstance.alert(title: tempLocalize("提示"), message: message, confirmTitle: confirmTitle)
    }
    
    /// 普通弹窗,左边按钮为取消，右边按钮为确认
    static func alertDefault(title: String? = tempLocalize("提示"), message: String? = nil, supplement: String? = nil, cancelCallback: SCAlertViewCancelBlock? = nil, confirmCallback: SCAlertViewConfirmBlock? = nil) {
        self.alert(title: title, message: message, supplement: supplement, cancelTitle: tempLocalize("取消"), confirmTitle: tempLocalize("确定"), cancelCallback: cancelCallback, confirmCallback: confirmCallback)
    }
    
    static func alert(title: String? = nil, message: String? = nil, supplement: String? = nil, cancelTitle: String? = nil, confirmTitle: String?, confirmColor: UIColor? = nil, cancelCallback: SCAlertViewCancelBlock? = nil, confirmCallback: SCAlertViewConfirmBlock? = nil, isNeedManualHide: Bool = false) {
        SCAlertView.sharedInstance.alert(title: title, message: message, supplement: supplement, cancelTitle: cancelTitle, confirmTitle: confirmTitle, confirmColor: confirmColor, cancelCallback: cancelCallback, confirmCallback: confirmCallback, isNeedManualHide: isNeedManualHide)
    }
    
    static func alertText(title: String? = nil, range: NSRange = NSRange(location: 1, length: 12), placeholder: String? = nil, content: String? = nil, supplement: String? = nil, cancelCallback: SCAlertViewCancelBlock? = nil, confirmCallback: SCAlertViewTextConfirmBlock? = nil, isNeedManualHide: Bool = false) {
        self.alertText(title: title, range: range, placeholder: placeholder, content: content, supplement: supplement, cancelTitle: tempLocalize("取消"), confirmTitle: tempLocalize("确定"), cancelCallback: cancelCallback, confirmCallback: confirmCallback, isNeedManualHide: isNeedManualHide)
    }
    
    static func alertText(title: String? = nil, range: NSRange = NSRange(location: 1, length: 12), placeholder: String? = nil, content: String? = nil, supplement: String? = nil, cancelTitle: String? = nil, confirmTitle: String?, cancelCallback: (() -> Void)? = nil, confirmCallback: SCAlertViewTextConfirmBlock? = nil, isNeedManualHide: Bool = false) {
        SCAlertView.sharedInstance.alertText(title: title, range: range, placeholder: placeholder, content: content, supplement: supplement, cancelTitle: cancelTitle, confirmTitle: confirmTitle, cancelCallback: cancelCallback, confirmCallback: confirmCallback, isNeedManualHide: isNeedManualHide)
    }
    
    static func alert(title: String? = nil, customView: UIView, supplement: String? = nil, cancelTitle: String = tempLocalize("取消"), confirmTitle: String = tempLocalize("确定"), cancelCallback: SCAlertViewCancelBlock? = nil, confirmCallback: SCAlertViewConfirmBlock? = nil, isNeedManualHide: Bool = false) {
        SCAlertView.sharedInstance.alert(title: title, customView: customView, supplement: supplement, cancelTitle: cancelTitle, confirmTitle: confirmTitle, cancelCallback: cancelCallback, confirmCallback: confirmCallback, isNeedManualHide: isNeedManualHide)
    }
    

    
    static func hide() {
        if SCAlertView.sharedInstance.isNeedManualHide {
            SCAlertView.sharedInstance.isNeedManualHide = false
        }
        SCAlertView.sharedInstance.hide()
    }
    
    fileprivate func alert(title: String? = nil, message: String? = nil, supplement: String? = nil, cancelTitle: String? = nil, confirmTitle: String? = nil, confirmColor: UIColor? = nil, cancelCallback: SCAlertViewCancelBlock? = nil, confirmCallback: (() -> Void)? = nil, isNeedManualHide: Bool = false) {
        self.hide()
        self.title = title
        self.message = message
        self.supplement = supplement
        self.cancelTitle = cancelTitle
        self.confirmTitle = confirmTitle
        self.cancelBlock = cancelCallback
        self.confirmBlock = confirmCallback
        self.isTextField = false
        self.confirmTitleColor = confirmColor
        self.isNeedManualHide = isNeedManualHide
        
        
        self.show()
    }
    
    fileprivate func alertText(title: String? = nil, range: NSRange = NSRange(location: 1, length: 12), placeholder: String? = nil, content: String? = nil, supplement: String? = nil, cancelTitle: String? = nil, confirmTitle: String?, cancelCallback: (() -> Void)? = nil, confirmCallback: SCAlertViewTextConfirmBlock? = nil, isNeedManualHide: Bool = false) {
        self.title = title
        self.placeholder = placeholder
        self.content = content
        self.supplement = supplement
        self.cancelTitle = cancelTitle
        self.confirmTitle = confirmTitle
        self.cancelBlock = cancelCallback
        self.textConfirmBlock = confirmCallback
        self.isTextField = true
        self.textRange = range
        self.isNeedManualHide = isNeedManualHide
        self.show()
    }
    
    fileprivate func alert(title: String? = nil, customView: UIView, supplement: String? = nil, cancelTitle: String? = nil, confirmTitle: String?, cancelCallback: SCAlertViewCancelBlock? = nil, confirmCallback: SCAlertViewConfirmBlock? = nil, isNeedManualHide: Bool = false) {
        self.title = title
        self.customView = customView
        self.cancelTitle = cancelTitle
        self.confirmTitle = confirmTitle
        self.cancelBlock = cancelCallback
        self.supplement = supplement
        self.confirmBlock = confirmCallback
        self.isNeedManualHide = isNeedManualHide
        
        self.show()
    }
    
    @objc private func cancelButtonAction() {
        self.hide()
        self.cancelBlock?()
        self.clearBlocks()
    }
    
    @objc private func confirmButtonAction() {
        if self.isTextField {
            let text = self.textField.text ?? ""
            if text.count == 0 || text.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
                SCProgressHUD.showHUD(tempLocalize("名称不能为空"))
                return
            }
            if text.count < self.textRange.location || text.count > textRange.length {
                return
            }
            self.hide()
            self.textConfirmBlock?(text)
            self.clearBlocks()
        }
        else {
            if !self.isNeedManualHide {
                self.hide()
            }
            self.confirmBlock?()
            if !self.isNeedManualHide {
                self.clearBlocks()
            }
        }
        
    }
    
    @objc private func keyboardWillChangeFrameNotification(_ notification: Notification) {
        guard let kbFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let kbHeight = kbFrame.height
        var rect = self.container.frame
        let bottom = kSCScreenHeight - rect.origin.y - rect.height
        if bottom < kbHeight {
            rect.origin.y = kSCScreenHeight - rect.height - kbHeight
            self.container.frame = rect
        }
    }
}

