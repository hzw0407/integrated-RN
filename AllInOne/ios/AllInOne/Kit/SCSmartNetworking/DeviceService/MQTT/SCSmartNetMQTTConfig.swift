//
//  SCSmartNetMQTTConfig.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/8.
//

import UIKit

class SCSmartNetMQTTConfig {
    var url: String = ""
    var host: String = ""
    var port: UInt32 = 0
    var username: String = ""
    var password: String = ""
    var clientId: String = ""
    
    /// 遗嘱主题
    private var willTopic: String = ""
    /// 遗嘱消息
    private var willMessageData: Data?
    
    func checkConfigReady() -> Bool {
        return (self.url.count > 0 || self.host.count > 0) && self.username.count > 0 && self.password.count > 0 && self.clientId.count > 0
    }
    
    func checkConfigEquel(config: SCSmartNetMQTTConfig) -> Bool {
        if self.url == config.url && self.username == config.username && self.password == config.password && self.clientId == config.clientId {
            return true
        }
        return false
    }
}
