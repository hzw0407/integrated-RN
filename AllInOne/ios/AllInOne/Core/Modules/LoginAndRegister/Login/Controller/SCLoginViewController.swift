//
//  SCLoginViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/22.
//

import UIKit

let kLastLoginUsernameKey = "kLastLoginUsernameKey"

class SCLoginViewController: SCBasicViewController {

    private let viewModel: SCLoginViewModel =  SCLoginViewModel()
    
    private var items: [SCLoginInputModel] = []
    
    private lazy var logoImageView: UIImageView = UIImageView(image: "Login.logoImage")
    
    private lazy var appName: UILabel = UILabel(text: tempLocalize("ALL IN ONE"), textColor: "Login.appName.titleLabel.textColor", font: "Login.appName.titleLabel.font", backgroundColor: "", numberLines: 0, alignment: .center )
    
    
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCLoginInputCell.self, cellIdendify: SCLoginInputCell.identify, rowHeight: 70, cellDelegate: self)
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.clear
        return tableView
    }()
    

    
    private lazy var agreeButton: UIButton = UIButton(image: "Login.agreeButton.unSelectAgreeBtn", target: self, action: #selector(agreeButtonClick), highlightedImage: "Login.agreeButton.unSelectAgreeBtn", backgroundColor: "", imageEdgeInsets:UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))

    private lazy var agreeLabel: UILabel = UILabel(text: tempLocalize("同意 用户协议 及 隐私条款"), textColor: "Login.agreeLabel.textColor", font: "Login.agreeLabel.font", backgroundColor: "", numberLines: 0, alignment: .center )
    
    private lazy var loginButton: UIButton = UIButton(tempLocalize("登录"), titleColor: "Login.loginButton.textColor", font: "Login.loginButton.font", target: self, action: #selector(loginButtonAction), backgroundColor: "Login.loginButton.backgroundColor", cornerRadius: 10)
    
    private lazy var forgotPasswordButton: UIButton = UIButton(tempLocalize("忘记密码?"), titleColor: "Login.forgotPasswordButton.textColor", font: "Login.forgotPasswordButton.font", target: self, action: #selector(forgotPasswordButtonAction), backgroundColor: "")
    
    
    private lazy var remoteLabel: UILabel = UILabel(text: tempLocalize("*仅支持中国大陆手机号，非中国大陆地区请使用邮箱登录"), textColor: "Login.remoteLabel.textColor", font: "Login.remoteLabel.font", backgroundColor: "", numberLines: 0, alignment: .center )
    
    private lazy var authCodeLoginButton: UIButton = {
        let btn = UIButton(tempLocalize("验证码登录"), titleColor: "Global.mainTitleColor", font: "Login.loginButton.font", target: self, action: #selector(authCodeLoginButtonAction), backgroundColor: "", cornerRadius: 10)
        btn.setTitle(tempLocalize("用户密码登录"), for: .selected)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadCountryData()
        
        if let username = SCUserCenter.sharedInstance.lastLoginUsername, username.count > 0 {
            if let item = self.items.first(where: { item in
                return item.type == .username
            }) {
                item.content = username
                self.tableView.reloadData()
            }
        }
    }
}

extension SCLoginViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("login_title")
        self.setupRightBarButtonItem(title: tempLocalize("login_register_button"), action: #selector(rightBarButtonItemAction))
    }
    
    override func setupView() {
       // self.view.addSubview(self.logoImageView)
        self.view.addSubview(self.appName)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.remoteLabel)
        self.view.addSubview(self.loginButton)
        self.view.addSubview(self.forgotPasswordButton)
        self.agreeButton.theme_setImage("Login.agreeButton.SelectAgreeBtn", forState: .selected)
        
        self.view.addSubview(self.agreeButton)
               //富文本变色
               let strg = "同意 用户协议 及 隐私条款"
               let ranStr = "用户协议"
               let ranStrs = "隐私条款"
               //所有文字变为富文本
               let attrstring:NSMutableAttributedString = NSMutableAttributedString(string:strg)
               //颜色处理的范围
               let str = NSString(string: strg)
               let theRange = str.range(of: ranStr)
               let theRanges = str.range(of: ranStrs)
               //颜色处理
                attrstring.addAttribute(NSAttributedString.Key.foregroundColor, value:RGBColor(r: 96, g: 174, b: 198, a: 1), range: theRange)
                attrstring.addAttribute(NSAttributedString.Key.foregroundColor, value:RGBColor(r: 96, g: 174, b: 198, a: 1), range: theRanges)
               //行间距
               let paragraphStye = NSMutableParagraphStyle()
               paragraphStye.lineSpacing = 5
               //行间距的范围
        let distanceRange = NSMakeRange(0, CFStringGetLength(strg as CFString?))
        attrstring .addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStye, range: distanceRange)
        self.agreeLabel.attributedText = attrstring//赋值方法
        
        self.view.addSubview(self.agreeLabel)
        self.view.addSubview(self.authCodeLoginButton)
    }
    
    override func setupLayout() {
        self.appName.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin).offset(37)
           // make.width.height.equalTo(80)
        }
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.appName.snp.bottom).offset(37)
            make.height.equalTo(70 * 3)
        }
        
        self.remoteLabel.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(self.tableView.snp.bottom).offset(5)
        }
        self.forgotPasswordButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(30)
            make.top.equalTo(self.remoteLabel.snp.bottom).offset(10)
        }
        
        self.agreeButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(30)
            make.width.equalTo(30)
            make.top.equalTo(self.forgotPasswordButton.snp.bottom).offset(10)
        }
      
        self.agreeLabel.snp.makeConstraints { make in
            make.left.equalTo(self.agreeButton.snp_rightMargin).offset(5)
            make.right.equalTo(self.view.snp_rightMargin).offset(-20)
            make.top.equalTo(self.forgotPasswordButton.snp.bottom).offset(16)
        }
        
        self.loginButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(62)
            make.top.equalTo(self.agreeButton.snp.bottom).offset(40)
        }
        
        self.authCodeLoginButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.top.equalTo(self.loginButton.snp.bottom).offset(30)
            make.centerX.equalTo(self.view.snp.centerX)
        }
    }
    
    override func setupData() {
        let types: [SCLoginInputType] = [.country, .username, .password]
        var items = [SCLoginInputModel]()
        for (i, type) in types.enumerated() {
            let item = SCLoginInputModel()
            item.type = type
            if type == .country {
                item.content = "深圳"
            }
            item.hasTopLine = i == 0
            items.append(item)
        }
        self.items = items
        
        self.tableView.set(list: [items])
    }
    
    private func reloadCountryData() {
        let item = self.items.first { return $0.type == .country }
        item?.content = SCUserCenter.sharedInstance.country?.name ?? ""
        self.tableView.reloadData()
    }
    
    private func reloadDataByChangeStyle() {
        if self.viewModel.loginStyle == .authCode {
            let index = self.items.firstIndex { model in
                return model.type == .password
            }
            if index != nil {
                let item = SCLoginInputModel()
                item.type = .authCode
                item.hasTopLine = false
                self.items[index!] = item
            }
        }
        else if self.viewModel.loginStyle == .username {
            let index = self.items.firstIndex { model in
                return model.type == .authCode
            }
            if index != nil {
                let item = SCLoginInputModel()
                item.type = .password
                item.hasTopLine = false
                self.items[index!] = item
            }
        }
        self.tableView.set(list: [self.items])
    }
}

