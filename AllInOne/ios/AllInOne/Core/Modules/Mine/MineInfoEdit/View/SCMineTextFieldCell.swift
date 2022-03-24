//
//  SCMineTextFieldCell.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/15.
//

import UIKit

protocol SCMineTextFieldCellDelegate: AnyObject {
    func cell(_ cell: SCMineTextFieldCell, textFieldEditDidChange model: SCMineTextFieldModel, textField: UITextField)
}

class SCMineTextFieldCell: SCMineBaseCell {
    
    private weak var delegate: SCMineTextFieldCellDelegate?
    
//    private lazy var textField: UITextField = {
//        let textField = UITextField()
//        textField.theme_textColor = "Mine.SCMineTextFieldCell.textField.textColor"
//        textField.theme_font = "Mine.SCMineTextFieldCell.textField.font"
//        textField.borderStyle = .none
//        textField.isSecureTextEntry = true
//        textField.clearsOnBeginEditing = false
//        textField.clearButtonMode = .whileEditing
//        textField.addTarget(self, action: #selector(textFieldAction(textField:)), for: UIControl.Event.editingChanged)
//        return textField
//    }()
    
    private lazy var textField: SCTextField = {
        let textField = SCTextField() { [weak self] text in
            guard let `self` = self else { return }
            self.textFieldAction(textField: self.textField.textField)
        }
        
        textField.keyboardType = .emailAddress
        textField.isSecureTextEntry = true
        textField.backgorundView.isHidden = true
        return textField
    }()
    
    /// 密码是否显示
    private lazy var secretButton: UIButton = {
        let btn = UIButton(image: "Login.InputCell.secretButton.normalImage", target: self, action: #selector(secretButtonAction))
        btn.theme_setImage("Login.InputCell.secretButton.selectImage", forState: .selected)
        return btn
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func set(model: Any?) {
        self.model = model
        guard let model = self.model as? SCMineTextFieldModel else { return }
        self.textField.placeholder = model.placeTitle
//        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.4)]
//        let attributedPlaceholder = NSAttributedString.init(string: model.placeTitle, attributes: attributes)
//        self.textField.attributedPlaceholder = attributedPlaceholder;
        self.cornerRadius(cornerRadius: 18, top: model.cornerRadiusTop, bottom: model.cornerRadiusBottom, cornerFrame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 40, height: 56))
    }
    
    override func set(delegate: Any?) {
        self.delegate = delegate as? SCMineTextFieldCellDelegate
    }
    
    @objc private func textFieldAction(textField: UITextField) {
        guard let model = self.model as? SCMineTextFieldModel else { return }
        self.delegate?.cell(self, textFieldEditDidChange: model, textField: textField)
    }
}

extension SCMineTextFieldCell {
    override func setupView() {
        super.setupView()
        self.colorBgView.addSubview(self.textField)
        self.colorBgView.addSubview(self.secretButton)
    }
    
    override func setupLayout() {
        super.setupLayout()
        self.secretButton.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        self.textField.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.bottom.equalTo(0)
            make.right.equalTo(-60)
        }
    }
}

extension SCMineTextFieldCell {
    @objc private func secretButtonAction() {
        self.secretButton.isSelected = !self.secretButton.isSelected
        self.textField.isSecureTextEntry = !self.secretButton.isSelected
    }
}
