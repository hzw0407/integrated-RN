//
//  SCSmartDeviceServiceConfig.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/1.
//

import UIKit

/*
长连接类型
 */
public enum SCSmartDeviceServiceType: Int {
    case mqtt
    case webSocket
}

/*
 设备消息服务配置
 */
public class SCSmartDeviceServiceConfig: NSObject {
    public var timeoutInterval: TimeInterval = 10
    
}

public enum SCSmartDeviceServiceCodeType: Int {
    case success = 0
    /// 参数或方法错误
    case paramOrMethodError = 1
    /// 接收成功，但操作未完成（参数或方法存在错误
    case serviceNotExistError = 200
    /// 服务不存在
    case serviceParamTypeError
    /// 服务参数数量不匹配
    case serviceParamCountError
}

public enum SCSmartDeviceServiceErrorType: Int {
    case unknow
    case netError
    case offline
    case timeout
    case tokenError
    case other
}


/*
 Device Service请求响应
 */
public struct SCSmartNetDeviceServiceResponse {
    var code: Int = -1
    var msgId: String = ""
    var data: [String: Any]?
    var json: [String: Any]?
    var custom: Any?
    var error: SCSmartDeviceServiceErrorType?
    var isCache: Bool = false
}

