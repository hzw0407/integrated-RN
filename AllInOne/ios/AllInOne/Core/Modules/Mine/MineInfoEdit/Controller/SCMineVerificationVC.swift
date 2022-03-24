//
//  SCMineVerificationVC.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/15.
//

import UIKit

enum SCMineVerificationType: Int {
    case phoneVerification
    case emailVerification
}

class SCMineVerificationVC: SCBasicViewController {
    private let netModel: SCMineResetModel =  SCMineResetModel()
    /// 背景颜色
    private lazy var bgView: UIView = {
        let bgView = UIView()
        bgView.theme_backgroundColor = "Mine.SCMineBaseCell.colorBgView.backgroundColor"
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 18
        return bgView
    }()
    /// 手机号码输入
//    private lazy var textField: UITextField = {
//        let textField = UITextField()
//        textField.theme_textColor = "Mine.SCMineTextFieldCell.textField.textColor"
//        textField.theme_font = "Mine.SCMineTextFieldCell.textField.font"
//        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.4)]
//        let placeholder = self.type == .phoneVerification ? "请输入手机号码" : "请输入邮箱地址"
//        let attributedPlaceholder = NSAttributedString.init(string: placeholder, attributes: attributes)
//        textField.attributedPlaceholder = attributedPlaceholder;
//        textField.borderStyle = .none
//        textField.isSecureTextEntry = false
//        textField.clearsOnBeginEditing = false
//        textField.clearButtonMode = .whileEditing
//        let keyboardType = self.type == .phoneVerification ? UIKeyboardType.phonePad : UIKeyboardType.default
//        textField.keyboardType = keyboardType
//        textField.addTarget(self, action: #selector(textFieldAction), for: UIControl.Event.editingChanged)
//        return textField
//    }()
    
    private lazy var textField: SCTextField = {
        let placeholder = self.type == .phoneVerification ? tempLocalize("请输入手机号码") : tempLocalize("请输入邮箱地址")
        let textField = SCTextField(placeholder: placeholder) { [weak self] text in
            guard let `self` = self else { return }
            self.textFieldAction()
        }
        let keyboardType = self.type == .phoneVerification ? UIKeyboardType.phonePad : UIKeyboardType.default
        textField.keyboardType = keyboardType
        textField.backgorundView.isHidden = true
        return textField
    }()
    
    /// 横线
    public lazy var bottomLineView: UIView = {
        let bottomLineView = UIView()
        bottomLineView.theme_backgroundColor = "Mine.SCMineBaseCell.bottomLineView.backgroundColor"
        return bottomLineView
    }()
    /// 验证码输入
//    private lazy var codeTextField: UITextField = {
//        let codeTextField = UITextField()
//        codeTextField.theme_textColor = "Mine.SCMineTextFieldCell.textField.textColor"
//        codeTextField.theme_font = "Mine.SCMineTextFieldCell.textField.font"
//        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.4)]
//        let attributedPlaceholder = NSAttributedString.init(string: "输入验证码", attributes: attributes)
//        codeTextField.attributedPlaceholder = attributedPlaceholder;
//        codeTextField.borderStyle = .none
//        codeTextField.isSecureTextEntry = false
//        codeTextField.clearsOnBeginEditing = false
//        codeTextField.clearButtonMode = .whileEditing
//        codeTextField.keyboardType = .numberPad
//        codeTextField.addTarget(self, action: #selector(textFieldAction(textField:)), for: UIControl.Event.editingChanged)
//        return codeTextField
//    }()
    
    private lazy var codeTextField: SCTextField = {
        let textField = SCTextField(placeholder: tempLocalize("输入验证码")) { [weak self] text in
            guard let `self` = self else { return }
            self.textFieldAction()
        }
        let keyboardType = self.type == .phoneVerification ? UIKeyboardType.phonePad : UIKeyboardType.default
        textField.keyboardType = .numberPad
        textField.backgorundView.isHidden = true
        return textField
    }()
    
