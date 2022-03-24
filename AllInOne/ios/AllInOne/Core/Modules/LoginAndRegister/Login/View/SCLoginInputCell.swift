//
//  SCLoginInputCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/24.
//

import UIKit

protocol SCLoginInputCellDelegate: AnyObject {
    func cell(_ cell: SCLoginInputCell, didTapedSelectButton model: SCLoginInputModel)
    func cell(_ cell: SCLoginInputCell, didTapedSecretButton model: SCLoginInputModel)
    func cell(_ cell: SCLoginInputCell, didTapedGetCodeButton model: SCLoginInputModel)
    func cell(_ cell: SCLoginInputCell, didChangedContent model: SCLoginInputModel)
}

extension SCLoginInputCellDelegate {
    func cell(_ cell: SCLoginInputCell, didTapedSelectButton model: SCLoginInputModel) {}
    func cell(_ cell: SCLoginInputCell, didTapedSecretButton model: SCLoginInputModel) {}
    func cell(_ cell: SCLoginInputCell, didTapedGetCodeButton model: SCLoginInputModel) {}
    func cell(_ cell: SCLoginInputCell, didChangedContent model: SCLoginInputModel) {}
}

class SCLoginInputCell: SCBasicTableViewCell {

    private weak var delegate: SCLoginInputCellDelegate?
    
    /// 标题
    private lazy var titleLabel: UILabel = UILabel(textColor: "Login.InputCell.titleLabel.textColor", font: "Login.InputCell.titleLabel.font")
    
    
    /// 输入框
//    private lazy var textField: UITextField = {
//        let textField = UITextField()
//        textField.theme_textColor = "Login.InputCell.textField.textColor"
//        textField.theme_font = "Login.InputCell.textField.font"
//
//
//        textField.delegate = self
//        textField.clearButtonMode = .whileEditing
//
//       // textField.backgroundColor = UIColor.white
//        return textField
//    }()
    
    private lazy var textField: SCTextField = {
        let textField = SCTextField { [weak self] text in
            guard let model = self?.model as? SCLoginInputModel else { return }
            model.content = text
        }
        textField.backgorundView.isHidden = true
        return textField
    }()
    
    /// 输入框背景
    private lazy var tView: UIView = {
        let tView = UIView()
        tView.theme_backgroundColor = "Login.InputCell.tView.backgroundColor"
       // tView.backgroundColor = UIColor.yellow
        tView.layer.masksToBounds = true
        tView.layer.cornerRadius = 15

        return tView
    }()
    
    private lazy var selectButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(selectButtonAction), for: .touchUpInside)
        return btn
    }()
    