// MARK: - Actions
extension SCLoginViewController {
    @objc private func rightBarButtonItemAction() {
        let vc = SCRegisterViewController()
        self.navigationController?.pushViewController(vc, animated: true)
//        #if DEBUG
//        var config = SCBindDeviceConfig()
////        config.uid = "92537"
//        config.uid = "124372"
//        config.ssid = "office-9F"
//        config.password = "sc666888"
//        config.host = "ota.3irobotix.net"
//        config.port = 8005
//
//        SCBindDeviceService.sharedInstance.startByAccessPoint(config: config) { step in
//            print("Bind test step: \(step.name)")
//        } completionHandler: { result in
//            print("Bind test result: \(result)")
//        }
//        #endif
    }
    
    @objc private func loginButtonAction() {
        self.view.endEditing(true)
        
        let vc = ViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        
       
//        let addressModel = self.items[0]
//        let userNameModel = self.items[1]
//        let passWordmodel = self.items[2]
//
//        if addressModel.content == "" {
//            SCProgressHUD.showHUD(tempLocalize("请选择地址"))
//            return
//        }
//
//        if userNameModel.content == "" {
//            SCProgressHUD.showHUD(tempLocalize("请输入手机号或者邮箱"))
//            return
//        }
//
//        if passWordmodel.content == "" {
//            SCProgressHUD.showHUD(tempLocalize("请输入密码"))
//            return
//        }
//
//        if !self.agreeButton.isSelected {
//            SCProgressHUD.showHUD(tempLocalize("请勾选同意用户协议及隐私条款"))
//            return
//        }
//
//        self.viewModel.items = self.items
//        self.viewModel.login { [weak self] in
//            SCUserCenter.sharedInstance.lastLoginUsername = userNameModel.content
//            self?.navigationController?.dismiss(animated: true, completion: nil)
//        }
    }
    
    @objc private func forgotPasswordButtonAction() {
        let vc = SCResetPasswordViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func agreeButtonClick(){
        NSLog("ssssssss")
        self.agreeButton.isSelected = !self.agreeButton.isSelected
    }
    
    @objc private func authCodeLoginButtonAction() {
        self.view.endEditing(true)
        
        self.authCodeLoginButton.isSelected = !self.authCodeLoginButton.isSelected
        self.viewModel.loginStyle = self.authCodeLoginButton.isSelected ? .authCode : .username
        self.reloadDataByChangeStyle()
    }
}

extension SCLoginViewController: SCLoginInputCellDelegate {
    func cell(_ cell: SCLoginInputCell, didTapedSelectButton model: SCLoginInputModel) {
        self.view.endEditing(true)
        let vc = SCCountryListViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func cell(_ cell: SCLoginInputCell, didTapedGetCodeButton model: SCLoginInputModel) {
        self.view.endEditing(true)
       
        let userNameModel = self.items[1]
        if userNameModel.content == "" {
            SCProgressHUD.showHUD(tempLocalize("请输入手机号或者邮箱"))
            return
        }
        self.viewModel.items = self.items
        self.viewModel.getAuthCode {
            var countDownNum = 60
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if countDownNum < 0 {
                    timer.invalidate()
                } else {
                    model.countDown = countDownNum
                    cell.model = model
                    cell.reloadCountDown()
                    countDownNum -= 1
                    
                }
            }
        }
    }
}