    /// 发送按钮
    private lazy var sendCodeButton: UIButton = {
        let btn = UIButton("发送验证码", titleColor: "Mine.SCMineVerificationVC.sendCodeButton.textColor", font: "Mine.SCMineVerificationVC.sendCodeButton.font", target: self, action: #selector(sendCodeButtonAction))
        btn.theme_setTitleColor("Mine.SCMineVerificationVC.sendCodeButton.disabledTextColor", forState: .disabled)
        btn.titleLabel?.textAlignment = .right
        btn.isEnabled = false
        return btn
    }()
    /// 确认按钮
    private lazy var confirmButton: UIButton = {
        let btn = UIButton("确认", titleColor: "Mine.SCMineVerificationVC.confirmButton.textDisabledColor", font: "Mine.SCMineVerificationVC.confirmButton.font", target: self, action: #selector(confirmButtonAction))
        btn.theme_setTitleColor("Mine.SCMineVerificationVC.confirmButton.textDisabledColor", forState: .disabled)
        btn.theme_setTitleColor("Mine.SCMineVerificationVC.confirmButton.textEnableColor", forState: .normal)
        btn.backgroundColor = UIColor.init(red: 96.0/255.0, green: 174.0/255.0, blue: 198.0/255.0, alpha: 0.3)
        btn.layer.cornerRadius = 18
        btn.layer.masksToBounds = true
        return btn
    }()
    /// 重置手机号按钮
    private lazy var resetPhoneButton: UIButton = {
        let btnTitle = self.type == .phoneVerification ? "重置手机号" : "重置邮箱"
        let btn = UIButton(btnTitle, titleColor: "Mine.SCMineVerificationVC.resetPhoneButton.textColor", font: "Mine.SCMineVerificationVC.resetPhoneButton.font", target: self, action: #selector(resetPhoneButtonAction))
        btn.theme_setImage("Mine.SCMineVerificationVC.resetPhoneButton.image", forState: .normal)
        let imageEdgeInsets_left = self.type == .phoneVerification ? 153.0 : 135.0
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0);
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: imageEdgeInsets_left, bottom: 0, right: 0)
        return btn
    }()
    /// 定时器
    private lazy var timer: Timer = {
        let timer = Timer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        return timer
    }()
    var timerSec = 60
    public var type: SCMineVerificationType = .phoneVerification
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func startTime() {
        self.timer.fireDate = NSDate.distantPast
    }
    func stopTime() {
        self.timer.fireDate = NSDate.distantFuture
    }
}

extension SCMineVerificationVC {
    override func setupView() {
        let title = self.type == .phoneVerification ? "手机号验证" : "邮箱验证"
        self.title = title
        self.view.addSubview(self.bgView)
        self.bgView.addSubview(self.bottomLineView)
        self.bgView.addSubview(self.textField)
        self.bgView.addSubview(self.codeTextField)
        self.bgView.addSubview(self.sendCodeButton)
        self.view.addSubview(self.confirmButton)
        self.view.addSubview(self.resetPhoneButton)
    }
    
    override func setupLayout() {
        self.bgView.snp.makeConstraints { make in
            make.top.equalTo(self.topOffset)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(112.5)
        }
        self.bottomLineView.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.centerY.equalToSuperview()
            make.height.equalTo(0.5)
        }
        self.textField.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(-20)
            make.height.equalTo(56)
            make.top.equalTo(0)
        }
        self.sendCodeButton.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.height.equalTo(56)
            make.bottom.equalTo(0)
            make.width.equalTo(106)
        }
        self.codeTextField.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(self.sendCodeButton.snp.left).offset(-5)
            make.height.equalTo(56)
            make.bottom.equalTo(0)
        }
        self.confirmButton.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(56)
            make.bottom.equalTo(-(kSCBottomSafeHeight + 68))
        }
        self.resetPhoneButton.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(56)
            make.top.equalTo(self.confirmButton.snp.bottom).offset(12)
        }
    }

    override func setupData() {
        
    }
}

extension SCMineVerificationVC {
    
    @objc private func sendCodeButtonAction() {
        netModel.number = self.textField.text ?? ""
        netModel.getAuthCode(type: .resetPassword, success: {
            SCProgressHUD.showHUD("验证码已发送")
            self.timerSec = 10
            self.startTime()
        })
         
        
        
      
    }
    
    @objc private func confirmButtonAction() {
        SCProgressHUD.showHUD("验证码错误或已过期")
        if self.type == .phoneVerification || self.type == .emailVerification {
            /// 修改密码
            let vc = SCMineResetPasswordController()
            vc.username = self.textField.text ?? ""
            vc.authcode = self.codeTextField.text ?? ""
            vc.type = SCMineChangePasswordType.resetPwd
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            /// 绑定手机
            let vc = SCMineBindController()
            vc.type = SCMineBindType.phoneBinding
            self.navigationController?.pushViewController(vc, animated: true)
            
        }

            
          
        }
    
    @objc private func resetPhoneButtonAction() {
        if self.type == .emailVerification {
            /// 绑定邮箱
            let vc = SCMineBindController()
            vc.type = SCMineBindType.emailBinding
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func textFieldAction() {
//        if textField == self.textField {
//
//        } else if textField == self.codeTextField {
//
//        }
        self.sendCodeButton.isEnabled = self.textField.text?.count ?? 0 > 0
        if self.textField.text?.count ?? 0 > 0, self.codeTextField.text?.count ?? 0 > 0 {
            self.confirmButton.isEnabled = true
            self.confirmButton.backgroundColor = UIColor.init(red: 96.0/255.0, green: 174.0/255.0, blue: 198.0/255.0, alpha: 1.0)
        } else {
            self.confirmButton.isEnabled = false
            self.confirmButton.backgroundColor = UIColor.init(red: 96.0/255.0, green: 174.0/255.0, blue: 198.0/255.0, alpha: 0.3)
        }
    }
    @objc private func timerAction() {
        if self.timerSec == 0 {
            self.stopTime()
            self.sendCodeButton.isEnabled = true
            self.sendCodeButton.setTitle("发送验证码", for: .normal)
        } else {
            let btnTitle = "重新发送" + "(\(self.timerSec)s)"
            self.sendCodeButton.setTitle(btnTitle, for: .disabled)
            self.sendCodeButton.isEnabled = false
            self.timerSec -= 1
        }
    }
}