//    /// 线
//    private lazy var lineView: UIView = {
//        let view = UIView()
//        view.theme_backgroundColor = "Login.InputCell.lineView.backgroundColor"
//        return view
//    }()
//
//    /// 线
//    private lazy var topLineView: UIView = {
//        let view = UIView()
//        view.theme_backgroundColor = "Login.InputCell.lineView.backgroundColor"
//        return view
//    }()
    
    /// 密码是否显示
    private lazy var secretButton: UIButton = {
        let btn = UIButton(image: "Login.InputCell.secretButton.normalImage", target: self, action: #selector(secretButtonAction))
        btn.theme_setImage("Login.InputCell.secretButton.selectImage", forState: .selected)
        btn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return btn
    }()
    
    /// 获取验证码
    private lazy var getCodeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(getCodeButtonAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var getCodeLabel: UILabel = UILabel(textColor: nil, font: "Login.InputCell.getCodeLabel.font")
    
    /// 右边箭头
    private lazy var arrowImageView: UIImageView = UIImageView(image: "Login.InputCell.arrowImage")
   // private lazy var getCodeLabel: UILabel = UILabel(textColor: nil, font: "Login.InputCell.getCodeLabel.font")
    
    func reloadCountDown() {
        guard let model = self.model as? SCLoginInputModel else { return }
        if model.countDown == 0 {
            self.getCodeLabel.text = tempLocalize("login_get_ver_code")
            self.getCodeLabel.theme_textColor = "Global.mainTitleColor"
            
            self.getCodeButton.isEnabled = true
        }
        else {
            self.getCodeButton.isEnabled = false
            self.getCodeLabel.text = String(model.countDown)
            self.getCodeLabel.theme_textColor = "Login.InputCell.getCodeLabel.disabledTextColor"
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? NSObject == self.textField {
            if keyPath == "text" {
                guard let model = self.model as? SCLoginInputModel else { return }
                model.content = self.textField.text ?? ""
                self.delegate?.cell(self, didChangedContent: model)
            }
        }
    }
    
    override func set(model: Any?) {
        self.model = model
        guard let model = self.model as? SCLoginInputModel else { return }
        self.textField.text = model.content
        self.titleLabel.text = model.title
        
     
       // self.textField.placeholder = model.placeholder
        
       // self.textField.setValue(UIColor.lightGray, forKey: "_placeholderLabel.textColor")
//theme_placeholderAttributes
//        self.textField.attributedPlaceholder = NSAttributedString.init(string:model.placeholder ?? "", attributes: [
//            NSAttributedString.Key.foregroundColor:UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.6)])
        self.textField.placeholder = model.placeholder
 
        self.tView.isHidden = !model.isbgViewShow
        self.textField.keyboardType = model.keyboardType
        self.textField.isSecureTextEntry = model.isSecureTextEntry
        self.textField.isEnabled = !model.hasSelect
        self.textField.textAlignment = model.contentAlignment
//        self.textField.theme_placeholderAttributes
        
        self.titleLabel.isHidden = !model.hasTitle
        self.secretButton.isHidden = !model.hasSecret

        self.arrowImageView.isHidden = !model.hasArrow
        self.selectButton.isHidden = !model.hasSelect
      //  self.topLineView.isHidden = !model.hasTopLine
        self.getCodeButton.isHidden = !model.hasAuthCode
        self.getCodeLabel.isHidden = !model.hasAuthCode
        
        var contentRightMargin: CGFloat = 20
        if model.hasSelect {
            contentRightMargin = 20 + 40 + 5
        }
        else if model.hasArrow {
            contentRightMargin = 20 + 20 + 5
        }
        else if model.hasAuthCode {
            self.reloadCountDown()
            let font = ThemeFontPicker.init(stringLiteral: "Login.InputCell.getCodeLabel.font").value() as! UIFont
            var width = self.getCodeLabel.text?.textWidth(height: 20, font: font) ?? 40
            if width > 120 {
                width = 120
            }
            contentRightMargin = 20 + width + 5
        }
        else if model.type == .password || model.type == .confirmPassword {
            contentRightMargin = 20 + 30 + 5
        }
        
        self.textField.snp.updateConstraints { make in
            make.right.equalToSuperview().offset(-contentRightMargin)
        }
    }
    
    override func set(delegate: Any?) {
        self.delegate = delegate as? SCLoginInputCellDelegate
    }
}

extension SCLoginInputCell {
    override func setupView() {
        self.backgroundColor = .clear
        self.contentView.addSubview(self.tView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.textField)
        self.contentView.addSubview(self.secretButton)
        self.contentView.addSubview(self.getCodeLabel)
        self.contentView.addSubview(self.getCodeButton)
        self.contentView.addSubview(self.arrowImageView)
        self.contentView.addSubview(self.selectButton)
        
  
        
        
        //self.contentView.addSubview(self.lineView)
       // self.contentView.addSubview(self.topLineView)
        
        self.textField.addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func setupLayout() {
        let margin: CGFloat = 20
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin+10)
            make.top.bottom.equalToSuperview()
            make.width.greaterThanOrEqualTo(0)
        }
        self.textField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.bottom.top.equalToSuperview()
            make.right.equalToSuperview().offset(-0)
        }
        self.secretButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-margin-10)
            make.width.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        self.getCodeButton.snp.makeConstraints { (make) in
            make.edges.equalTo(self.getCodeLabel)
        }
        self.getCodeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-margin-10)
            make.height.equalTo(40)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(60)
            make.width.lessThanOrEqualTo(120)
        }
        self.arrowImageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-margin-10)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
//        self.lineView.snp.makeConstraints { (make) in
//            make.left.right.equalToSuperview().inset(margin)
//            make.height.equalTo(0.5)
//            make.bottom.equalToSuperview().offset(-0.5)
//        }
//        self.topLineView.snp.makeConstraints { (make) in
//            make.left.right.equalToSuperview().inset(margin)
//            make.height.equalTo(0.5)
//            make.top.equalToSuperview()
//        }
        self.selectButton.snp.makeConstraints { (make) in
            make.top.bottom.left.equalTo(self.textField)
            make.right.equalToSuperview()
        }
        
        self.tView.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(-5)
          
        }
    }
}

extension SCLoginInputCell {
    @objc private func selectButtonAction() {
        guard let model = self.model as? SCLoginInputModel else { return }
        self.delegate?.cell(self, didTapedSelectButton: model)
    }
    
    @objc private func secretButtonAction() {
        guard let model = self.model as? SCLoginInputModel else { return }
        self.secretButton.isSelected = !self.secretButton.isSelected
        model.isPasswordShow = self.secretButton.isSelected
        self.textField.isSecureTextEntry = !self.secretButton.isSelected
        self.delegate?.cell(self, didTapedSecretButton: model)
    }
    
    @objc private func getCodeButtonAction() {
        guard let model = self.model as? SCLoginInputModel else { return }
    
        
        self.delegate?.cell(self, didTapedGetCodeButton: model)
    }
}

extension SCLoginInputCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let model = self.model as? SCLoginInputModel else { return }
        model.content = self.textField.text ?? ""
    }
}
