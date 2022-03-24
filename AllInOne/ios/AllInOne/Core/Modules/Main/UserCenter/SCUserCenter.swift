//
//  SCUserCenter.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/24.
//

import UIKit

fileprivate let kAppVersionKey = "kAppVersionKey"
fileprivate let kGaodeMapApiKey = "faca5aa15834583b002f918a15873ddd"
fileprivate let kSaveCountryKey = "kSaveCountryKey"

class SCUserCenter {
    
    static let sharedInstance = SCUserCenter()
    
    private (set) var isNewAppVersion: Bool = false
    
    var lastLoginUsername: String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kLastLoginUsernameKey)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: kLastLoginUsernameKey)
        }
    }

    var user: SCNetResponseUserModel? {
        return SCSmartNetworking.sharedInstance.user
    }
    
    var isLogin: Bool {
        if let user = self.user, user.token.count > 0 {
            return true
        }
        return false
    }
    
    var country: SCCountryModel? {
        set {
            UserDefaults.standard.setValue(newValue?.json, forKey: kSaveCountryKey)
            UserDefaults.standard.synchronize()
        }
        get {
            let json = UserDefaults.standard.dictionary(forKey: kSaveCountryKey) ?? [:]
            let model = SCCountryModel(json: json)
            return model
        }
    }
    
    private (set) var netConfig: SCSmartNetAddressConfig = SCSmartNetAddressConfig()
    
    func setup() {
//        SCSmartNetworking.sharedInstance.set(projectType: "test_type", tenantId: "15223486161", version: "v1", zone: "as")
        var zone = self.country?.ab ?? "CHN"
        if zone.count == 0{
            zone = "CHN"
        }
//        self.netConfig = SCSmartNetAddressConfig(projectType: "test_type", tenantId: "1433245345114095616", version: "v1", zone: zone)
        self.netConfig = SCSmartNetAddressConfig(projectType: "test_type", tenantId: "0", version: "v1", zone: zone)
        self.netConfig.tenantId = "0"
        SCSmartNetworking.sharedInstance.set(projectType: self.netConfig.projectType, tenantId: self.netConfig.tenantId, version: self.netConfig.version, zone: self.netConfig.zone)
        SCSmartNetworking.sharedInstance.set(language: SCLocalize.appLanguage().netLanguageText)
        
        kAddObserver(self, #selector(loginStatusChangedNotification(_:)), SCNetLoginStatusChangedNotificationKey, nil)
        if (self.user?.token.count ?? 0) > 0 {
            SCSmartNetworking.sharedInstance.loginRequestWithToken(success: { _ in }, failure: { _ in })
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                self.pushToLogin()
            }
        }
        
        self.checkAppNewVersion()
        
        self.setupMap()
    }
    
    func set(zone: String) {
        self.netConfig.zone = zone
        SCSmartNetworking.sharedInstance.set(projectType: self.netConfig.projectType, tenantId: self.netConfig.tenantId, version: self.netConfig.version, zone: self.netConfig.zone)
    }
    
    private func checkAppNewVersion() {
        #if DEBUG
//        self.isNewAppVersion = true
        #endif
        let lastVersion = UserDefaults.standard.value(forKey: kAppVersionKey) as? String
        if lastVersion != kAppVersionString {
            self.isNewAppVersion = true
            UserDefaults.standard.setValue(kAppVersionString, forKey: kAppVersionKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    func pushToLogin() {
        if self.user != nil {
            SCSmartNetworking.sharedInstance.clearUser()
        }
        
        if kGetTopController() is SCLoginViewController {
            return
        }
        
        let vc = SCLoginViewController()
        let nav = SCNavigationViewController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        
        let tab = UIApplication.shared.delegate?.window??.rootViewController
        tab?.present(nav, animated: true, completion: nil)
    }
    
    @objc func loginStatusChangedNotification(_ notification: Notification) {
        if let json = notification.userInfo {
            if let code = json["code"] as? Int, code == SCSmartNetworkingCodeType.noAuth.rawValue {
                if let msg = json["msg"] as? String {
                    SCProgressHUD.showHUD(msg)
                }
                self.pushToLogin()
                return
            }
        }
        if !self.isLogin {
            self.pushToLogin()
        }
    }
    
    /// 初始化地图设置
    private func setupMap() {
        AMapServices.shared().apiKey = kGaodeMapApiKey
    }
}


