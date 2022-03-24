//
//  SCLocalNetwork.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/3.
//

import CoreLocation
import SystemConfiguration.CaptiveNetwork


let kGetLocationAccessNotificationKey = "kGetLocationAccessNotificationKey"
let kPingLocalNetStatusKey = "kPingLocalNetStatusKey"

class SCLocalNetwork: NSObject {
    static let sharedInstance = SCLocalNetwork()
    
    private lazy var location: CLLocationManager = CLLocationManager()
    private var locationAuthTimer: Timer?
    private var accuracyAuthorizationTimer: Timer?
    
    private var accuracyAutorizationAlert: UIAlertController?
    
    private var pingTimer: Timer?
    private var ping: SimplePing?
    private var failure: (() -> Void)?
    private var success: (() -> Void)?
    private var pingCount: Int = 0
    private var isPingStart: Bool = false
    
    private var privatePingStatus: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kPingLocalNetStatusKey)
            UserDefaults.standard.synchronize()
        }
        get {
            let value = (UserDefaults.standard.value(forKey: kPingLocalNetStatusKey) as? Bool) ?? false
            return value
        }
    }
    
    var didQuickAlert: Bool = false
    
    var pingStatus: Bool {
        return self.privatePingStatus
    }
    
    private func startLocationAuthTimer() {
        if self.locationAuthTimer == nil {
            self.locationAuthTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(locationAuthTimerHandler), userInfo: nil, repeats: true)
            RunLoop.main.add(self.locationAuthTimer!, forMode: .common)
        }
    }
    
    private func stopLocationAuthTimer() {
        self.locationAuthTimer?.invalidate()
        self.locationAuthTimer = nil
    }
    
    @objc private func locationAuthTimerHandler() {
        let status = CLLocationManager.authorizationStatus()
        if status != .notDetermined {
            let hasAccess = status == .authorizedAlways || status == .authorizedWhenInUse
            SCSDKLog("用户授权结果：\(hasAccess)")
            self.stopLocationAuthTimer()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kGetLocationAccessNotificationKey), object: nil, userInfo: ["hasAccess": hasAccess])
        }
        else {
            SCSDKLog("用户还未授权位置权限")
        }
    }
    
    private func startAccuracyAuthorizationTimer() {
        if self.accuracyAuthorizationTimer == nil {
            self.accuracyAuthorizationTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(accuracyAuthorizationTimerAction), userInfo: nil, repeats: true)
            RunLoop.main.add(self.accuracyAuthorizationTimer!, forMode: .common)
        }
    }
    
    private func stopAccuracyAutorizationTimer() {
        self.accuracyAuthorizationTimer?.invalidate()
        self.accuracyAuthorizationTimer = nil
    }
    
    @objc private func accuracyAuthorizationTimerAction() {
        if #available(iOS 14.0, *) {
            if self.location.accuracyAuthorization == .fullAccuracy {
                self.stopAccuracyAutorizationTimer()
                SCSDKLog("开启精确位置权限")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kGetLocationAccessNotificationKey), object: nil, userInfo: ["hasAccess": true])
                if self.accuracyAutorizationAlert != nil {
                    self.accuracyAutorizationAlert?.dismiss(animated: false)
                    self.accuracyAutorizationAlert = nil
                }
            }
        }
        else {
            self.stopAccuracyAutorizationTimer()
        }
    }
    
    public func getSsid() -> String? {
        if #available(iOS 13, *) {
            if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == .notDetermined {
                self.location.requestWhenInUseAuthorization()
                self.startLocationAuthTimer()
                return nil
            }
            
            if #available(iOS 14.0, *) {
                if self.location.accuracyAuthorization != .fullAccuracy {
                    let alert = UIAlertController(title: nil, message: tempLocalize("Please enable the \"Precise Location\" permission in the \"Location\" of the APP settings to obtain the currently connected WiFi"), preferredStyle: .alert)
                    let action = UIAlertAction(title: kLocalize("global_confirm"), style: .default) { (_) in
                        let url = URL(string: UIApplication.openSettingsURLString)!
                        
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                    let cancel = UIAlertAction(title: kLocalize("global_cancel"), style: .cancel, handler: nil)
                    alert.addAction(action)
                    alert.addAction(cancel)
                    kGetTopController()?.present(alert, animated: true, completion: nil)
                    self.accuracyAutorizationAlert = alert
                    self.startAccuracyAuthorizationTimer()
                    return nil
                }
            }
            
            if CLLocationManager.authorizationStatus() == .denied {
                let alert = UIAlertController(title: nil, message: kLocalize("app_location_auth"), preferredStyle: .alert)
                let action = UIAlertAction(title: kLocalize("global_confirm"), style: .default) { (_) in
                    let url = URL(string: UIApplication.openSettingsURLString)!
                    
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                let cancel = UIAlertAction(title: kLocalize("global_cancel"), style: .cancel, handler: nil)
                alert.addAction(action)
                alert.addAction(cancel)
                kGetTopController()?.present(alert, animated: true, completion: nil)
                
                return nil
            }
        }
        
        guard let unwrappedCFArrayInterfaces = CNCopySupportedInterfaces() else {
            //            print("this must be a simulator, no interfaces found")
            return nil
        }
        guard let swiftInterfaces = (unwrappedCFArrayInterfaces as NSArray) as? [String] else {
            //            print("System error: did not come back as array of Strings")
            return nil
        }
        var wifiName: String?
        for interface in swiftInterfaces {
//            print("Looking up SSID info for \(interface)") // en0
            guard let unwrappedCFDictionaryForInterface = CNCopyCurrentNetworkInfo(interface as CFString) else {
                //                print("System error: \(interface) has no information")
                return nil
            }
            guard let SSIDDict = (unwrappedCFDictionaryForInterface as NSDictionary) as? [String: AnyObject] else {
                //                print("System error: interface information is not a string-keyed dictionary")
                return nil
            }
            wifiName = (SSIDDict["SSID"] as? String)
        }
        return wifiName ?? ""
    }
}

