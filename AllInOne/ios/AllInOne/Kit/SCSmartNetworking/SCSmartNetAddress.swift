//
//  SCSmartNetAddress.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/8.
//

import UIKit

let SCNetServiceAddressSaveKey = "SCNetServiceAddressSaveKey"

/*
 代理协议
 */
protocol SCSmartNetAddressDelegate: AnyObject {
    /// 地址变化时执行代理方法
    func serviceAddressChanged(domain: SCNetResponseDomainModel?)
}

/*
 地址所需信息
 */
class SCSmartNetAddressConfig {
    /// 工程类型
    var projectType: String = ""
    /// 租户ID
    var tenantId: String = ""
    /// APP版本
    var version: String = ""
    /// 地区
    var zone: String = ""
    
    convenience init(projectType: String, tenantId: String, version: String, zone: String) {
        self.init()
        self.projectType = projectType
        self.tenantId = tenantId
        self.version = version
        self.zone = zone
    }
}

/*
 地址模块
 */
class SCSmartNetAddress {
    weak var delegate: SCSmartNetAddressDelegate?
    /// 配置信息
    private var config: SCSmartNetAddressConfig = SCSmartNetAddressConfig()
    /// 域名
    private (set) var domain: SCNetResponseDomainModel?
    
    /// 已请求次数
    private var requestCount: Int = 0
    /// 定时器
    private var timer: Timer?
    /// 是否在请求地址中
    private (set) var isRequesting: Bool = false
    /// http服务
    private var httpService: SCSmartNetHttpService?
    
    init(delegate: SCSmartNetAddressDelegate, httpService: SCSmartNetHttpService) {
        self.httpService = httpService
        self.delegate = delegate
        if let json = UserDefaults.standard.object(forKey: SCNetServiceAddressSaveKey) as? [String: String] {
            if let model = SCNetResponseDomainModel.serialize(json: json) {
                self.domain = model
                self.delegate?.serviceAddressChanged(domain: self.domain)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForegroundNotification), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func setup() {
        
    }
    
    /// 清除
    func clear() {
        self.domain = nil
        
        self.delegate?.serviceAddressChanged(domain: self.domain)
        
        SCSDKLog("WYNetServiceAddress 清除当前地址")
    }
    
    /// 配置地址所需信息
    func set(config: SCSmartNetAddressConfig) {
        SCSDKLog("** set config projectType:\(config.projectType), tenantId:\(config.tenantId), version:\(config.version), zone:\(config.zone)")
        if config.projectType != self.config.projectType || config.tenantId != self.config.tenantId || config.version != self.config.version || config.zone != self.config.zone {
            self.stopTimer()
            self.config = config
            
            self.startRequestAdress()
        }
    }
    
    /// 开始循环获取地址
    func startRequestAdress() {
        if self.config.projectType.count == 0 { return }
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if self.timer != nil { return }
            SCSDKLog("开始获取http地址和长连接地址")
            SCSDKLog("**startRequestAdress")
            self.isRequesting = true
            self.requestCount = 0
            self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [weak self] (_) in
                self?.requestAdress()
            })
            self.timer?.fire()
        }
    }
    
    /// 获取地址
    @objc func requestAdress() {
        self.requestCount += 1
        
        if self.requestCount > 5 {
            if self.timer != nil {
                self.timer?.invalidate()
                self.timer = nil
                SCSDKLog("获取http和长连接地址失败,等待下次激活重新获取")
                return
            }
            else {
                SCSDKLog("定时器销毁失败")
                return
            }
        }
        
        let param: [String: Any] = ["projectType": self.httpService!.config.projectType, "tenantId": self.httpService!.config.tenantId, "version": self.httpService!.config.version, "zone": self.httpService!.config.zone]
        
        self.httpService?.request(api: .domainsList, params: param, callback: { response in
            if response.code == 0, let json = response.json {
                guard let result = json["result"] as? [String: Any] else { return }
                guard let enDomain = result["domain"] as? String, let key = result["tenantId"] as? String else { return }
                let keyMd5 = key.MD5Encrypt(.lowercase16)
                let domain = SCSmartAESCode.aesDecrypt(content: enDomain, key: keyMd5)
                print("domain:\(domain)")

                guard let json = try? JSONSerialization.jsonObject(with: domain.data(using: .utf8) ?? Data(), options: .mutableContainers) as? [String: Any] else { return }
                guard let model = SCNetResponseDomainModel.serialize(json: json) else { return }
  
                self.stopTimer()
                SCSDKLog("service address rsp param:\(param.description), json:\(json.description)")
                
                if self.domain != model {
                    self.domain = model
                    SCSDKLog("更换当前http和长连接地址")
                    
                    UserDefaults.standard.setValue(json, forKey: SCNetServiceAddressSaveKey)
                    UserDefaults.standard.synchronize()
                    self.delegate?.serviceAddressChanged(domain: self.domain)
                    
                    SCSmartNetworking.sharedInstance.clearUser()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: SCNetLoginStatusChangedNotificationKey), object: nil, userInfo: response.json)
                }
            }
            else {
                SCSDKLog("service address rsp  param:\(param.description), error code:\(response.code)")
                if self.domain == nil && self.requestCount < 3 {
                    self.requestAdress()
                    self.requestCount += 1
                }
            }
            
        })
    }
    
    /// 将要出现在前台时重新获取地址
    @objc private func willEnterForegroundNotification() {
        if self.isRequesting {
            self.startRequestAdress()
        }
    }
    
    /// 关闭定时器
    private func stopTimer() {
        self.isRequesting = false
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
}
