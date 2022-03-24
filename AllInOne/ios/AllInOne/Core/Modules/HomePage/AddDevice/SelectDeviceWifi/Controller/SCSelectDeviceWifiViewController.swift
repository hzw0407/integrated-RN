//
//  SCSelectDeviceWifiViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/15.
//

import UIKit

class SCSelectDeviceWifiViewController: SCBasicViewController {

    var product: SCNetResponseProductModel?
    var config: SCBindDeviceConfig = SCBindDeviceConfig()
    
    private lazy var coverImageView: UIImageView = UIImageView(image: "HomePage.AddDeviceController.SelectDeviceWifiController.coverImage", contentMode: .scaleAspectFit)
    
    private lazy var instructionLabel: UILabel = UILabel(text: tempLocalize("打开手机“设置-无线局域网”连接上图所示Wi-Fi网络"), textColor: "HomePage.AddDeviceController.SelectDeviceWifiController.instructionLabel.textColor", font: "HomePage.AddDeviceController.SelectDeviceWifiController.instructionLabel.font", numberLines: 0, alignment: .center)
    
    private lazy var wifiLabel: UILabel = UILabel(text: tempLocalize("当前手机连接Wi-Fi："), textColor: "HomePage.AddDeviceController.SelectDeviceWifiController.wifiLabel.textColor", font: "HomePage.AddDeviceController.SelectDeviceWifiController.wifiLabel.font", numberLines: 0, alignment: .center)
    
    private var isPushNext: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.isPushNext = false
        self.loadSsid()
    }
}

extension SCSelectDeviceWifiViewController {
    override func setupView() {
        self.title = tempLocalize("选择设备WiFi")
        
        self.view.addSubview(self.coverImageView)
        self.view.addSubview(self.instructionLabel)
        self.view.addSubview(self.wifiLabel)
    }
    
    override func setupLayout() {
        let height = 300 / 375 * kSCScreenWidth
        self.coverImageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
            make.height.equalTo(height)
        }
        self.instructionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(self.coverImageView.snp.bottom).offset(20)
        }
        self.wifiLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.instructionLabel)
            make.top.equalTo(self.instructionLabel.snp.bottom).offset(12)
        }
    }
    
    override func setupObservers() {
        kAddObserver(self, #selector(loadSsid), UIApplication.willEnterForegroundNotification.rawValue)
        kAddObserver(self, #selector(loadSsid), kGetLocationAccessNotificationKey)
        kAddObserver(self, #selector(loadSsid), SCNetworkReachabilityStatusChangedNotificationKey)
    }
    
    @objc private func loadSsid() {
        if let ssid = SCLocalNetwork.sharedInstance.getSsid(), ssid.count > 0 {
            self.wifiLabel.text = tempLocalize("当前手机连接Wi-Fi：") + ssid
            
            let prefix = self.product?.info?.dmsPrefix ?? (self.product?.dmsPrefix ?? "i")
            if !self.isPushNext && ssid.hasPrefix(prefix) {
                let vc = SCBindDeviceViewController()
                vc.product = self.product
                vc.config = self.config
                self.navigationController?.pushViewController(vc, animated: true)
                self.isPushNext = true
            }
        }
        
    }
}