extension SCLocalNetwork: SimplePingDelegate {
    func pingLocalNet() {
        self.success = nil
        self.failure = nil
        
        if self.pingTimer == nil {
            self.pingTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(pingTimerHandler), userInfo: nil, repeats: true)
            self.pingTimer?.fire()
        }
    }
    
    func checkLocalNetStatus(success: @escaping (() -> Void), failure: @escaping (() -> Void)) {
        self.success = success
        self.failure = failure
        
        if self.pingTimer == nil {
            self.pingTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(pingTimerHandler), userInfo: nil, repeats: true)
            self.pingTimer?.fire()
        }
    }
    
    func stop() {
        if self.ping != nil {
            self.ping?.stop()
            self.isPingStart = false
            self.ping = nil
        }
        
        if self.pingTimer != nil {
            self.pingTimer?.invalidate()
            self.pingTimer = nil
        }
        
        self.pingCount = 0
    }
    
    @objc private func pingTimerHandler() {
        guard let ip = LDSRouterInfo.getRouterInfo()["ip"] as? String, ip.count > 0 else {
            self.perform(#selector(pingTimerHandler), with: self, afterDelay: 1.5)
            return
        }
        if self.ping == nil {
            self.ping = SimplePing(hostName: ip)
            self.ping?.delegate = self
            self.ping?.start()
            self.pingCount = 0
        }
        if self.isPingStart {
//            self.isPingStart = false
            self.ping?.send(with: Data())
            self.pingCount += 1
            
            if self.pingCount > 5 {
                self.stop()
                SCSDKLog("**不可以使用局域网**")
                self.failure?()
            }
        }
    }
    
    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        self.isPingStart = true
        if self.ping == pinger {
           print("")
        }
    }
    
    func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: UInt16) {
        SCSDKLog("**可以使用局域网**")
        self.privatePingStatus = true
        self.stop()
        self.success?()
    }
    
    func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error) {
        if (error as NSError).code == 65 {
            if self.pingCount >= 4 {
                self.stop()
                SCSDKLog("**不可以使用局域网**")
                self.failure?()
            }
        }
    }
    
    func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
        if (error as NSError).code == 65 {
            if self.pingCount >= 4 {
                self.stop()
                SCSDKLog("**不可以使用局域网**")
                self.failure?()
            }
        }
    }
    
    func simplePing(_ pinger: SimplePing, didReceiveUnexpectedPacket packet: Data) {
        
    }
}
