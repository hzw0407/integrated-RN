//
//  SCSmartNetworking.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/1.
//

import UIKit
import sqlcipher
//import Result

let SCNetLoginStatusChangedNotificationKey = "SCNetLoginStatusChangedNotificationKey"

public class SCSmartNetworking {
    
    public var domain: SCNetResponseDomainModel {
        return self.privateDomain ?? SCNetResponseDomainModel()
    }
    
    public var aesKey: String {
        return self.config.tenantId.MD5Encrypt(.lowercase16)
    }
    
    /// 单例
    public static let sharedInstance = SCSmartNetworking()
    /// http请求服务
    private lazy var httpService: SCSmartNetHttpService = SCSmartNetHttpService()
    /// 设备请求服务
    private lazy var deviceService: SCSmartNetDeviceService = SCSmartNetDeviceService()
    /// 地址服务
    private lazy var adderssService: SCSmartNetAddress = {
        let address = SCSmartNetAddress(delegate: self, httpService: self.httpService)
        return address
    }()
    /// 用户
    private (set) var user: SCNetResponseUserModel? {
        didSet {
            self.setupUser()
        }
    }
    
    private (set) var language: String = ""
    
    private var privateDomain: SCNetResponseDomainModel?
    
    private var uploadAccessModels: [String: SCNetResponseUploadAccessModel] = [:]
    
    init() {
        self.adderssService.setup()
        self.user = SCNetResponseUserModel.loadLocalUser()
        self.setupUser()
        SCNetworkReachabilityManager.shared.startListenForReachability()
    }
    
    /// 设置用户
    private func setupUser() {
        let user = self.user ?? SCNetResponseUserModel()
        self.httpService.set(authToken: user.token, userId: user.id)
        
        self.deviceService.set(username: user.id, mqttToken: user.mqttToken, tenantId: self.config.tenantId)
    }
    
    /// http配置信息
    private var config: SCSmartHttpServiceConfig {
        return self.httpService.config
    }
    
    // MARK: - user center
    /// 获取域名地址
    /// - Parameter path: 相对路径/绝对路径
    /// - Returns: 返回绝对路径地址
    public func getHttpPath(forPath path: String) -> String {
        var result = path
        if !path.hasPrefix("http") {
            return self.httpService.baseUrl + path
        }
//        result = result.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? result
        return result
    }
    
    public func set(language: String) {
        self.language = language
        self.config.lang = language
    }
    
    /// 配置
    /// - Parameters:
    ///   - projectType: 工程类型
    ///   - tenantId: 租户ID
    ///   - version: 版本号
    ///   - zone: 地区
    public func set(projectType: String, tenantId: String, version: String, zone: String) {
        let config = SCSmartNetAddressConfig(projectType: projectType, tenantId: tenantId, version: version, zone: zone)
        self.adderssService.set(config: config)
        self.httpService.set(projectType: projectType, tenantId: tenantId, version: version, zone: zone)
    }
    
    /// 清除用户
    public func clearUser() {
        self.user = nil
        SCNetResponseUserModel.clear()
    }
    
    /// 注册
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    ///   - authCode: 验证码
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func registerRequest(username: String, password: String, authCode: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let params: [String: Any] = ["username": username, "password": password, "authcode": authCode, "projectType": self.config.projectType, "phoneBrand": SCAppInformation.phoneModel, "phoneSys": 2]
        
        self.httpService.request(api: .register, params: params) {[weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 登录 (用户名 + 密码)
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func loginRequest(username: String, password: String, success: @escaping SCSuccessModelHandler<SCNetResponseUserModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let params = ["username": username, "password": password, "projectType": self.config.projectType, "lang": self.config.lang, "versionCode": 0, "versionName": "", "phoneBrand": SCAppInformation.phoneModel, "phoneSys": 2] as [String: Any]
        
        self.httpService.request(api: .login, params: params) { [weak self] response in
            guard let `self` = self else { return }
            if response.code == 0 {
                let result = response.json?["result"] as? [String: Any]
                let user = SCNetResponseUserModel.serialize(json: result) as? SCNetResponseUserModel
                self.user = user
                success(user)
            }
            else if let error = response.error {
                failure(error)
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SCNetLoginStatusChangedNotificationKey), object: nil, userInfo: response.json)
        }
    }
    
    /// 登录 (用户名 + 验证码)
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 验证码
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func loginRequestWithAuthCode(username: String, authCode: String, success: @escaping SCSuccessModelHandler<SCNetResponseUserModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let params = ["username": username, "authcode": authCode, "projectType": self.config.projectType, "lang": self.config.lang, "versionCode": 0, "versionName": "", "phoneBrand": SCAppInformation.phoneModel, "phoneSys": 2] as [String: Any]
        self.httpService.request(api: .loginWithAuthCode, params: params) { [weak self] response in
            guard let `self` = self else { return }
            if response.code == 0 {
                let result = response.json?["result"] as? [String: Any]
                let user = SCNetResponseUserModel.serialize(json: result) as? SCNetResponseUserModel
                self.user = user
                success(user)
            }
            else if let error = response.error {
                failure(error)
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SCNetLoginStatusChangedNotificationKey), object: nil, userInfo: response.json)
        }
    }
    
    /// 静默登录
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func loginRequestWithToken(success: @escaping SCSuccessModelHandler<SCNetResponseUserModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        guard let user = self.user else {
            let error = SCSmartNetworkingError(code: -2, type: .tokenError)
            failure(error)
            return
        }
        let params = ["userId": user.id, "token": user.token, "projectType": self.config.projectType, "lang": self.config.lang, "versionCode": 0, "versionName": "", "phoneBrand": SCAppInformation.phoneModel, "phoneSys": 2] as [String: Any]
        self.httpService.request(api: .loginWithToken, params: params) { [weak self] response in
            guard let `self` = self else { return }
            if response.code == 0 {
//                let result = response.json?["result"] as? [String: Any]
//                let user = SCNetResponseUserModel.serialize(json: result) as? SCNetResponseUserModel
//                self.user = user
                self.setupUser()
                success(user)
            }
            else if let error = response.error {
                if error.code > 0 {
                    self.clearUser()
                }
                failure(error)
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SCNetLoginStatusChangedNotificationKey), object: nil, userInfo: response.json)
        }
    }
    
