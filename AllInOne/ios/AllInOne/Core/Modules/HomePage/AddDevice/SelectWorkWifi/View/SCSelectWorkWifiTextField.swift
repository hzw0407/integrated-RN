//
//  SCSelectWorkWifiTextField.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/15.
//

import UIKit
import CloudKit

class SCSelectWorkWifiTextField: SCBasicView {
    
    var text: String? {
        set {
            self.textField.text = newValue
        }
        get {
            return self.textField.text
        }
    }
    
    var isSecureTextEntry: Bool {
        set {
            self.textField.isSecureTextEntry = newValue
        }
        get {
            return self.textField.isSecureTextEntry
        }
    }
    
    private var rightButtonClickedBlock: ((Bool) -> Void)?
    private var didChangeSelectionBlock: (() -> Void)?
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.theme_textColor = "HomePage.AddDeviceController.SelectWorkWifiController.textField.textColor"
        textField.theme_font = "HomePage.AddDeviceController.SelectWorkWifiController.textField.font"
        textField.delegate = self
        return textField
    }()
    
    private lazy var rightButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(rightButtonAction), for: .touchUpInside)
        return btn
    }()
    
    convenience init(placeholder: String?, isEnabled: Bool, didChangeSelectionHandle: (() -> Void)? = nil) {
        self.init(frame: .zero)
        self.textField.placeholder = placeholder
        self.textField.isEnabled = isEnabled
        self.didChangeSelectionBlock = didChangeSelectionHandle
        
        let placeholderColor = ThemeColorPicker(keyPath: "HomePage.AddDeviceController.SelectWorkWifiController.textField.placeholderColor").value() as! UIColor
        let placeholderAttributes = [NSAttributedString.Key.foregroundColor: placeholderColor]
        self.textField.theme_placeholderAttributes = ThemeStringAttributesPicker.pickerWithAttributes([placeholderAttributes])
    }
    
    func addRightButton(image: ThemeImagePicker, selectImage: ThemeImagePicker, rightButtonClickedHandle: ((Bool) -> Void)?) {
        self.rightButton.theme_setImage(image, forState: .normal)
        self.rightButton.theme_setImage(selectImage, forState: .selected)
        self.rightButton.snp.updateConstraints { make in
            make.left.equalTo(self.snp.right).offset(-20 - 25)
        }
        self.rightButtonClickedBlock = rightButtonClickedHandle
    }
}

extension SCSelectWorkWifiTextField {
    override func setupView() {
        self.theme_backgroundColor = "HomePage.AddDeviceController.SelectWorkWifiController.textField.backgroundColor"
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        
        self.addSubview(self.textField)
        self.addSubview(self.rightButton)
    }
    
    override func setupLayout() {
        self.textField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(self.rightButton.snp.left).offset(-10)
        }
        self.rightButton.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.centerY.equalToSuperview()
            make.left.equalTo(self.snp.right).offset(10)
        }
    }
}

extension SCSelectWorkWifiTextField {
    @objc private func rightButtonAction() {
        self.rightButton.isSelected = !self.rightButton.isSelected
        self.rightButtonClickedBlock?(self.rightButton.isSelected)
    }
}

extension SCSelectWorkWifiTextField: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.didChangeSelectionBlock?()
    }
}
