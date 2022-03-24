//
//  SCTextField.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/25.
//

import UIKit

class SCTextField: SCBasicView {
    
    var text: String? {
        set {
            self.textField.text = newValue
        }
        get {
            return self.textField.text
        }
    }
    
    var placeholder: String? {
        set {
            self.textField.placeholder = newValue
        }
        get {
            return self.textField.placeholder
        }
    }
    
    var hasClearButton: Bool = true
    
    var isEnabled: Bool = true {
        didSet {
            self.textField.isEnabled = self.isEnabled
        }
    }
    
    var isSecureTextEntry: Bool = false {
        didSet {
            self.textField.isSecureTextEntry = self.isSecureTextEntry
        }
    }
    
    var keyboardType: UIKeyboardType = .default {
        didSet {
            self.textField.keyboardType = self.keyboardType
        }
    }
    
    var textAlignment: NSTextAlignment = .left {
        didSet {
            self.textField.textAlignment = self.textAlignment
        }
    }
    
    private (set) lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = tempLocalize("请输入名称")
        let placeholderColor = ThemeColorPicker(keyPath: "Global.TextField.placeholderColor").value() as! UIColor
        let placeholderFont = ThemeFontPicker(stringLiteral: "Global.TextField.placeholderFont").value() as! UIFont
        let placeholderAttributes = [NSAttributedString.Key.foregroundColor: placeholderColor, NSAttributedString.Key.font: placeholderFont]
        textField.theme_placeholderAttributes = ThemeStringAttributesPicker.pickerWithAttributes([placeholderAttributes])
        textField.theme_textColor = "Global.TextField.textColor"
        textField.theme_font = "Global.TextField.font"
//        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        return textField
    }()

    private var textDidChangeBlock: ((String) -> Void)?
    private var beginEditingBlock: (() -> Void)?
    
    private (set) lazy var backgorundView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = "Global.TextField.backgroundColor"
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var clearButton = UIButton(image: "Global.TextField.clearImage", target: self, action: #selector(clearButtonAction), imageEdgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    
    convenience init(placeholder: String? = nil, beginEditingHandle: (() -> Void)? = nil, textDidChangeHandle: ((String) -> Void)? = nil) {
        self.init(frame: .zero)
        self.placeholder = placeholder
        self.beginEditingBlock = beginEditingHandle
        self.textDidChangeBlock = textDidChangeHandle
    }
}

extension SCTextField {
    override func setupView() {
        self.addSubview(self.backgorundView)
        self.addSubview(self.textField)
        self.addSubview(self.clearButton)
        
        self.clearButton.isHidden = true
    }
    
    override func setupLayout() {
        self.backgorundView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
        self.textField.snp.makeConstraints { make in
            make.left.equalTo(self).offset(20)
            make.top.bottom.equalToSuperview().inset(5)
            make.right.equalTo(self.clearButton.snp.left).offset(-5)
        }
        self.clearButton.snp.makeConstraints { make in
            make.right.equalTo(self.backgorundView).offset(0)
            make.height.width.equalTo(36)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc private func clearButtonAction() {
        self.textField.text = nil
    }
}

extension SCTextField: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.hasClearButton {
            self.clearButton.isHidden = true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.hasClearButton {
            self.clearButton.isHidden = false
        }
        self.beginEditingBlock?()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.textDidChangeBlock?(textField.text ?? "")
    }
}
