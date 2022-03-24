//
//  SCSelectWorkWifiViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/15.
//

import UIKit

class SCSelectWorkWifiViewController: SCBasicViewController {
    var product: SCNetResponseProductModel?
    var config: SCBindDeviceConfig = SCBindDeviceConfig()
    
    private lazy var coverImageView: UIImageView = UIImageView(contentMode: .scaleAspectFit)
    
    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.AddDeviceController.SelectWorkWifiController.nameLabel.textColor", font: "HomePage.AddDeviceController.SelectWorkWifiController.nameLabel.font", numberLines: 0, alignment: .center)
    
    private lazy var ssidTextField: SCSelectWorkWifiTextField = {
        let textField = SCSelectWorkWifiTextField(placeholder: tempLocalize("请先将手机链接WiFi"), isEnabled: false)
        return textField
    }()
    
    private lazy var passwordTextField: SCSelectWorkWifiTextField = {
        let textField = SCSelectWorkWifiTextField(placeholder: tempLocalize("请输入Wi-Fi密码"), isEnabled: true) { [weak self] in
            guard let `self` = self else { return }
            self.refreshNextButton()
        }
        textField.isSecureTextEntry = true
        textField.addRightButton(image: "Global.passwordSecretButton.normalImage", selectImage: "Global.passwordSecretButton.selectImage") { [weak self] isSelected in
            guard let `self` = self else { return }
            self.passwordTextField.isSecureTextEntry = !isSelected
        }
        return textField
    }()
    
    private lazy var wifiTipLabel: UILabel = UILabel(text: tempLocalize("请使用2.4G Wi-Fi，不支持5G Wi-Fi"), textColor: "HomePage.AddDeviceController.SelectWorkWifiController.wifiTipLabel.textColor", font: "HomePage.AddDeviceController.SelectWorkWifiController.wifiTipLabel.font", numberLines: 0)

    private lazy var nextButton: UIButton = {
        let btn = UIButton(tempLocalize("下一步"), titleColor: "HomePage.AddDeviceController.SelectWorkWifiController.nextButton.textColor", font: "HomePage.AddDeviceController.SelectWorkWifiController.nextButton.font", target: self, action: #selector(nextButtonAction), backgroundColor: "HomePage.AddDeviceController.SelectWorkWifiController.nextButton.backgroundColor", cornerRadius: 12)
        btn.theme_setTitleColor("HomePage.AddDeviceController.SelectWorkWifiController.nextButton.disabledTextColor", forState: .disabled)
        return btn
    }()
    
    private var ssid: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadSsid()
    }
}

extension SCSelectWorkWifiViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("选择工作WiFi")
    }
    
    override func setupView() {
        self.view.addSubview(self.coverImageView)
        self.view.addSubview(self.nameLabel)
        self.view.addSubview(self.ssidTextField)
        self.view.addSubview(self.passwordTextField)
        self.view.addSubview(self.wifiTipLabel)
        self.view.addSubview(self.nextButton)
    }
    
    override func setupLayout() {
        self.coverImageView.snp.makeConstraints { make in
            make.width.height.equalTo(120)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin).offset(40)
        }
        self.nameLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(self.coverImageView.snp.bottom).offset(20)
        }
        self.ssidTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(40)
        }
        self.passwordTextField.snp.makeConstraints { make in
            make.left.right.height.equalTo(self.ssidTextField)
            make.top.equalTo(self.ssidTextField.snp.bottom).offset(12)
        }
        self.wifiTipLabel.snp.makeConstraints { make in
            make.top.equalTo(self.passwordTextField.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
        }
        self.nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-36)
            make.height.equalTo(56)
        }
    }
    
    override func setupData() {
        self.refreshNextButton()
        
        var imgUrl = self.product?.info?.photoUrl
        
        if imgUrl == nil {
            imgUrl = self.product?.photoUrl
        }
        
        self.coverImageView.sd_setImage(with: URL(string: imgUrl ?? ""), completed: nil)
    }
    
    override func setupObservers() {
        kAddObserver(self, #selector(loadSsid), UIApplication.willEnterForegroundNotification.rawValue)
        kAddObserver(self, #selector(loadSsid), kGetLocationAccessNotificationKey)
        kAddObserver(self, #selector(loadSsid), SCNetworkReachabilityStatusChangedNotificationKey)
    }
    
    private func refreshNextButton() {
        if let ssidCount = self.ssidTextField.text?.count, let passwordCount = self.passwordTextField.text?.count, ssidCount > 0 && passwordCount > 0 {
            self.nextButton.isEnabled = true
            self.nextButton.theme_backgroundColor = "HomePage.AddDeviceController.SelectWorkWifiController.nextButton.backgroundColor"
        }
        else {
            self.nextButton.isEnabled = false
            self.nextButton.theme_backgroundColor = "HomePage.AddDeviceController.SelectWorkWifiController.nextButton.disableBackgroundColor"
        }
    }
}

extension SCSelectWorkWifiViewController {
    @objc private func nextButtonAction() {
        let ssid = self.ssidTextField.text ?? ""
        let password = self.passwordTextField.text ?? ""
        
        self.config.familyId = SCHomePageViewModel.currentFamilyId() ?? ""
        self.config.ssid = ssid
        self.config.password = password
        self.config.uid = SCSmartNetworking.sharedInstance.user?.id ?? ""
        self.config.domain = SCSmartNetworking.sharedInstance.domain
        
        if self.product!.isBluetoothCommunication {
            let vc = SCSelectBluetoothDeviceViewController()
            vc.config = self.config
            vc.product = self.product
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc = SCSelectDeviceWifiViewController()
            vc.product = self.product
            vc.config = self.config
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        SCWorkWifiModel.add(ssid: ssid, password: password)
    }
    
    @objc private func loadSsid() {
        if let ssid = SCLocalNetwork.sharedInstance.getSsid(), ssid.count > 0 {
            self.ssidTextField.text = ssid
            if self.ssid != ssid {
                self.ssid = ssid
                let pwd = SCWorkWifiModel.password(forSsid: ssid)
                if pwd.count > 0 {
                    self.passwordTextField.text = pwd
                }
                
            }
            if ssid.hasPrefix(self.product?.dmsPrefix ?? "") {
                self.wifiTipLabel.text = tempLocalize("请选择家庭Wi-Fi，请勿选择设备Wi-Fi！")
                self.wifiTipLabel.theme_textColor = "HomePage.AddDeviceController.SelectWorkWifiController.wifiTipLabel.redTextColor"
            }
            else {
                self.wifiTipLabel.text = tempLocalize("请使用2.4G Wi-Fi，不支持5G Wi-Fi")
                self.wifiTipLabel.theme_textColor = "HomePage.AddDeviceController.SelectWorkWifiController.wifiTipLabel.textColor"
            }
        }
        self.refreshNextButton()
    }
}
