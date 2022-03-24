//
//  SCSmartNetworkingError.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/1.
//

import UIKit


public enum SCSmartNetworkingErrorType: Int {
    case unknow
    case netError
    case timeout
    case codeError
    case tokenError
}

/*
 网络错误模型
 */
public class SCSmartNetworkingError {
    var type: SCSmartNetworkingErrorType = .codeError
    var code: Int = -1
    var msg: String?
    
    var codeType: SCSmartNetworkingCodeType = .unknow
    
    init(code: Int, type: SCSmartNetworkingErrorType = .codeError) {
        self.code = code
        self.type = type
        
        self.codeType = SCSmartNetworkingCodeType(rawValue: code) ?? .unknow
    }
}

/*
 网络请求错误码
 */
public enum SCSmartNetworkingCodeType: Int {
    case unknow = -1
    /// 成功
    case success = 0
    
    /*
     服务器错误码 600+
     */
    /// 无法解析的数据格式
    case illegalProtocol = 601
    /// http错误码
    case httpError = 602
    /// 请先登录
    case needLogin = 603
    /// 找不到服务，服务繁忙
    case noService = 604
    /// 已经登录
    case alreadyLoggedIn = 605
    /// 错误次数太多，请稍后尝试
    case reject = 606
    /// 缺少traceId
    case noTraceId = 607
    /// 禁止访问的URI
    case forbidURI = 608
    /// 未授权或者授权过期，请重新登录
    case noAuth = 609
    /// 签名错误
    case securitySignError = 610
    /// 数据异常
    case notFoundData = 611
    /// 参数合法性校验失败
    case paramValidateFail = 612
    /// 服务内部异常
    case innerServerError = 613
    /// 缓存异常
    case cacheError = 614
    /// 非法状态
    case illegalState = 615
    /// 服务器正在开小差，请稍后再试
    case serviceBusy = 616
    /// 非法操作
    case illegalOperate = 617
    /// 重复数据
    case duplicateData = 618
    /// 第三方异常
    case thirdPartyError = 619
    /// 用户名或者密码错误
    case usernamePasswordError = 620
    /// 禁止使用
    case forbidUse = 621
    /// 该用户已存在
    case userExists = 622
    /// 该用户不存在
    case userNotExists = 623
    /// 操作过于频繁，请稍后再试
    case useTooOfen = 624
    /// 没有相应的权限
    case noPermission = 625
    /// 验证码错误
    case captchaWrong = 626
    /// 房间名称已存在
    case roomNameRepeat = 690
    
    
    /// 没有网络
    case noNetwork = 1001
    /// 超时
    case timeout = 1002
    /// mqtt服务已断开
    case offline = 1003
    
    
}