    /// 获取验证码
    /// - Parameters:
    ///   - username: 用户名
    ///   - type: 验证码类型
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getAuthCodeRequest(username: String, type: SCSmartNetHttpAuthCodeType, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let params = ["username": username, "scope": type.rawValue, "projectType": self.config.projectType, "lang": self.config.lang] as [String: Any]
        self.httpService.request(api: .getAuthCode, params: params) {[weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 登出
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func logoutRequest(success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        guard let user = self.user else {
            success()
            return
        }
        let param = ["userId": user.id]
        self.httpService.request(api: .logout, params: param) {[weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 修改密码
    /// - Parameters:
    ///   - oldPassword: 旧密码
    ///   - newPassword: 新密码
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func changePasswordRequest(oldPassword: String, newPassword: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        guard let user = self.user else {
            let error = SCSmartNetworkingError(code: -2, type: .tokenError)
            failure(error)
            return
        }
        let params = ["newPassword": newPassword, "oldPassword": oldPassword, "userId": user.id]
        self.httpService.request(api: .changePassword, params: params) {[weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 重置密码
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    ///   - authCode: 验证码
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func resetPasswordRequest(username: String, password: String, authCode: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let params = ["authcode": authCode, "username": username, "password": password]
        self.httpService.request(api: .resetPassword, params: params) {[weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 获取用户头像
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getUserAvatarRequest(success: @escaping SCSuccessModelHandler<String>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        self.httpService.request(api: .getAvatar, params: nil) { [weak self] response in
            self?.parseAnyResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 获取用户昵称
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getUserNicknameRequest(success: @escaping SCSuccessModelHandler<String>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        self.httpService.request(api: .getNickname, params: nil) { [weak self] response in
            self?.parseAnyResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 获取用户简介
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getUserProfileRequest(isCache: Bool, success: @escaping SCSuccessModelHandler<SCNetResponseUserProfileModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        self.httpService.request(api: .getProfile, params: nil, isCache: isCache) { [weak self] response in
            self?.parseModelResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 修改用户头像
    /// - Parameters:
    ///   - url: 头像地址
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func modifyUserAvatarRequest(url: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["url": url]
        self.httpService.request(api: .modifyAvatar, params: param) {[weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 修改用户昵称
    /// - Parameters:
    ///   - nickname: 昵称
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func modifyUserNicknameRequest(nickname: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["nickname": nickname]
        self.httpService.request(api: .modifyNickname, params: param) {[weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 修改邮箱
    /// - Parameters:
    ///   - email: 邮箱地址
    ///   - authCode: 验证码
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func modifyEmailRequest(email: String, authCode: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        guard let user = self.user else {
            let error = SCSmartNetworkingError(code: -2, type: .tokenError)
            failure(error)
            return
        }
        let headers = ["email": user.username, "id": user.id, "username": user.username]
        let param = ["email": email, "authCode": authCode]
        self.httpService.request(api: .modifyEmail, params: param, headers: headers) {[weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    
    
    /// 修改手机号
    /// - Parameters:
    ///   - phone: 手机号
    ///   - authCode: 验证码
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func modifyPhoneRequest(phone: String, authCode: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        guard let user = self.user else {
            let error = SCSmartNetworkingError(code: -2, type: .tokenError)
            failure(error)
            return
        }
        let headers = ["phone": user.username, "id": user.id, "username": user.username]
        let param = ["phone": phone, "authCode": authCode]
        self.httpService.request(api: .modifyPhone, params: param, headers: headers) {[weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 设置国家/地区
    /// - Parameters:
    ///   - country: 国家/地区代码
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func setCountryRequest(country: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["country": country]
        self.httpService.request(api: .setCountry, params: param) {[weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    
    /// 删除账号
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func deleteAccountRequest(success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        guard let user = self.user else {
            let error = SCSmartNetworkingError(code: -2, type: .tokenError)
            failure(error)
            return
        }
        let headers = ["username": user.username]
        self.httpService.request(api: .deleteAccount, params: nil, headers: headers) {[weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    // MARK: - device
    
    public func getProductListRequest(isCache: Bool = false, success: @escaping SCSuccessModelArrayHandler<SCNetResponseProductModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        self.httpService.request(api: .getProductList, params: nil, isCache: isCache) {  [weak self] response in
            self?.parseModelArrayResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func getProductInfoListRequest(productIds: [String], success: @escaping SCSuccessModelArrayHandler<SCNetResponseProductInfoModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["productIds": productIds]
        self.httpService.request(api: .getProductInfoList, params: param) { [weak self] response in
            self?.parseModelArrayResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func getProductTypeListRequest(classifyParentId: String? = nil, isCache: Bool = false, success: @escaping SCSuccessModelArrayHandler<SCNetResponseProductTypeParentModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var param: [String: Any]?
        if classifyParentId != nil {
            param = ["classifyParentId": classifyParentId!]
        }
        self.httpService.request(api: .getProductTypeList, params: param, isCache: isCache) { [weak self] response in
            self?.parseModelArrayResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func getProductInfoRequest(id: String, isCache: Bool = false, success: @escaping SCSuccessModelHandler<SCNetResponseProductInfoModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["id": id]
        self.httpService.request(api: .getProductInfo, params: param, isCache: isCache) { [weak self] response in
            self?.parseModelResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// APP绑定设备
    /// - Parameters:
    ///   - sn: sn
    ///   - mac: mac
    ///   - nickname: 设备昵称
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func appBindDeviceRequest(sn: String, mac: String, nickname: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        guard let user = self.user else {
            let error = SCSmartNetworkingError(code: -2, type: .tokenError)
            failure(error)
            return
        }
        let headers = ["id": user.id, "username": user.username]
        let param = ["sn": sn, "mac": mac, "nickname": nickname]
        self.httpService.request(api: .appBindDevice, params: param, headers: headers) {[weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 获取设备绑定APP结果
    /// - Parameters:
    ///   - bindKey: 绑定key
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getDeviceBindAppResultRequest(bindKey: String, familyId: String, success: @escaping SCSuccessModelHandler<SCNetResponseBindAppResultModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["bindKey": bindKey, "familyId": familyId]
        self.httpService.request(api: .deviceBindAppResult, params: param) {[weak self] response in
            self?.parseModelResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 获取设备信息
    /// - Parameters:
    ///   - sn: 设备sn
    ///   - mac: 设备mac地址
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getDeviceInfoRequest(sn: String, mac: String, success: @escaping SCSuccessModelHandler<SCNetResponseDeviceInfoModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["sn": sn, "mac": mac]
        self.httpService.request(api: .getDeviceInfo, params: param) { [weak self] response in
            self?.parseModelResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 修改设备昵称
    /// - Parameters:
    ///   - deviceId: 设备ID
    ///   - nickname: 设备昵称
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func modifyDeviceNicknameRequest(deviceId: String, roomId: String, nickname: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["deviceId": deviceId, "roomId": roomId, "nickname": nickname]
        self.httpService.request(api: .modifyDeviceNickname, params: param) {[weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 获取设备在线状态
    /// - Parameters:
    ///   - deviceId: 设备ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getDeviceOnlineStatusRequest(deviceId: String, success: @escaping SCSuccessModelHandler<Bool>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["deviceId": deviceId]
        self.httpService.request(api: .getDeviceOnlineStatus, params: param) {[weak self] response in
            self?.parseAnyResponse(response: response, success: success, failure: failure)
        }
    }
    
    
    /// 获取设备状态
    /// - Parameters:
    ///   - deviceId: 设备ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getDeviceStatusRequest(deviceId: String, success: @escaping SCSuccessModelHandler<Bool>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["deviceId": deviceId]
        let headers = ["bindList": "[\(deviceId)]"]
        self.httpService.request(api: .getDeviceStatus, params: param, headers: headers) {[weak self] response in
            self?.parseAnyResponse(response: response, success: success, failure: failure)
        }
    }
    
    
    /// 设置默认设备
    /// - Parameters:
    ///   - deviceId: 设备ID
    ///   - success: 成功回调，参数为Bool类型，true为设置成功，false为设备绑定关系不存在
    ///   - failure: 失败回调
    public func setDefaultDeviceRequest(deviceId: String, success: @escaping SCSuccessModelHandler<Bool>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["deviceId": deviceId]
        let headers = ["bindList": "[\(deviceId)]"]
        self.httpService.request(api: .setDefaultDevice, params: param, headers: headers) {[weak self] response in
            self?.parseAnyResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 分享设备给其他用户
    /// - Parameters:
    ///   - username: 被分享的用户名
    ///   - deviceId: 被分享的设备ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func shareDeviceToUserRequest(username: String, deviceIds: [String], success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param: [String: Any] = ["beInvited": username, "targetIds": deviceIds]
        self.httpService.request(api: .shareDeviceToUser, params: param) {[weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 删除分享信息
    /// - Parameters:
    ///   - shareId: 分享ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func deleteShareRequest(shareId: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["shareId": shareId]
        self.httpService.request(api: .deleteShare, params: param) {[weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 获取分享信息
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getShareInfoRequest(deviceId: String,tenantId: String,isInviter: Int, success: @escaping SCSuccessModelArrayHandler<SCNetResponseDeviceModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var param: [String: Any]?
        param = ["deviceId": deviceId,"tenantId": tenantId,"inviter": isInviter]
        self.httpService.request(api: .getShareInfo, params: param) { [weak self] response in
            self?.parseModelArrayResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 获取个人中心历史分享记录
    /// - Parameters:
    ///   - targetId: 家庭id或设备id, 当查询家庭分享记录的时候必填
    ///   - page: 页码，默认第0页
    ///   - pageSize: 每页条数，默认30条
    ///   - type: 共享类型，暂时忽略
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getShareHistoryRequest(targetId: String?, type: Int? = nil, page: Int = 1, pageSize: Int = 30, success: @escaping SCSuccessModelHandler<SCNetResponseShareHistoryModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var param: [String: Any] = ["page": page, "pageSize": pageSize]
        param["targetId"] = targetId
        param["type"] = type
        self.httpService.request(api: .getShareHistory, params: param) { [weak self] response in
            self?.parseModelResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 回复分享
    /// - Parameters:
    ///   - type: 共享类型，0-设备共享，1-家庭共享
    ///   - replyType: 1-同意，2-拒绝
    ///   - familyId: 家庭id，共享设备时必填
    ///   - inviterId: 邀请者用户ID
    ///   - targetId: 被分享的目标ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func replyForShareRequest(type: Int, replyType: Int, familyId: String?, inviterId: String, targetId: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var param: [String: Any] = ["type": type, "dealType": replyType, "inviterId": inviterId, "targetId": targetId]
        param["familyId"] = familyId
        self.httpService.request(api: .replyForShare, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    
    /// 回复分享
    /// - Parameters:
    ///   - deviceId: 被分享的设备ID
    ///   - inviterId: 邀请者用户ID
    ///   - dealType: 1-同意，2-拒绝
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func replyShareByUserRequest(deviceId: String, inviterId: String, familyId: String, dealType: Int, success: @escaping SCSuccessModelHandler<Bool>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["deviceId": deviceId, "inviterId": inviterId, "familyId": familyId, "dealType": dealType] as [String: Any]
        self.httpService.request(api: .replyShareByUser, params: param) { [weak self] response in
            self?.parseAnyResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 触发设备升级
    /// - Parameters:
    ///   - deviceId: 设备ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func triggerDeviceUpgradeRequest(deviceId: String, success: @escaping SCSuccessModelHandler<Bool>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["deviceId": deviceId]
        let headers = ["bindList": "[\(deviceId)]"]
        self.httpService.request(api: .triggerDeviceUpgrade, params: param, headers: headers) { [weak self] response in
            self?.parseAnyResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 解绑设备
    /// - Parameters:
    ///   - deviceId: 设备ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func unbindDeviceRequest(deviceId: String, success: @escaping SCSuccessModelHandler<Bool>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["deviceId": deviceId]
        self.httpService.request(api: .unbindDevice, params: param) {[weak self] response in
            self?.parseAnyResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 上传文件
    /// - Parameters:
    ///   - direction: <#direction description#>
    ///   - district: 地区
    ///   - fileName: 文件名称
    ///   - data: 数据
    ///   - success: 成功回调
    ///   - progress: <#progress description#>
    ///   - failure: <#failure description#>
    public func uploadFileRequest(direction: String, district: String, fileName: String, data: Data, success: @escaping SCSuccessModelHandler<String>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let params: [String: Any] = ["dir": direction, "district": district, "tenantId": self.config.tenantId, "file": data]
        self.httpService.upload(api: .uploadFile, params: params, fileName: fileName) { [weak self] response in
            self?.parseAnyResponse(response: response, success: success, failure: failure)
        }
    }
    
    
    /// 获取FAQ列表
    /// - Parameters:
    ///   - productId: 产品ID
    ///   - typeId: 类型
    ///   - page: 当前页
    ///   - pageSize: 页数
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getFaqListRequest(productId: String, typeId: String? = nil, page: Int = 1, pageSize: Int = 30, success: @escaping SCSuccessModelHandler<SCNetResponseFaqsInfoModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var params: [String: Any] = ["productId": productId, "lang": self.language]
        params["typeId"] = typeId
        params["page"] = page
        params["pageSize"] = pageSize
        self.httpService.request(api: .getFaqList, params: params) { [weak self] response in
            self?.parseModelResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func getUserProtocolTypeListRequest(lang: String, success: @escaping SCSuccessModelHandler<SCNetResponseUserProtocolTypeModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let params = ["lang": lang]
        self.httpService.request(api: .getUserProtocolType, params: params) { [weak self] response in
            self?.parseModelResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func getUserProtocolListRequest(type: Int, lang: String, success: @escaping SCSuccessModelHandler<SCNetResponseUserProtocolContentModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let params: [String: Any] = ["type": type, "lang": lang]
        self.httpService.request(api: .getUserProtocolContent, params: params) { [weak self] response in
            self?.parseModelResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func getProductManualDownloadUrl(lang: String, success: @escaping SCSuccessModelHandler<SCNetResponseProductManualModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let params = ["lang": lang, "code": "0"]
        self.httpService.request(api: .getProductManualDownloadUrl, params: params) { [weak self] response in
            self?.parseModelResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 上传日志
    /// - Parameters:
    ///   - type: 日志类型
    ///   - content: 日志内容
    ///   - sn: sn
    ///   - time: 发生时间
    ///   - fileUrl: 文件
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func uploadAppLog(type: SCNetHttpLogType, content: String?, sn: String?, time: Int64?, fileUrl: String?, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var param: [String: Any] = ["appVersion": SCAppInformation.appVersion, "phoneMode": SCAppInformation.phoneModel, "systemVersion": SCAppInformation.phoneSystemVersion, "tenantId": self.config.tenantId, "userId": self.user?.id ?? 0, "username": self.user?.username ?? "", "zone": self.config.zone]
        if content != nil {
            param["content"] = content
        }
        if sn != nil {
            param["sn"] = sn
        }
        if time != nil {
            param["time"] = time
        }
        else {
            param["time"] = Int64(Date().timeIntervalSince1970)
        }
        param["type"] = type.value
        if fileUrl != nil {
            param["url"] = fileUrl
        }
        self.httpService.request(api: type.api, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    // MARK: - Family
    public func addFamilyRequest(name: String, address: String?, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var param: [String: Any] = ["familyName": name]
        param["address"] = address
//        param["tenantId"] = self.config.tenantId
        self.httpService.request(api: .addFamily, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func getFamilyDetailRequest(id: String, isCache: Bool = false, success: @escaping SCSuccessModelHandler<SCNetResponseFamilyModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        self.httpService.request(api: .getFamilyDetail, params: nil, pathParam: id, isCache: isCache) { [weak self] response in
            self?.parseModelResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func getFamilyListWithRoomsDeviceIdsRequest(success: @escaping SCSuccessModelArrayHandler<SCNetResponseFamilyModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        self.httpService.request(api: .getFamilyListWithRoomsDeviceIds, params: nil, pathParam: self.user?.id) { [weak self] response in
            self?.parseModelArrayResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func getFamilyListRequest(isCache: Bool = false, success: @escaping SCSuccessModelArrayHandler<SCNetResponseFamilyModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        self.httpService.request(api: .getFamilyList, params: nil, pathParam: self.user?.id, isCache: isCache) { [weak self] response in
            self?.parseModelArrayResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func getConsumablesInfoByFamilyIdRequest(familyId: String, success: @escaping SCSuccessModelArrayHandler<SCMineConsumableModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
      
        self.httpService.request(api: .getConsumablesInfoByFamilyId, params: nil, pathParam: familyId) { [weak self] response in
            self?.parseModelArrayResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func modifyFamilyRequest(familyId: String, name: String?, headUrl: String?, address: String?, country: String?, city: String?, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var param = ["id": familyId]
        param["familyName"] = name
        param["headUrl"] = headUrl
        param["address"] = address
        param["country"] = country
        self.httpService.request(api: .modifyFamily, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func deleteFamilyRequest(familyId: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        self.httpService.request(api: .deleteFamily, params: nil, pathParam: familyId) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func addFamilyRoomRequest(familyId: String, name: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["familyId": familyId, "roomName": name]
        self.httpService.request(api: .addFamilyRoom, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 修改家庭房间
    /// - Parameters:
    ///   - roomId: 房间ID
    ///   - name: 房间名称
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func modifyFamilyRoomRequest(familyId: String, roomId: String, name: String?, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var param = ["id": roomId]
        param["roomName"] = name
        param["familyId"] = familyId
        self.httpService.request(api: .modifyFamilyRoom, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 删除家庭房间
    /// - Parameters:
    ///   - roomId: 房间ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func deleteFamilyRoomsRequest(roomIds: [String], success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["ids": roomIds]
        self.httpService.request(api: .deleteFamilyRooms, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 修改房间设备昵称
    /// - Parameters:
    ///   - roomId: 房间ID
    ///   - deviceId: 设备ID
    ///   - nickname: 昵称
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func modifyRoomDeviceNickname(roomId: String, deviceId: String, nickname: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["roomId": roomId, "deviceId": deviceId, "nickname": nickname]
        self.httpService.request(api: .modifyFamilyRoomDeviceNickname, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 将设备从某个房间移动到另外一个房间
    /// - Parameters:
    ///   - deviceId: 设备ID
    ///   - fromRoomId: 来源房间ID
    ///   - toRoomId: 目的房间ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func moveDeviceToRoom(deviceIds: [String], fromRoomId: String, toRoomId: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param: [String: Any] = ["fromRoomId": fromRoomId, "deviceIdList": deviceIds, "toRoomId": toRoomId]
        self.httpService.request(api: .moveDeviceToOtherRoom, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 将设备从某个房间移动到另外一个房间
    /// - Parameters:
    ///   - deviceId: 设备ID
    ///   - fromRoomId: 来源房间ID
    ///   - toRoomId: 目的房间ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func moveDeviceToUsedRoom(deviceIds: [String], roomId: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param: [String: Any] = ["roomId": roomId, "deviceIdList": deviceIds]
        self.httpService.request(api: .moveDeviceToUsedRoom, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 将房间设备移动到顶部
    /// - Parameters:
    ///   - roomId: 房间ID
    ///   - deviceIds: 设备列表
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func moveRoomDeviceToTop(roomId: String, deviceIds: [String], success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param: [String: Any] = ["roomId": roomId, "idList": deviceIds]
        self.httpService.request(api: .moveRoomDeviceToTop, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 根据房间ID获取设备列表
    /// - Parameters:
    ///   - roomId: 房间ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getDeviceListByFamilyRoomRequest(roomId: String, success: @escaping SCSuccessModelArrayHandler<SCNetResponseDeviceModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["roomId": roomId]
        self.httpService.request(api: .getDeviceListByFamilyRoom, params: param) { [weak self] response in
            self?.parseModelArrayResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 设置房间默认设备
    /// - Parameters:
    ///   - roomId: 房间ID
    ///   - deviceId: 设备ID
    ///   - success: 成功回调 （返回false代表该设备绑定关系不存在）
    ///   - failure: 失败回调
    public func setRoomDefaultDeviceRequest(roomId: String, deviceId: String, success: @escaping SCSuccessModelHandler<Bool>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["roomID": roomId, "deviceId": deviceId]
        self.httpService.request(api: .setRoomDefaultDevice, params: param) { [weak self] response in
            self?.parseAnyResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 更新家庭房间排序
    /// - Parameters:
    ///   - familyId: 家庭ID
    ///   - roomIds: 房间ID数组
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func updateFamilyRoomsSortRequest(familyId: String, roomIds: [String], success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param: [String: Any] = ["familyId": familyId, "idList": roomIds]
        self.httpService.request(api: .updateFamilyRoomsSort, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 添加家庭成员
    /// - Parameters:
    ///   - familyId: 家庭ID
    ///   - username: 用户名:邮箱/手机号/艾加ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func addFamilyMemberRequest(familyId: String, username: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        guard let user = self.user else { return }
        let param = ["familyId": familyId, "userName": username, "userId": user.id]
        self.httpService.request(api: .addFamilyMember, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func getWaitReplyListByFamilyShareRequest(success: @escaping SCSuccessModelArrayHandler<SCNetResponseFamilyShareModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        guard let user = self.user else { return }
        let param = ["userId": user.id]
        self.httpService.request(api: .getWaitReplyByFamilyShare, params: param) { [weak self] response in
            self?.parseModelArrayResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 回复家庭分享
    /// - Parameters:
    ///   - shareId: 分享ID
    ///   - shareStatus: 共享状态(0、拒绝 1、等待确认 2、已经确认 3、管理员撤销 4、被分享者主动退出)
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func replyFamilyShareRequest(shareId: String, shareStatus: String, success: @escaping SCSuccessModelHandler<Bool>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["id": shareId, "shareStatus": shareStatus]
        self.httpService.request(api: .replyFamilyShare, params: param) { [weak self] response in
            self?.parseAnyResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 成员主动退出家庭
    /// - Parameters:
    ///   - familyId: 家庭ID
    ///   - shareId: 分享ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func exitFamilyByUserRequest(familyId: String, shareId: String, success: @escaping SCSuccessModelHandler<Bool>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["id": shareId, "shareStatus": "4", "familyId": familyId]
        self.httpService.request(api: .exitFamilyByUser, params: param) { [weak self] response in
            self?.parseAnyResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 删除家庭成员
    /// - Parameters:
    ///   - familyId: <#familyId description#>
    ///   - inviteId: 邀请人id
    ///   - beInviteId: 被邀请人的用户id
    ///   - success: <#success description#>
    ///   - failure: <#failure description#>
    public func deleteFamilyMemberRequest(familyId: String, inviteId: String, beInviteId: String?, success: @escaping SCSuccessModelHandler<Bool>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var param = ["inviteId": inviteId, "familyId": familyId]
        param["beInviteId"] = beInviteId
        self.httpService.request(api: .deleteFamilyMember, params: param) { [weak self] response in
            self?.parseAnyResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 获取分享记录列表
    /// - Parameters:
    ///   - page: <#page description#>
    ///   - pageSize: <#pageSize description#>
    ///   - success: <#success description#>
    ///   - failure: <#failure description#>
    public func getFamilyShareRecordRequest(page: Int = 1, pageSize: Int = 20, success: @escaping SCSuccessModelArrayHandler<SCNetResponseFamilyShareModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        guard let user = self.user else { return }
        let param: [String: Any] = ["userId": user.id, "pageNum": page, "pageSize": pageSize]
        self.httpService.request(api: .getFamilyShareRecord, params: param) { [weak self] response in
            self?.parseModelArrayResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 获取家庭成员列表
    /// - Parameters:
    ///   - familyId: 家庭ID
    ///   - page: 页码
    ///   - pageSize: 一页数量
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getFamilyMemberListRequest(page: Int = 1, pageSize: Int = 20, familyId: String, success: @escaping SCSuccessModelArrayHandler<SCNetResponseFamilyMemberModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param: [String: Any] = ["familyId": familyId, "pageNum": page, "pageSize": pageSize]
        self.httpService.request(api: .getFamilyMemberList, params: param) { [weak self] response in
            self?.parseModelArrayResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 获取家庭成员详情信息
    /// - Parameters:
    ///   - familyId: 家庭ID
    ///   - userId: 用户ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getFamilyMemberDetailRequest(familyId: String, userId: String, success: @escaping SCSuccessModelHandler<SCNetResponseFamilyMemberModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["familyId": familyId, "userId": userId]
        self.httpService.request(api: .getFamilyMemberDetail, params: param) { [weak self] response in
            self?.parseModelResponse(response: response, success: success, failure: failure)
        }
    }

    
    /// 根据家庭ID获取设备列表
    /// - Parameters:
    ///   - familyId: 家庭ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getDeviceListByFamilyRequest(familyId: String, isCache: Bool = false, success: @escaping SCSuccessModelArrayHandler<SCNetResponseDeviceModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        self.httpService.request(api: .getDeviceListByFamily, params: nil, pathParam: familyId, isCache: isCache) { [weak self] response in
            self?.parseModelArrayResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 获取设备列表
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getDeviceListRequest(isCache: Bool = false, success: @escaping SCSuccessModelArrayHandler<SCNetResponseDeviceModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        guard let user = self.user else {
            let error = SCSmartNetworkingError(code: -2, type: .tokenError)
            failure(error)
            return
        }
        self.httpService.request(api: .getDeviceListByUid, params: nil, pathParam: user.id, isCache: isCache) { [weak self] response in
            self?.parseModelArrayResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 用户家庭房间绑定设备
    /// - Parameters:
    ///   - sn: 设备sn
    ///   - deviceId: 设备ID
    ///   - nickname: 设备昵称
    ///   - roomId: 房间ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func bindDeviceByRoom(deviceId: String, roomId: String, familyId: String, nickname: String?, sn: String?, productId: String?, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var param: [String: Any] = ["roomId": roomId, "deviceId": deviceId, "familyId": familyId]
        param["nickname"] = nickname
        param["sn"] = sn
        param["productId"] = productId
        self.httpService.request(api: .bindDeviceByRoom, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 用户家庭房间解绑设备
    /// - Parameters:
    ///   - deviceId: 设备ID
    ///   - roomId: 房间ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func unbindDeviceByRoom(deviceId: String, roomId: String, success: @escaping SCSuccessModelHandler<Bool>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param: [String: Any] = ["roomId": roomId, "deviceId": deviceId]
        self.httpService.request(api: .unbindDeviceByRoom, params: param) { [weak self] response in
            self?.parseAnyResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 根据用户id获取分享设备列表
    /// - Parameters:
    ///   - userId: 用户ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getShareDevices(userId: String, success: @escaping SCSuccessModelArrayHandler<SCNetResponseDeviceModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        guard let user = self.user else { return }
        self.httpService.request(api: .getShareDevice, params: nil, pathParam: user.id) { [weak self] response in
            self?.parseModelArrayResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 根据用户id获取接受设备列表
    /// - Parameters:
    ///   - userId: 用户ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getAcceptListDevices(userId: String, success: @escaping SCSuccessModelArrayHandler<SCNetResponseDeviceModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        guard let user = self.user else { return }
        self.httpService.request(api: .getAcceptList, params: nil, pathParam: user.id) { [weak self] response in
            self?.parseModelArrayResponse(response: response, success: success, failure: failure)
        }
    }
    
    
    /// 用户家庭绑定分享设备
    /// - Parameters:
    ///   - sn: 设备sn
    ///   - deviceId: 设备ID
    ///   - nickname: 设备昵称
    ///   - familyId: 家庭ID
    ///   - owner: 设备拥有者(用户ID)
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func bindShareDeviceByFamily(sn: String, deviceId: String, nickname: String?, familyId: String?, owner: String?, success: @escaping SCSuccessModelHandler<Bool>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var param: [String: Any] = ["sn": sn, "deviceId": deviceId]
        param["nickname"] = nickname
        param["familyId"] = familyId
        param["owner"] = owner
        param["userId"] = self.user?.id
        self.httpService.request(api: .bindShareDeviceByFamily, params: param) { [weak self] response in
            self?.parseAnyResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 用户家庭解绑分享设备
    /// - Parameters:
    ///   - deviceId: 设备ID
    ///   - roomId: 房间ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func unbindShareDeviceByFamily(deviceId: String, roomId: String?, success: @escaping SCSuccessModelHandler<Bool>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var param: [String: Any] = ["deviceId": deviceId]
        param["roomId"] = roomId
        self.httpService.request(api: .unbindShareDeviceByFamily, params: param) { [weak self] response in
            self?.parseAnyResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 将设备移出常用
    /// - Parameters:
    ///   - deviceIds: 设备ID数组
    ///   - roomId: 房间ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func moveDeviceOutUsedRequest(deviceIds: [String], roomId: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param: [String: Any] = ["deviceIdList": deviceIds, "roomId": roomId]
        self.httpService.request(api: .moveDeviceOutUsed, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 更新房间设备排序
    /// - Parameters:
    ///   - deviceIds: 设备ID数组
    ///   - roomId: 房间ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func updateRoomDevicesSortRequest(deviceIds: [String], roomId: String, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param: [String: Any] = ["idList": deviceIds, "roomId": roomId]
        self.httpService.request(api: .updateRoomDevicesSort, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
//    public func getFeedbackListRequest(deviceId: String, type: String, page: Int? = nil, pageSize: Int? = nil, success: @escaping SCSuccessModelHandler<SCNetResponseFeedbackMainModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
//        guard let user = self.user else { return }
//        var api = SCSmartHttpServiceApi.getAllFeedbackList
//        var param: [String: Any] = ["deviceId": deviceId, "type": type, "userId": user.id]
//        if page != nil && pageSize != nil {
//            api = .getFeedbackListByPage
//            param["page"] = page
//            param["pageSize"] = pageSize
//        }
//        self.httpService.request(api: api, params: param) { [weak self] response in
//            self?.parseModelResponse(response: response, success: success, failure: failure)
//        }
//    }
    
    public func uploadFeedbackRequest(productId: String, title: String?, phone: String, question: String, type: String, questionType: String, routerModel: String?, url: String?, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        guard let user = self.user else { return }
        var param: [String: Any] = ["productId": productId, "phone": phone, "type": type, "question": question, "questionType": questionType, "userId": user.id, "zone": self.config.zone]
        param["title"] = title
        param["routerModel"] = routerModel
        param["url"] = url
        
        self.httpService.request(api: .uploadFeedback, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 获取问题反馈记录
    /// - Parameters:
    ///   - deviceId: 设备ID
    ///   - type: 类型
    ///   - page: 当前页
    ///   - pageSize:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getFeedbackRecordRequest(deviceId: String? = nil, type: String? = nil, page: Int = 1, pageSize: Int = 30, success: @escaping SCSuccessModelHandler<SCNetResponseFeedbackRecordsInfoModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var param: [String: Any] = ["userId": self.user?.id ?? "", "page": page, "pageSize": pageSize]
        param["deviceId"] = deviceId
        param["type"] = type
        self.httpService.request(api: .getFeedbackRecord, params: param) { [weak self] response in
            self?.parseModelResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 删除问题反馈记录
    /// - Parameters:
    ///   - ids: id数组
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func deleteFeedbackRecordRequest(ids: [String], success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param = ["ids": ids]
        self.httpService.request(api: .deleteFeedbackRecord, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func setRemoteNotificationRequest(isOn: Bool, isQuietOn: Bool, day: String, beginTime: String, endTime: String, success: @escaping SCSuccessModelHandler<Bool>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var param: [String: Any] = ["open": isOn ? 1 : 0]
        param["notNotice"] = isQuietOn ? 1 : 0
        param["day"] = day
        param["beginTime"] = beginTime
        param["endTime"] = endTime
        self.httpService.request(api: .setRemoteNotification, params: param) { [weak self] response in
            self?.parseAnyResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func getRemoteNotificationConfigRequest(success: @escaping SCSuccessModelHandler<SCNetResponseRemoteNotificationConfigModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        self.httpService.request(api: .getRemoteNotificationConfig, params: nil) { [weak self] response in
            self?.parseModelResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func getDeviceNotificationRecordRequest(page: Int = 1, pageSize: Int = 30, deviceId: String? = nil, beginTime: Int64? = nil, endTime: Int64? = nil, success: @escaping SCSuccessModelHandler<SCNetResponseDeviceNotificaitonRecordsInfoModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var param: [String: Any] = ["page": page, "pageSize": pageSize]
        param["deviceId"] = deviceId
        param["beginTime"] = beginTime
        param["endTime"] = endTime
        self.httpService.request(api: .getDeviceNotificationRecord, params: param) { [weak self] response in
            self?.parseModelResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func getShareNotificationRecordRequest(targetId: String?, type: Int, page: Int = 1, pageSize: Int = 30, success: @escaping SCSuccessModelHandler<SCNetResponseShareNotificaitonRecordsInfoModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var param: [String: Any] = ["type": type, "page": page, "pageSize": pageSize]
        param["targetId"] = targetId
        self.httpService.request(api: .getShareNotificationRecord, params: param) { [weak self] response in
            self?.parseModelResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func replyByShareNotificationRecordRequest(recordId: String, shareId: String, status: Int, familyId: String?, familyName: String?, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var param: [String: Any] = ["recordId": recordId, "shareId": shareId, "status": status]
        param["familyId"] = familyId
        param["familyName"] = familyName
        self.httpService.request(api: .replyByShareNotificationRecord, params: param) { [weak self] response in
            self?.parseNormalResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func getConsumablesListRequest(productClassifyId: String? = nil, label: String? = nil, name: String? = nil, beginTime: String? = nil, endTime: String? = nil, deleteFlag: Int? = nil, success: @escaping SCSuccessModelHandler<SCNetResponseConsumablesSectionModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        var param: [String: Any] = [:]
        param["productClassifyId"] = productClassifyId
        self.httpService.request(api: .getConsumablesList, params: param) { [weak self] response in
            self?.parseModelResponse(response: response, success: success, failure: failure)
        }
    }
    
    public func getUploadAccessRequest(directory: String, serviceType: SCSmartNetHttpUploadServiceType, isCache: Bool = false, success: @escaping SCSuccessModelHandler<SCNetResponseUploadAccessModel>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let param: [String: Any] = ["dir": directory, "district": self.config.zone, "serviceType": serviceType.rawValue, "tenantId": self.config.tenantId]
        var api = SCSmartHttpServiceApi.getUploadAccessForForeign
        if self.config.zone == "CHN" {
            api = .getUploadAccessForChina
        }
        self.httpService.request(api: api, params: param, isCache: isCache) { [weak self] response in
            self?.parseModelResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// 上传文件
    /// - Parameters:
    ///   - directory: 路径
    ///   - serviceType: 文件类型
    ///   - data: 文件数据
    ///   - progress: 进度回调
    ///   - success: 成功回调
    ///   - failure: 失败回调
    func uploadData(directory: String, serviceType: SCSmartNetHttpUploadServiceType, data: Data, progress: @escaping SCProgressHandler, success: @escaping SCSuccessString, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let uploadBlock: ((SCNetResponseUploadAccessModel) -> Void) = { [weak self] model in
            guard let `self` = self else { return }
            if data.count == 0 { return }
            if self.config.zone == "CHN" {
                self.httpService.uploadDataByAliyun(accessId: model.accessId, secret: model.secret, endPoint: model.endPoint, bucketName: model.bucket, objectKey: directory, expirationTimeInGMTFormat: model.expirationTime, data: data, progress: progress, success: success) { error in
                    failure(SCSmartNetworkingError(code: -1))
                }
            }
            else {
                self.httpService.uploadDataByAmazon(accessId: model.accessId, secret: model.secret, endPoint: model.endPoint, bucketName: model.bucket, objectKey: directory, contentType: serviceType.mimeTypeByFileName, expirationTimeInGMTFormat: model.expirationTime, data: data, progress: progress, success: success) { error in
                    failure(SCSmartNetworkingError(code: -1))
                }
            }
        }
        
        if let model = self.uploadAccessModels[directory] {
            let time = TimeInterval(model.expirationTimeInGMTFormat) ?? 0
            if Date().timeIntervalSince1970 < time {
                uploadBlock(model)
                return
            }
        }
        
        let startTime = Date().timeIntervalSince1970
        self.getUploadAccessRequest(directory: directory, serviceType: serviceType) { model in
            if let model = model {
                model.expirationTimeInGMTFormat = String(UInt64(startTime) + (UInt64(model.expirationTime) ?? 0))
                self.uploadAccessModels[directory] = model
                uploadBlock(model)
            }
            else {
                failure(SCSmartNetworkingError(code: -1))
            }
        } failure: { error in
            failure(error)
        }
    }
    
    func uploadFile(directory: String, serviceType: SCSmartNetHttpUploadServiceType, dataFileURL: URL, progress: @escaping SCProgressHandler, success: @escaping SCSuccessString, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        let uploadBlock: ((SCNetResponseUploadAccessModel) -> Void) = { [weak self] model in
            guard let `self` = self else { return }
            if self.config.zone == "CHN" {
                self.httpService.uploadFileByAliyun(accessId: model.accessId, secret: model.secret, endPoint: model.endPoint, bucketName: model.bucket, objectKey: directory, expirationTimeInGMTFormat: model.expirationTimeInGMTFormat, dataFileURL: dataFileURL, progress: progress, success: success) { error in
                    failure(SCSmartNetworkingError(code: -1))
                }
            }
        }
        
        if let model = self.uploadAccessModels[directory] {
            let time = TimeInterval(model.expirationTimeInGMTFormat) ?? 0
            if Date().timeIntervalSince1970 < time {
                uploadBlock(model)
                return
            }
        }
        
        let startTime = Date().timeIntervalSince1970
        let path = (directory as NSString).substring(to: directory.count - (directory.components(separatedBy: "/").last ?? "").count)
        self.getUploadAccessRequest(directory: path, serviceType: serviceType) { model in
            if let model = model {
                model.expirationTimeInGMTFormat = String(UInt64(startTime) + (UInt64(model.expirationTime) ?? 0))
                self.uploadAccessModels[directory] = model
                uploadBlock(model)
            }
            else {
                failure(SCSmartNetworkingError(code: -1))
            }
        } failure: { error in
            failure(error)
        }

    }
    
    func download(url: String, outFilePath: String? = nil, needBackgroundDownload: Bool = false, progress: @escaping SCProgressHandler, success: @escaping SCSuccessData, failure: @escaping SCFailureError) {
        self.httpService.download(url: url, outFilePath: outFilePath, params: nil, needBackgroundDownload: needBackgroundDownload, progress: progress, success: success, failure: failure)
    }
    
    func downloadByOssOrAws(direction: String, serviceType: SCSmartNetHttpUploadServiceType, progress: @escaping SCProgressHandler, success: @escaping SCSuccessData, failure: @escaping SCFailureError) {
        
        let downloadBlock: ((SCNetResponseUploadAccessModel) -> Void) = { [weak self] model in
            guard let `self` = self else { return }
            var url: String = ""
            if self.config.zone == "CHN" {
                url = "https://" + model.bucket + "." + model.endPoint + "/" + direction
                
            }
            else {
                url = ""
            }
//            self.download(url: url, outFilePath: outFilePath, needBackgroundDownload: needBackgroundDownload, progress: progress, success: success, failure: failure)
            
            if self.config.zone == "CHN" {
                self.httpService.downloadByAliyun(accessId: model.accessId, secret: model.secret, endPoint: model.endPoint, bucketName: model.bucket, objectKey: direction, expirationTimeInGMTFormat: model.expirationTime, progress: progress, success: success, failure: failure)
            }
            else {
                
            }
        }
        
        if let model = self.uploadAccessModels[direction] {
            let time = TimeInterval(model.expirationTimeInGMTFormat) ?? 0
            if Date().timeIntervalSince1970 < time {
                downloadBlock(model)
                return
            }
        }
        
        let startTime = Date().timeIntervalSince1970
        self.getUploadAccessRequest(directory: direction, serviceType: serviceType) { model in
            if let model = model {
                model.expirationTimeInGMTFormat = String(UInt64(startTime) + (UInt64(model.expirationTime) ?? 0))
                self.uploadAccessModels[direction] = model
                downloadBlock(model)
            }
            else {
                failure(NSError() as Error)
            }
        } failure: { error in
            failure(NSError() as Error)
        }

    }
}

extension SCSmartNetworking {
    /// 解析解析SCSmartNetHttpServiceResponse数据，直接回调，不需要传参
    private func parseNormalResponse(response: SCSmartNetHttpServiceResponse, success: @escaping SCSuccessHandler, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        if response.code == 0 {
            success()
        }
        else if let error = response.error {
            failure(error)
        }
    }
    
    /// 解析SCSmartNetHttpServiceResponse数据，转为遵守协议SCNetResponseModelProtocol的T对象
    private func parseModelResponse<T: SCNetResponseModelProtocol>(response: SCSmartNetHttpServiceResponse, success: @escaping SCSuccessModelHandler<T>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        if response.code == 0 {
            let result = response.json?["result"] as? [String: Any]
            if result == nil {
                success(nil)
                return
            }
            let model = T.serialize(json: result) as? T
            success(model)
        }
        else if let error = response.error {
            failure(error)
        }
    }
    
    /// 解析SCSmartNetHttpServiceResponse数据，转为T类型
    private func parseAnyResponse<T>(response: SCSmartNetHttpServiceResponse, success: @escaping SCSuccessModelHandler<T>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        if response.code == 0 {
            let result = response.json?["result"] as? T
            success(result)
        }
        else if let error = response.error {
            failure(error)
        }
    }
    
    /// 解析SCSmartNetHttpServiceResponse数据，转为遵守协议SCNetResponseModelProtocol的对象为元素的数组
    private func parseModelArrayResponse<T: SCNetResponseModelProtocol>(response: SCSmartNetHttpServiceResponse, success: @escaping SCSuccessModelArrayHandler<T>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        if response.code == 0 {
            let result = response.json?["result"] as? [[String: Any]]
            let list = T.serialize(jsonArray: result ?? []) as? [T]
            success(list ?? [])
        }
        else if let error = response.error {
            failure(error)
        }
    }
    
    /// 解析SCSmartNetHttpServiceResponse数据，转为遵守协议SCNetResponseModelProtocol的对象为元素的数组
    private func parseModelArrayByListKeyResponse<T: SCNetResponseModelProtocol>(listKey: String, response: SCSmartNetHttpServiceResponse, success: @escaping SCSuccessModelArrayHandler<T>, failure: @escaping SCSmartNetHttpServiceFailureResponseBlock) {
        if response.code == 0 {
            let result = response.json?["result"] as? [String: Any]
            let listJson = result?[listKey] as? [[String: Any]]
            let list = T.serialize(jsonArray: listJson ?? []) as? [T]
            success(list ?? [])
        }
        else if let error = response.error {
            failure(error)
        }
    }
}

extension SCSmartNetworking {
    func unsubscribeAll() {
        self.deviceService.unsubscribeAll()
    }
    
    /// 设置设备产品ID、sn
    /// - Parameters:
    ///   - productId: 产品ID
    ///   - sn: sn
    func setDevice(productId: String, sn: String) {
        self.deviceService.set(productId: productId, sn: sn)
    }
    
    /// 设置设备属性
    /// - Parameters:
    ///   - message: 消息体
    ///   - callback: 回调
    func setDeviceProperty(message: [String: Any], callback: SCSmartNetDeviceServiceBlock?) {
        self.deviceService.setProperty(nil, message: message, callback: callback)
    }
    
    /// 获取设备属性
    /// - Parameters:
    ///   - message: 消息体
    ///   - callback: 回调
    func getDeviceProperty(message: [String: Any], callback: SCSmartNetDeviceServiceBlock?) {
        self.deviceService.getProperty(nil, message: message, callback: callback)
    }

    /// 设置设备服务
    /// - Parameters:
    ///   - identifer: 服务类型
    ///   - message: 消息体
    ///   - callback: 回调
    func setDeviceService(identifer: String, message: [String: Any], callback: SCSmartNetDeviceServiceBlock?) {
        self.deviceService.setService(nil, identifer: identifer, message: message, callback: callback)
    }
    
    /// 订阅设备属性推送
    /// - Parameter callback: 回调
    func subscribeDevicePropertyPush(callback: SCSmartNetDeviceServicePropertyPushBlock?) {
        self.deviceService.subscribePropertyPush(callback: callback)
    }
    
    
//    /// 发送设备消息
//    /// - Parameter data: Data类型数据
//    func sendDeviceMessage(data: Data) {
//        self.deviceService.send(data: data)
//    }
//
//    /// 发送设备消息
//    /// - Parameter message: json类型数据
//    func sendDeviceMessage(message: [String: Any]) {
//        self.deviceService.send(message: message)
//    }
}


extension SCSmartNetworking: SCSmartNetAddressDelegate {
    func serviceAddressChanged(domain: SCNetResponseDomainModel?) {
        guard let domain = domain else { return }
        self.privateDomain = domain
        self.httpService.set(baseUrl: domain.appApiUrl)
        self.deviceService.set(mqttHost: domain.mqttHost, mqttPort: domain.mqttPort)
        
        #if DEBUG
        if domain.appApiUrl.count == 0 {
            self.httpService.set(baseUrl: "https://test-sz-cn-apiaiot.3irobotix.net")
        }
        #endif
    }
}

extension SCSmartNetworking {
    @objc private func reachabilityStatusChangedNotification() {
        if SCNetworkReachabilityManager.shared.isReachable {
            self.deviceService.reconnect()
            
            if self.adderssService.isRequesting {
                self.adderssService.startRequestAdress()
            }
        }
    }
}
