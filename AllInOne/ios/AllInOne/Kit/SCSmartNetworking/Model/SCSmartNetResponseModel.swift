//
//  SCSmartNetResponseModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/8.
//

import UIKit
import ObjectMapper

/// 成功回调，参数为泛型
typealias SCSmartNetSuccessResponseBlock<T> = ((T?) -> Void)

/// 存储用户信息
fileprivate var kSCNetUserModelKey: String = "kSCNetUserModelKey"

/*
 网络请求响应模型协议
 */
protocol SCNetResponseModelProtocol {
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol?
    static func serialize(jsonArray: [[String: Any]]) -> [SCNetResponseModelProtocol]
}

extension SCNetResponseModelProtocol {
    static func serialize(jsonArray: [[String: Any]]) -> [SCNetResponseModelProtocol] { return [] }
}

/*
 基础模型
 */
public struct SCNetResponseBasicModel: Mappable, SCNetResponseModelProtocol {
    /// 响应code
    var code: Int = 0
    /// 消息
    var msg: String = ""
    /// body数据
    var result: Any?
    
    public init?(map: Map) { }
    
    mutating public func mapping(map: Map) {
        code <- map["code"]
        msg <- map["msg"]
        result <- map["result"]
    }
    
    static func serialize(json: [String : Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseBasicModel>().map(JSON: json ?? [:])
    }
}

/*
 基础模型
 */
public struct SCNetResponseDomainModel: Mappable, Equatable {
    var mqttHost: String = ""
    var mqttPort: Int = 0
    var gaMqttHost: String = ""
    var gaMqttPort: Int = 0
    var mapCdnHost: String = ""
    var mapCdnPort: Int = 0
    
    var appApiUrl: String = ""
    var appCdnUrl: String = ""
    var appLogUrl: String = ""
    
    var deviceApiHost: String = ""
    var deviceApiPort: Int = 0
    var deviceOtaHost: String = ""
    var deviceOtaPort: Int = 0
    var deviceLogHost: String = ""
    var deviceLogPort: Int = 0
    
    public init() { }
    
    public init?(map: Map) { }
    
    mutating public func mapping(map: Map) {
        let mqtt = (map.JSON["MQTT"] as? String) ?? ""
        if let (host, port) = self.getHostAndPort(string: mqtt) {
            self.mqttHost = host
            self.mqttPort = port
        }
        
        let gaMqtt = (map.JSON["MQTT_ga"] as? String) ?? ""
        if let (host, port) = self.getHostAndPort(string: gaMqtt) {
            self.gaMqttHost = host
            self.gaMqttPort = port
        }
        
        let mapCdn = (map.JSON["MAP_cdn"] as? String) ?? ""
        if let (host, port) = self.getHostAndPort(string: mapCdn) {
            self.mapCdnHost = host
            self.mapCdnPort = port
        }
        
        appApiUrl <- map["APP_api"]
        appCdnUrl <- map["APP_cdn"]
        appLogUrl <- map["APP_log"]
        
        if appApiUrl.components(separatedBy: ":").last == "80" {
            appApiUrl = appApiUrl.components(separatedBy: ":").first ?? appApiUrl
        }
                
        if appApiUrl.count > 0 && !appApiUrl.hasPrefix("http") {
            appApiUrl = "https://" + appApiUrl
        }
        if appCdnUrl.count > 0 && !appCdnUrl.hasPrefix("http") {
            appCdnUrl = "https://" + appCdnUrl
        }
        if appLogUrl.count > 0 && !appLogUrl.hasPrefix("http") {
            appLogUrl = "https://" + appLogUrl
        }
        
        let deviceApi = (map.JSON["DEV_api"] as? String) ?? ""
        if let (host, port) = self.getHostAndPort(string: deviceApi) {
            self.deviceApiHost = host
            self.deviceApiPort = port
        }
        
        let deviceOta = (map.JSON["DEV_ota"] as? String) ?? ""
        if let (host, port) = self.getHostAndPort(string: deviceOta) {
            self.deviceOtaHost = host
            self.deviceOtaPort = port
        }
        
        let deviceLog = (map.JSON["dev_log"] as? String) ?? ""
        if let (host, port) = self.getHostAndPort(string: deviceLog) {
            self.deviceLogHost = host
            self.deviceLogPort = port
        }
    }
    
    static func serialize(json: [String : Any]?) -> SCNetResponseDomainModel? {
        return Mapper<SCNetResponseDomainModel>().map(JSON: json ?? [:])
    }
    
    private func getHostAndPort(string: String) -> (String, Int)? {
        if string.count == 0 {
            return nil
        }
        var text = string
        if string.components(separatedBy: "://").count == 2 {
            text = string.components(separatedBy: "://").last!
        }
        let subs = text.components(separatedBy: ":")
        if subs.count >= 2 {
            var port = Int(subs.last!) ?? 0
            if port == 80 || port == 443 {
                port = 443
            }
            let host = (text as NSString).substring(to: text.count - subs.last!.count - 1)
            return (host, port)
        }
        else {
            return (text, 0)
        }
    }
    
    public static func == (lhs: SCNetResponseDomainModel, rhs: SCNetResponseDomainModel) -> Bool {
        return lhs.mqttHost == rhs.mqttHost
        && lhs.mqttPort == rhs.mqttPort
        && lhs.gaMqttHost == rhs.gaMqttHost
        && lhs.gaMqttPort == rhs.gaMqttPort
        && lhs.mapCdnHost == rhs.mapCdnHost
        && lhs.mapCdnPort == rhs.mapCdnPort
        && lhs.appApiUrl == rhs.appApiUrl
        && lhs.appCdnUrl == rhs.appCdnUrl
        && lhs.appLogUrl == rhs.appLogUrl
        && lhs.deviceApiHost == rhs.deviceApiHost
        && lhs.deviceApiPort == rhs.deviceApiPort
        && lhs.deviceOtaHost == rhs.deviceOtaHost
        && lhs.deviceOtaPort == rhs.deviceOtaPort
        && lhs.deviceLogHost == rhs.deviceLogHost
        && lhs.deviceLogPort == rhs.deviceLogPort
    }
}

/*
 网络请求响应用户模型
 */
public struct SCNetResponseUserModel: Mappable, SCNetResponseModelProtocol {
    /// 客户端类型
    var clientType: String = ""
    /// 用户ID
    var id: String = ""
    /// 用户token
    var token: String = ""
    /// 连接类型
    var connectionType: String = ""
    var controlDevice: Int = 0
    /// APP语言
    var lang: String = ""
    /// 工程类型
    var projectType: String = ""
    var robotType: String = ""
    /// 租户ID
    var tenantId: String = ""
    /// 用户名
    var username: String = ""
    /// MQTT token
    var mqttToken: String = ""
    init() { }
    public init?(map: Map) { }
    mutating public func mapping(map: Map) {
        clientType <- map["clientType"]
        id <- map["id"]
        token <- map["data.AUTH"]
        connectionType <- map["data.CONNECTION_TYPE"]
        controlDevice <- map["data.CONTROL_DEVICE"]
        lang <- map["data.LANG"]
        projectType <- map["data.PROJECT_TYPE"]
        robotType <- map["data.ROBOT_TYPE"]
        tenantId <- map["data.TENANT_ID"]
        username <- map["data.USERNAME"]
        mqttToken <- map["data.EMQ_TOKEN"]
    }
    
    static func clear() {
        UserDefaults.standard.setValue(nil, forKey: kSCNetUserModelKey)
        UserDefaults.standard.synchronize()
    }
    
    /// JSON转模型
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        if json != nil {
            UserDefaults.standard.setValue(json!, forKey: kSCNetUserModelKey)
            UserDefaults.standard.synchronize()
        }
        return Mapper<SCNetResponseUserModel>().map(JSON: json ?? [:])
    }
    
    /// 本地加载用户模型
    static func loadLocalUser() -> SCNetResponseUserModel? {
        if let json = UserDefaults.standard.object(forKey: kSCNetUserModelKey) as? [String: Any] {
            return SCNetResponseUserModel.serialize(json: json) as? SCNetResponseUserModel
        }
        return nil
    }
}

/*
 网络请求响应用户信息模型
 */
public class SCNetResponseUserProfileModel: Mappable, SCNetResponseModelProtocol {
    /// 头像地址
    var avatarUrl: String = ""
    /// 邮箱
    var email: String = ""
    /// 昵称
    var nickname: String = ""
    /// 手机号
    var phone: String = ""
    
    // 绑定的设备数量
    var device: Int = 0
    
    public init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        avatarUrl <- map["avatarUrl"]
        email <- map["email"]
        nickname <- map["nickName"]
        phone <- map["phone"]
        device <- map["device"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseUserProfileModel>().map(JSON: json ?? [:])
    }
}

/*
 网络请求响应设备信息模型
 */
public struct SCNetResponseDeviceInfoModel: Mappable, SCNetResponseModelProtocol {
    /// 主键id
    var id: String = ""
    /// 登录IP
    var ip: String = ""
    /// 租户id
    var tenantId: String = ""
    /// 设备sn
    var sn: String = ""
    /// mac地址
    var mac: String = ""
    /// 设备昵称
    var nickname: String = ""
    /// 产品id
    var productId: String = ""
    /// 工程类型
    var projectType: String = ""
    /// 软件版本号
    var versions: String = ""
    /// 区域
    var zone: String = ""
    /// 最近离线时间
    var offlineTime: String = ""
    /// 最近在线时间
    var onlineTime: String = ""
    /// 最近登录的城市
    var city: String = ""
    /// 创建者
    var creator: String = ""
    /// 创建时间
    var createTime: String = ""
    /// 是否删除 0:正常 0以下的数：已删除
    var deleteFlag: Int = 0
    /// 更新者
    var updater: String = ""
    /// 修改时间
    var updateTime: String = ""
    /// 测试设备是否已重置：0已重置，1未重置
    var resetStatus: String = ""
    
    public init?(map: Map) { }
    mutating public func mapping(map: Map) {
        id <- map["id"]
        ip <- map["ip"]
        tenantId <- map["tenantId"]
        sn <- map["sn"]
        mac <- map["mac"]
        nickname <- map["nickname"]
        productId <- map["productId"]
        projectType <- map["projectType"]
        versions <- map["versions"]
        zone <- map["zone"]
        offlineTime <- map["offlineTime"]
        onlineTime <- map["onlineTime"]
        city <- map["city"]
        creator <- map["createBy"]
        createTime <- map["createTime"]
        deleteFlag <- map["deleteFlag"]
        updater <- map["updateBy"]
        updateTime <- map["updateTime"]
        resetStatus <- map["resetStatus"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseDeviceInfoModel>().map(JSON: json ?? [:])
    }
}

/*
 网络请求响应共享信息模型
 */
public class SCNetResponseShareInfoModel: Mappable, SCNetResponseModelProtocol {
    /// 主键id
    var id: String = ""
    /// 被邀请人的用户id
    var beInviteId: String = ""
    /// 邀请者ID，与自己ID相同，表示自己是邀请方，不相同表示 是被邀请方
    var inviterId: String = ""
    /// 0-共享设备；1-共享家庭
    var type: Int = 0
    /// 设备id或家庭id
    var targetId: String = ""
    /// 0-正常->待确认；1-已同意；2-已拒绝
    var status: Int = 0
    /// 设备昵称或家庭名称
    var name: String = ""
    /// 图片地址,共享家庭则为共享人图片，共享设备则为设备的图片
    var imageUrl: String = ""
    /// 用户名,当前用户为分享者，则用户名为接受分享者的用户名(分享给:xxx)；当前用户为接受分享者，则用户名为分享者的用户名（来自:xxx）
    var username: String = ""
    /// 设备sn
    var sn: String = ""
    /// 设备mac
    var mac: String = ""
    /// 产品型号名称
    var modeType: String = ""
    /// 产品型号代码
    var productModeCode: String = ""
    /// 租户id
    var tenantId: String = ""
    /// 创建者
    var createBy: String = ""
    /// 创建时间
    var createTime: String = ""
    /// 是否删除（0：正常；低于0的数字：已删除）
    var deleteFlag: String = ""
    /// 修改人
    var updateBy: String = ""
    /// 修改时间
    var updateTime: String = ""
    /// 区域
    var zone: String = ""
    /// 删除 1-邀请者删除；2-被邀请者删除
    var removed: Int = 0
    
    init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        id <- map["id"]
        beInviteId <- map["beInviteId"]
        inviterId <- map["inviteId"]
        type <- map["type"]
        targetId <- map["targetId"]
        status <- map["status"]
        name <- map["name"]
        imageUrl <- map["phoneUrl"]
        username <- map["username"]
        sn <- map["sn"]
        mac <- map["mac"]
        modeType <- map["modeType"]
        productModeCode <- map["productModeCode"]
        tenantId <- map["tenantId"]
        createBy <- map["createBy"]
        createTime <- map["createTime"]
        deleteFlag <- map["deleteFlag"]
        updateBy <- map["updateBy"]
        updateTime <- map["updateTime"]
        zone <- map["zone"]
        removed <- map["removed"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseShareInfoModel>().map(JSON: json ?? [:])
    }
    
    static func serialize(jsonArray: [[String: Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseShareInfoModel>().mapArray(JSONArray: jsonArray)
    }
}

/*
 网络请求响应共享历史模型
 */
public class SCNetResponseShareHistoryModel: Mappable, SCNetResponseModelProtocol {
    var current: Int = 0
    var pages: Int = 0
    var size: Int = 0
    var total: Int = 0
    var items: [SCNetResponseShareInfoModel] = []
    
    init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        current <- map["current"]
        pages <- map["pages"]
        size <- map["size"]
        total <- map["total"]
        items <- map["records"]
        
        if total == 0 {
            total = Int((map.JSON["total"] as? String) ?? "0") ?? 0
        }
    }
    
    static func serialize(json: [String : Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseShareHistoryModel>().map(JSON: json ?? [:])
    }
}

/*
 网络请求响应设备模型
 */
public class SCNetResponseDeviceModel: Mappable, SCNetResponseModelProtocol {
    /// 产品ID
    var productId: String = ""
    /// 设备ID
    var deviceId: String = ""
    /// 设备sn
    var sn: String = ""
    /// mac地址
    var mac: String = ""
    /// 绑定时间
    var bindTime: String = ""
    var ctrTime: String = ""
    /// 协议版本
    var ctrVersion: String = ""
    /// 是否为默认设备
    var isDefault: Bool = false
    ///
    var modeType: String = ""
    /// 昵称
    var nickname: String = ""
    /// 所有者
    var owner: String = ""
    ///
    var powerValue: Int = 0
    /// 工程类型
    var projectType: String = ""
    /// 软件版本
    var softVersion: String = ""
    var stats: String = ""
    var status: Int = 0
    var userId: String = ""
    var versions: String = ""
        
    //房间ID
    var roomId: String = ""
    //分享状态 0：未 1:已分享
    var shareStatus: String = ""
    
    //用户名
    var username: String = ""
    
    //邀请人id
    var inviteId: String = ""
    
    //产品型号代码
    var productModeCode: String = ""
    
    //分享id
    var id: String = ""
    
    //共享列表的icon
    var phoneUrl: String = ""
    
    //设备列表的icon
    var photoUrl: String = ""
 
    public init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        productId <- map["productId"]
        deviceId <- map["deviceId"]
        sn <- map["sn"]
        mac <- map["mac"]
        bindTime <- map["bindTime"]
        ctrTime <- map["ctrTime"]
        ctrVersion <- map["ctrVersion"]
        isDefault <- map["default"]
        modeType <- map["modeType"]
        nickname <- map["nickname"]
        owner <- map["owner"]
        powerValue <- map["powerValue"]
        projectType <- map["projectType"]
        softVersion <- map["softVersion"]
        stats <- map["stats"]
        status <- map["status"]
        userId <- map["userId"]
        versions <- map["versions"]
        roomId <- map["roomId"]
        shareStatus <- map["shareStatus"]
        username <- map["username"]
        inviteId <- map["inviteId"]
        productModeCode <- map["productModeCode"]
        id <- map["id"]
        phoneUrl <- map["phoneUrl"]
        photoUrl <- map["photoUrl"]
      
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseDeviceModel>().map(JSON: json ?? [:])
    }
    
    static func serialize(jsonArray: [[String: Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseDeviceModel>().mapArray(JSONArray: jsonArray)
    }
}

/*
 网络请求响应产品类型列表父模型
 */
public class SCNetResponseProductTypeParentModel: Mappable, SCNetResponseModelProtocol {
    var id: String = ""
    var createBy: String = ""
    var createTime: String = ""
    var deleteFlag: Int = 0
    var key: String = ""
    var name: String = ""
    var parentId: String = ""
    var photoUrl: String = ""
    var updateBy: String = ""
    var updateTime: String = ""
    var zone: String = ""
    
    var items: [SCNetResponseProductTypeMiddleModel] = []
    
    public init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        id <- map["id"]
        createBy <- map["createBy"]
        createTime <- map["createTime"]
        deleteFlag <- map["deleteFlag"]
        key <- map["key"]
        name <- map["name"]
        parentId <- map["parentId"]
        photoUrl <- map["photoUrl"]
        updateBy <- map["updateBy"]
        updateTime <- map["updateTime"]
        zone <- map["zone"]
        items <- map["children"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseProductTypeParentModel>().map(JSON: json ?? [:])
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseProductTypeParentModel>().mapArray(JSONArray: jsonArray)
    }
}

/*
 网络请求响应产品类型列表中间模型
 */
public class SCNetResponseProductTypeMiddleModel: Mappable, SCNetResponseModelProtocol {
    var id: String = ""
    var createBy: String = ""
    var createTime: String = ""
    var deleteFlag: Int = 0
    var key: String = ""
    var name: String = ""
    var parentId: String = ""
    var photoUrl: String = ""
    var updateBy: String = ""
    var updateTime: String = ""
    var zone: String = ""
    
//    var items: [SCNetResponseProductTypeChildModel] = []
    
    public init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        id <- map["id"]
        createBy <- map["createBy"]
        createTime <- map["createTime"]
        deleteFlag <- map["deleteFlag"]
        key <- map["key"]
        name <- map["name"]
        parentId <- map["parentId"]
        photoUrl <- map["photoUrl"]
        updateBy <- map["updateBy"]
        updateTime <- map["updateTime"]
        zone <- map["zone"]
//        items <- map["children"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseProductTypeMiddleModel>().map(JSON: json ?? [:])
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseProductTypeMiddleModel>().mapArray(JSONArray: jsonArray)
    }
}

///*
// 网络请求响应产品类型列表子模型
// */
//public class SCNetResponseProductTypeChildModel: Mappable, SCNetResponseModelProtocol {
//    var id: String = ""
//    var createBy: String = ""
//    var createTime: String = ""
//    var deleteFlag: Int = 0
//    var key: String = ""
//    var name: String = ""
//    var parentId: String = ""
//    var photoUrl: String = ""
//    var updateBy: String = ""
//    var updateTime: String = ""
//    var zone: String = ""
//    var items: [SCNetResponseProductTypeChildModel] = []
//    
//    var ssidPrefix: String = ""
//    var deviceUuid: String = ""
//    
//    /// 是否支持蓝牙
//    var supportBluetooth: Bool = false
//    
//    public init() {}
//    required public init?(map: Map) { }
//    public func mapping(map: Map) {
//        id <- map["id"]
//        createBy <- map["createBy"]
//        createTime <- map["createTime"]
//        deleteFlag <- map["deleteFlag"]
//        key <- map["key"]
//        name <- map["name"]
//        parentId <- map["parentId"]
//        photoUrl <- map["photoUrl"]
//        updateBy <- map["updateBy"]
//        updateTime <- map["updateTime"]
//        zone <- map["zone"]
//        items <- map["children"]
//    }
//    
//    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
//        return Mapper<SCNetResponseProductTypeChildModel>().map(JSON: json ?? [:])
//    }
//    
//    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
//        return Mapper<SCNetResponseProductTypeChildModel>().mapArray(JSONArray: jsonArray)
//    }
//}

/*
 网络请求响应产品类型列表子模型
 */
public class SCNetResponseProductInfoModel: Mappable, SCNetResponseModelProtocol {
    /// 通讯协议（1：WiFi-蓝牙，2：Wi-Fi，3：蓝牙）
    var communicationProtocol: Int = 0
    /// 主键
    var id: String = ""
    /// 创建者
    var createBy: String = ""
    /// 创建时间
    var createTime: String = ""
    /// 0：正常；低于0的数字：已删除
    var deleteFlag: Int = 0
    /// 说明
    var describe: String = ""
    /// 设备数量
    var deviceNum: String = ""
    /// 配网步骤
    var distributionNetworkStep: String = ""
    /// 设备蓝牙或热点名称前缀（由2-16位的数字或字母组成）
    var dmsPrefix: String = ""
    /// 配网引导说明
    var guideDesc: String = ""
    /// 配网引导标题
    var guideTitle: String = ""
    /// 配网引导图片
    var guideUrl: String = ""
    /// 名称
    var name: String = ""
    /// 图片地址
    var photoUrl: String = ""
    /// 产品类别id
    var productClassifyId: String = ""
    /// 产品物模型模板id
    var produtThingModelTemplateId: String = ""
    /// 状态（0：开发中，1：测试中，2：已发布）
    var status: Int = 0
    /// 企业id
    var tenantId: String = ""
    /// 更新者
    var updateBy: String = ""
    /// 更新时间
    var updateTime: String = ""
    /// 区域
    var zone: String = ""
    
    public init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        communicationProtocol <- map["communicationProtocol"]
        createBy <- map["createBy"]
        createTime <- map["createTime"]
        deleteFlag <- map["deleteFlag"]
        describe <- map["describe"]
        deviceNum <- map["deviceNum"]
        distributionNetworkStep <- map["distributionNetworkStep"]
        dmsPrefix <- map["dmsPrefix"]
        guideDesc <- map["guideDesc"]
        guideTitle <- map["guideTitle"]
        guideUrl <- map["guideUrl"]
        id <- map["id"]
        name <- map["name"]
        photoUrl <- map["photoUrl"]
        productClassifyId <- map["productClassifyId"]
        produtThingModelTemplateId <- map["produtThingModelTemplateId"]
        status <- map["status"]
        tenantId <- map["tenantId"]
        updateBy <- map["updateBy"]
        updateTime <- map["updateTime"]
        zone <- map["zone"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseProductInfoModel>().map(JSON: json ?? [:])
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseProductInfoModel>().mapArray(JSONArray: jsonArray)
    }
}

/*
 网络请求响应产品列表模型
 */
public class SCNetResponseProductModel: Mappable, SCNetResponseModelProtocol {
    /// 通讯协议（1：WiFi-蓝牙，2：Wi-Fi，3：蓝牙）
    var communicationProtocol: Int = 0
    /// 主键
    var id: String = ""
    /// 创建者
    var createBy: String = ""
    /// 创建时间
    var createTime: String = ""
    /// 0：正常；低于0的数字：已删除
    var deleteFlag: Int = 0
    /// 说明
    var describe: String = ""
    /// 设备数量
    var deviceNum: String = ""
    /// 配网步骤
    var distributionNetworkStep: String = ""
    /// 设备蓝牙或热点名称前缀（由2-16位的数字或字母组成）
    var dmsPrefix: String = ""
    /// 配网引导说明
    var guideDesc: String = ""
    /// 配网引导标题
    var guideTitle: String = ""
    /// 配网引导图片
    var guideUrl: String = ""
    /// 名称
    var name: String = ""
    /// 图片地址
    var photoUrl: String = ""
    /// 产品类别id
    var productClassifyId: String = ""
    /// 产品物模型模板id
    var produtThingModelTemplateId: String = ""
    /// 状态（0：开发中，1：测试中，2：已发布）
    var status: Int = 0
    /// 企业id
    var tenantId: String = ""
    /// 更新者
    var updateBy: String = ""
    /// 更新时间
    var updateTime: String = ""
    /// 区域
    var zone: String = ""
    
    public init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        communicationProtocol <- map["communicationProtocol"]
        createBy <- map["createBy"]
        createTime <- map["createTime"]
        deleteFlag <- map["deleteFlag"]
        describe <- map["describe"]
        deviceNum <- map["deviceNum"]
        distributionNetworkStep <- map["distributionNetworkStep"]
        dmsPrefix <- map["dmsPrefix"]
        guideDesc <- map["guideDesc"]
        guideTitle <- map["guideTitle"]
        guideUrl <- map["guideUrl"]
        id <- map["id"]
        name <- map["name"]
        photoUrl <- map["photoUrl"]
        productClassifyId <- map["productClassifyId"]
        produtThingModelTemplateId <- map["produtThingModelTemplateId"]
        status <- map["status"]
        tenantId <- map["tenantId"]
        updateBy <- map["updateBy"]
        updateTime <- map["updateTime"]
        zone <- map["zone"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseProductModel>().map(JSON: json ?? [:])
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseProductModel>().mapArray(JSONArray: jsonArray)
    }
}

/*
 网络请求响应绑定结果模型
 */
public struct SCNetResponseBindAppResultModel: Mappable, SCNetResponseModelProtocol {
    var sn: String = ""
    var mac: String = ""
    var deviceId: String = ""
    var isNew: Bool = false
    var createTime: String = ""
    var ip: String = ""
    var nickname: String = ""
    var onlineTime: String = ""
    var productId: String = ""
    var productModeCode: String = ""
    var tenantId: String = ""
    var updateTime: String = ""
    var versions: String = ""
    
    public init?(map: Map) { }
    mutating public func mapping(map: Map) {
        sn <- map["sn"]
        mac <- map["mac"]
        deviceId <- map["deviceId"]
        isNew <- map["isNew"]
        createTime <- map["createTime"]
        ip <- map["ip"]
        nickname <- map["nickname"]
        onlineTime <- map["onlineTime"]
        productId <- map["productId"]
        productModeCode <- map["productModeCode"]
        tenantId <- map["tenantId"]
        updateTime <- map["updateTime"]
        versions <- map["versions"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseBindAppResultModel>().map(JSON: json ?? [:])
    }
}

/*
 网络请求响应FAQ type模型
 */
public struct SCNetResponseFaqTypeModel: Mappable, SCNetResponseModelProtocol {
    var label: String = ""
    var value: Any?
    
    public init?(map: Map) { }
    mutating public func mapping(map: Map) {
        label <- map["label"]
        value <- map["value"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseFaqTypeModel>().map(JSON: json ?? [:])
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseFaqTypeModel>().mapArray(JSONArray: jsonArray)
    }
}

/*
 网络请求响应FAQ模型
 */
public struct SCNetResponseFaqContentModel: Mappable, SCNetResponseModelProtocol {
    /// 型号代码
    var code: String = ""
    /// 创建者
    var creator: String = ""
    /// 创建时间
    var createTime: String = ""
    /// 删除，0-正常，-1为删除
    var deleteFlag: Int = 0
    /// 主键id
    var id: String = ""
    /// 型号名称
    var label: String = ""
    /// 语言
    var lang: String = ""
    /// 产品型号id
    var productModeId: String = ""
    /// 问题
    var question: String = ""
    /// 回答
    var result: String = ""
    /// 租户ID
    var tenantId: String = ""
    /// 类型ID
    var typeId: String = ""
    /// 更新者
    var updateBy: String = ""
    /// 更新时间
    var updateTime: String = ""
    /// 地区
    var zone: String = ""
    
    public init?(map: Map) { }
    mutating public func mapping(map: Map) {
        code <- map["code"]
        creator <- map["createBy"]
        createTime <- map["createTime"]
        deleteFlag <- map["deleteFlag"]
        id <- map["id"]
        label <- map["label"]
        lang <- map["lang"]
        productModeId <- map["productModeId"]
        question <- map["question"]
        result <- map["result"]
        tenantId <- map["tenantId"]
        typeId <- map["typeId"]
        updateBy <- map["updateBy"]
        updateTime <- map["updateTime"]
        zone <- map["zone"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseFaqContentModel>().map(JSON: json ?? [:])
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseFaqContentModel>().mapArray(JSONArray: jsonArray)
    }
}

/*
 网络请求响应FAQ信息模型
 */
public class SCNetResponseFaqsInfoModel: Mappable, SCNetResponseModelProtocol {
    var current: Int = 0
    var pages: Int = 0
    var size: Int = 0
    var total: Int = 0
    var items: [SCNetResponseFaqItemModel] = []
    
    init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        current <- map["current"]
        pages <- map["pages"]
        size <- map["size"]
        total <- map["total"]
        items <- map["records"]
        
        if total == 0 {
            total = Int((map.JSON["total"] as? String) ?? "0") ?? 0
        }
    }
    
    static func serialize(json: [String : Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseFaqsInfoModel>().map(JSON: json ?? [:])
    }
}

/*
 网络请求响应FAQ模型
 */
public struct SCNetResponseFaqItemModel: Mappable, SCNetResponseModelProtocol {
    /// 创建者
    var createBy: String = ""
    /// 创建时间
    var createTime: String = ""
    /// 删除，0-正常，-1为删除
    var deleteFlag: Int = 0
    /// 主键id
    var id: String = ""
    /// 语言
    var lang: String = ""
    /// 产品id
    var productId: String = ""
    /// 产品名称
    var productName: String = ""
    /// 问题
    var question: String = ""
    /// 回答
    var result: String = ""
    /// 租户id
    var tenantId: String = ""
    /// 类型id
    var typeId: String = ""
    /// 类型名称
    var typeName: String = ""
    /// 更新者
    var updateBy: String = ""
    /// 更新时间
    var updateTime: String = ""
    /// 地区
    var zone: String = ""
    
    public init?(map: Map) { }
    mutating public func mapping(map: Map) {
        createBy <- map["createBy"]
        createTime <- map["createTime"]
        deleteFlag <- map["deleteFlag"]
        id <- map["id"]
        lang <- map["lang"]
        productId <- map["productId"]
        productName <- map["productName"]
        question <- map["question"]
        result <- map["result"]
        tenantId <- map["tenantId"]
        typeId <- map["typeId"]
        typeName <- map["typeName"]
        updateBy <- map["updateBy"]
        updateTime <- map["updateTime"]
        zone <- map["zone"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseFaqItemModel>().map(JSON: json ?? [:])
    }
}


/*
 网络请求响应用户协议类型模型
 */
public struct SCNetResponseUserProtocolTypeModel: Mappable, SCNetResponseModelProtocol {
    var userProtocol: Int = 0
    var privacy: Int = 0
    
    public init?(map: Map) { }
    mutating public func mapping(map: Map) {
        userProtocol <- map["user"]
        privacy <- map["private"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseUserProtocolTypeModel>().map(JSON: json ?? [:])
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseUserProtocolTypeModel>().mapArray(JSONArray: jsonArray)
    }
}

/*
 网络请求响应用户协议内容模型
 */
public struct SCNetResponseUserProtocolContentModel: Mappable, SCNetResponseModelProtocol {
    var label: String = ""
    var value: Any?
    
    public init?(map: Map) { }
    mutating public func mapping(map: Map) {
        label <- map["label"]
        value <- map["value"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseUserProtocolContentModel>().map(JSON: json ?? [:])
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseUserProtocolContentModel>().mapArray(JSONArray: jsonArray)
    }
}

/*
 网络请求响应产品说明书模型
 */
public struct SCNetResponseProductManualModel: Mappable, SCNetResponseModelProtocol {
    var label: String = ""
    var value: Any?
    
    public init?(map: Map) { }
    mutating public func mapping(map: Map) {
        label <- map["label"]
        value <- map["value"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseProductManualModel>().map(JSON: json ?? [:])
    }
}
//SCMineConsumableModel
/*
 网络请求响应家庭耗材模型
 */
public class SCMineConsumableModel: Mappable, SCNetResponseModelProtocol {
    var consumablesList: [SCMineConsumableModelSon] = []
    
    var title: String = ""
    var subTitle: String = ""
    var deviceId: String = ""
    var nickname: String = ""
    var owner: String = ""
    var productId: String = ""
    var roomId: String = ""
    var roomName: String = ""
        var cornerRadiusTop: Bool = false
        var cornerRadiusBottom: Bool = false

    
    init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        consumablesList <- map["consumablesList"]
        deviceId <- map["deviceId"]
        
        title <- map["title"]
        subTitle <- map["subTitle"]
        
        nickname <- map["nickname"]
        owner <- map["owner"]
        productId <- map["productId"]
        roomId <- map["roomId"]
        roomName <- map["roomName"]
        cornerRadiusTop <- map["cornerRadiusTop"]
        cornerRadiusBottom <- map["cornerRadiusBottom"]
       
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCMineConsumableModel>().map(JSON: json ?? [:])
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCMineConsumableModel>().mapArray(JSONArray: jsonArray)
    }
}


//SCMineConsumableModelSon
/*
 网络请求响应家庭耗材子模型
 */
public class SCMineConsumableModelSon: Mappable, SCNetResponseModelProtocol {
 
    var balance: Int = 0
    var consumablesId: String = ""
    var consumablesImgUrl: String = ""
    var consumablesName: String = ""
   

    
    init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        balance <- map["balance"]
        consumablesId <- map["consumablesId"]
        consumablesImgUrl <- map["consumablesImgUrl"]
        consumablesName <- map["consumablesName"]
      
       
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCMineConsumableModelSon>().map(JSON: json ?? [:])
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCMineConsumableModelSon>().mapArray(JSONArray: jsonArray)
    }
}

/*
 网络请求响应家庭模型
 */
public class SCNetResponseFamilyModel: Mappable, SCNetResponseModelProtocol {
    var address: String = ""
    var city: String = ""
    var country: String = ""
    var createTime: String = ""
    var creatorId: String = ""
    var deleteFlag: String = ""
    var deviceNum: String = ""
    var name: String = ""
    var headUrl: String = ""
    var id: String = ""
    var latitude: Float = 0
    var longitude: Float = 0
    var memberNum: String = ""
    var tenantId: String = ""
    var updateTime: String = ""
    var roomNum: String = ""
    var isSelecteds: Bool = false
    var rooms: [SCNetResponseFamilyRoomModel] = []
    
    init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        address <- map["address"]
        city <- map["city"]
        country <- map["country"]
        createTime <- map["createTime"]
        creatorId <- map["creatorId"]
        deleteFlag <- map["deleteFlag"]
        deviceNum <- map["deviceNum"]
        name <- map["familyName"]
        headUrl <- map["headUrl"]
        id <- map["id"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        memberNum <- map["memberNum"]
        tenantId <- map["tenantId"]
        updateTime <- map["updateTime"]
        rooms <- map["roomDeviceInfoVoList"]
        roomNum <- map["roomNum"]
        isSelecteds <- map["isSelecteds"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseFamilyModel>().map(JSON: json ?? [:])
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseFamilyModel>().mapArray(JSONArray: jsonArray)
    }
}

/*
 网络请求响应家庭房间模型
 */
public class SCNetResponseFamilyRoomModel: Mappable, SCNetResponseModelProtocol {
    var id: String = ""
    var roomName: String = ""
    var deviceNum: Int = 0
    var deviceIds: [String] = []
    var devices: [SCNetResponseDeviceModel] = []
    var creatorId: String = ""
    var roomSequence: Int = 0
    var roomSortWeight: Int = 0
    /// 房间类型(0、普通房间，1、常用，-1、不显示)
    var roomType: Int = 0
    var tenantId: String = ""
    var updateId: String = ""
    var updateTime: String = ""
    
    init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        id <- map["id"]
        if id.count == 0 {
            id <- map["roomId"]
        }
        roomName <- map["roomName"]
        deviceNum <- map["deviceNum"]
        deviceIds <- map["deviceIds"]
        devices <- map["bindDeviceInfoVos"]
        creatorId <- map["creatorId"]
        roomSequence <- map["roomSequence"]
        roomSortWeight <- map["roomSortWeight"]
        tenantId <- map["tenantId"]
        updateId <- map["updateId"]
        updateTime <- map["updateTime"]
        
        let typeString = map.JSON["roomType"] as? String
        roomType = Int(typeString ?? "") ?? 0
        
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseFamilyRoomModel>().map(JSON: json ?? [:])
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseFamilyRoomModel>().mapArray(JSONArray: jsonArray)
    }
}

/*
 家庭所有成员信息
 */
public class SCNetResponseFamilyMembersInfoModel: Mappable, SCNetResponseModelProtocol {
    var current: Int = 0
    var pages: Int = 0
    var size: Int = 0
    var total: Int = 0
    /// 成员列表
    var members: [SCNetResponseFamilyMemberModel] = []
    
    init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        current <- map["current"]
        pages <- map["pages"]
        size <- map["size"]
        total <- map["total"]
        members <- map["records"]
        
        if total == 0 {
            total = Int((map.JSON["total"] as? String) ?? "0") ?? 0
        }
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseFamilyMembersInfoModel>().map(JSON: json ?? [:])
    }
}

/*
 网络请求响应家庭成员模型
 */
public class SCNetResponseFamilyMemberModel: Mappable, SCNetResponseModelProtocol {
    /// 家庭ID
    var familyId: String = ""
    /// 用户ID
    var userId: String = ""
    /// 分享表主键id，确认是那一条分享记录
    var shareId: String = ""
    /// 身份（0、管理员,1、普通成员,2、共享成员 ,3、待确认成员）
    var identity: Int = 0
    /// 用户昵称
    var nickname: String = ""
    /// 用户头像
    var headUrl: String = ""
    
    init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        familyId <- map["familyId"]
        userId <- map["userId"]
        shareId <- map["shareId"]
        identity <- map["identity"]
        nickname <- map["nickName"]
        headUrl <- map["headUrl"]
        
        let identityString = map.JSON["identity"] as? String
        identity = Int(identityString ?? "") ?? 0
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseFamilyMemberModel>().map(JSON: json ?? [:])
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseFamilyMemberModel>().mapArray(JSONArray: jsonArray)
    }
}

public struct SCNetResponseFamilyShareModel: Mappable, SCNetResponseModelProtocol {
    /// 家庭ID
    var familyId: String = ""
    /// 用户ID
    var userId: String = ""
    /// 分享表主键id，确认是那一条分享记录
    var shareId: String = ""
    /// 身份（0、管理员,1、普通成员,2、共享成员 ,3、待确认成员）
    var identify: String = ""
    /// 用户昵称
    var nickname: String = ""
    /// 用户头像
    var headUrl: String = ""
    
    public init?(map: Map) { }
    mutating public func mapping(map: Map) {
        familyId <- map["familyId"]
        userId <- map["userId"]
        shareId <- map["shareId"]
        identify <- map["identity"]
        nickname <- map["nickName"]
        headUrl <- map["headUrl"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseFamilyShareModel>().map(JSON: json ?? [:])
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseFamilyShareModel>().mapArray(JSONArray: jsonArray)
    }
}

//
public struct SCNetResponseFeedbackMainModel: Mappable, SCNetResponseModelProtocol {
    /// 当前页
    var current: String = ""
    /// 一页返回多少条数据
    var size: String = ""
    /// 总页数
    var total: Int = 0
    
    var hitCount: String = ""
    var isSearchCount: String = ""
    var optimizeCountSql: String = ""
    
    
    ///
    var records: [SCNetResponseFeedbackModel] = []
    
    ///
    var orders: [SCNetResponseFeedbackOrdersModel] = []
   
    
    public init?(map: Map) { }
    mutating public func mapping(map: Map) {
        current <- map["current"]
        size <- map["size"]
        total <- map["total"]
        
        hitCount <- map["hitCount"]
        isSearchCount <- map["isSearchCount"]
        optimizeCountSql <- map["optimizeCountSql"]
        
        records <- map["records"]
        orders <- map["orders"]
       
        if total == 0 {
            total = Int((map.JSON["total"] as? String) ?? "0") ?? 0
        }
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseFeedbackMainModel>().map(JSON: json ?? [:])//SCNetResponseFeedbackModel
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseFeedbackMainModel>().mapArray(JSONArray: jsonArray)
    }
}

public struct SCNetResponseFeedbackOrdersModel: Mappable, SCNetResponseModelProtocol {
    ///
    var asc: Bool = false
    ///
    var column: String = ""
   
    
    public init?(map: Map) { }
    mutating public func mapping(map: Map) {
        asc <- map["asc"]
        column <- map["column"]
      
       
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseFeedbackOrdersModel>().map(JSON: json ?? [:])//SCNetResponseFeedbackModel
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseFeedbackOrdersModel>().mapArray(JSONArray: jsonArray)
    }
}


public struct SCNetResponseFeedbackModel: Mappable, SCNetResponseModelProtocol {
    /// 回答
    var answer: String = ""
    /// 创建者 用户ID
    var createBy: String = ""
    /// 创建时间
    var createTime: String = ""
    /// 是否删除 0:正常 0以下的数：已删除
    var deleteFlag: String = ""
    /// 设备id， 必填
    var productId: String = ""
    /// 主键ID
    var id: String = ""
    /// 联系方式,必填
    var phone: String = ""
    /// 问题内容，必填
    var question: String = ""
    /// 问题类型。必填，若type为设备，则为设备名称（绑定关系的昵称）;若type为智能场景，则为智能场景；若type为账号，则为账号
    var questionType: String = ""
    /// 路由型号
    var routerModel: String = ""
    /// 租户ID
    var tenantId: String = ""
    /// 标题
    var title: String = ""
    /// 类型。设备、智能场景、账号。必填
    var type: String = ""
    /// 修改者
    var updateBy: String = ""
    /// 修改时间
    var updateTime: String = ""
    /// 文件存储路径
    var url: String = ""
    /// 用户id， 必填
    var userId: String = ""
    /// 区域
    var zone: String = ""
    
    public init?(map: Map) { }
    mutating public func mapping(map: Map) {
        answer <- map["answer"]
        createBy <- map["createBy"]
        createTime <- map["createTime"]
        deleteFlag <- map["deleteFlag"]
        productId <- map["productId"]
        id <- map["id"]
        phone <- map["phone"]
        question <- map["question"]
        questionType <- map["questionType"]
        routerModel <- map["routerModel"]
        tenantId <- map["tenantId"]
        title <- map["title"]
        type <- map["type"]
        updateBy <- map["updateBy"]
        updateTime <- map["updateTime"]
        url <- map["url"]
        userId <- map["userId"]
        zone <- map["zone"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseFeedbackModel>().map(JSON: json ?? [:])//SCNetResponseFeedbackModel
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseFeedbackModel>().mapArray(JSONArray: jsonArray)
    }
}

/*
 网络请求响应反馈记录信息模型
 */
public class SCNetResponseFeedbackRecordsInfoModel: Mappable, SCNetResponseModelProtocol {
    var current: Int = 0
    var pages: Int = 0
    var size: Int = 0
    var total: Int = 0
    var items: [SCNetResponseFeedbackRecordModel] = []
    
    init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        current <- map["current"]
        pages <- map["pages"]
        size <- map["size"]
        total <- map["total"]
        items <- map["records"]
        
        if total == 0 {
            total = Int((map.JSON["total"] as? String) ?? "0") ?? 0
        }
    }
    
    static func serialize(json: [String : Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseFeedbackRecordsInfoModel>().map(JSON: json ?? [:])
    }
}

/*
 网络请求响应反馈记录模型
 */
public class SCNetResponseFeedbackRecordModel: Mappable, SCNetResponseModelProtocol {
    /// 回答
    var answer: String = ""
    /// 创建者 用户ID
    var createBy: String = ""
    /// 创建时间
    var createTime: String = ""
    /// 是否删除 0:正常 0以下的数：已删除
    var deleteFlag: String = ""
    /// 设备id， 必填
    var deviceId: String = ""
    /// 主键ID
    var id: String = ""
    /// 联系方式,必填
    var phone: String = ""
    /// 问题内容，必填
    var question: String = ""
    /// 问题类型。必填，若type为设备，则为设备名称（绑定关系的昵称）;若type为智能场景，则为智能场景；若type为账号，则为账号
    var questionType: String = ""
    /// 路由型号
    var routerModel: String = ""
    /// 租户ID
    var tenantId: String = ""
    /// 标题
    var title: String = ""
    /// 类型。设备、智能场景、账号。必填
    var type: String = ""
    /// 修改者
    var updateBy: String = ""
    /// 修改时间
    var updateTime: String = ""
    /// 文件存储路径
    var url: String = ""
    /// 用户id， 必填
    var userId: String = ""
    /// 区域
    var zone: String = ""
    
    init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        answer <- map["answer"]
        createBy <- map["createBy"]
        createTime <- map["createTime"]
        deleteFlag <- map["deleteFlag"]
        deviceId <- map["deviceId"]
        id <- map["id"]
        phone <- map["phone"]
        question <- map["question"]
        questionType <- map["questionType"]
        routerModel <- map["routerModel"]
        tenantId <- map["tenantId"]
        title <- map["title"]
        type <- map["type"]
        updateBy <- map["updateBy"]
        updateTime <- map["updateTime"]
        url <- map["url"]
        userId <- map["userId"]
        zone <- map["zone"]
        
        if createTime.isEmpty {
            createTime = String((map.JSON["createTime"] as? Int64) ?? 0)
        }
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseFeedbackRecordModel>().map(JSON: json ?? [:])//SCNetResponseFeedbackModel
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseFeedbackRecordModel>().mapArray(JSONArray: jsonArray)
    }
}

public struct SCNetResponseRemoteNotificationConfigModel: Mappable, SCNetResponseModelProtocol {
    /// 家庭ID
    var familyId: String = ""
    /// 用户ID
    var userId: String = ""
    /// 分享表主键id，确认是那一条分享记录
    var shareId: String = ""
    /// 身份（0、管理员,1、普通成员,2、共享成员 ,3、待确认成员）
    var identify: String = ""
    /// 用户昵称
    var nickname: String = ""
    /// 用户头像
    var headUrl: String = ""
    
    /// 开始时间
    var beginTime: String = ""
    
    /// 创建时间
    var createTime: Int = 0
    
    ///
    var deleteFlag: Int = 0
    
    /// 结束时间
    var endTime: String = ""
    
    ///
    var id: Int = 0
    
    ///是否开启免消息打扰
    var notNotice: Int = 0
    
    /// 是否开启推送
    var open: Int = 0
    
    ///
    var tenantId: String = ""
    
    ///
    var updateTime: Int = 0
    
    var day: String = ""
    
    public init?(map: Map) { }
    mutating public func mapping(map: Map) {
        familyId <- map["familyId"]
        userId <- map["userId"]
        shareId <- map["shareId"]
        identify <- map["identity"]
        nickname <- map["nickName"]
        headUrl <- map["headUrl"]
        
        beginTime <- map["beginTime"]
        endTime <- map["endTime"]
        createTime <- map["createTime"]
        deleteFlag <- map["deleteFlag"]
        id <- map["id"]
        notNotice <- map["notNotice"]
        open <- map["open"]
        tenantId <- map["tenantId"]
        updateTime <- map["updateTime"]
        day <- map["day"]
     
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseRemoteNotificationConfigModel>().map(JSON: json ?? [:])
    }
}


/*
 网络请求响应设备共享模型
 */
public struct SCNetResponseDeviceShareModel: Mappable, SCNetResponseModelProtocol {
    /// 创建时间
    var createTime: String = ""
    /// 创建人ID
    var creatorId: String = ""
    /// 最新控制时间
    var ctrTime: String = ""
    /// 是否删除（0：正常；低于0的数字：已删除）
    var deleteFlag: String = ""
    /// 设备ID
    var deviceId: String = ""
    /// 排序权重
    var deviceSortWeight: String = ""
    /// 设备分享标识（0、正常，1、分享设备）
    var flag: String = ""
    /// 主键
    var id: String = ""
    /// 设备昵称（SN）
    var nickname: String = ""
    /// 设备拥有者(用户ID)
    var owner: String = ""
    /// 设备头像
    var photoUrl: String = ""
    /// 产品ID
    var productId: String = ""
    /// 房间ID
    var roomId: String = ""
    /// 房间类型(0、普通房间，1、常用，-1、不显示)
    var roomType: Int = 0
    /// 分享状态（0、未分享，1、分享）
    var shareStatus: Int = 0
    /// 设备sn
    var sn: String = ""
    /// 租户ID
    var tenantId: String = ""
    /// 更新人ID
    var updateId: String = ""
    /// 更新时间
    var updateTime: String = ""
    
    public init?(map: Map) { }
    mutating public func mapping(map: Map) {
        createTime <- map["createTime"]
        creatorId <- map["creatorId"]
        ctrTime <- map["ctrTime"]
        deleteFlag <- map["deleteFlag"]
        deviceId <- map["deviceId"]
        deviceSortWeight <- map["deviceSortWeight"]
        flag <- map["flag"]
        id <- map["id"]
        nickname <- map["nickname"]
        owner <- map["owner"]
        photoUrl <- map["photoUrl"]
        productId <- map["productId"]
        roomId <- map["roomId"]
        sn <- map["sn"]
        tenantId <- map["tenantId"]
        updateId <- map["updateId"]
        updateTime <- map["updateTime"]
        
        
        let roomTypeString = map.JSON["roomType"] as? String
        roomType = Int(roomTypeString ?? "") ?? 0
        let shareStatusString = map.JSON["shareStatus"] as? String
        shareStatus = Int(shareStatusString ?? "") ?? 0
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseProductManualModel>().map(JSON: json ?? [:])
    }
}

public class SCNetResponseConsumablesSectionModel: Mappable, SCNetResponseModelProtocol {
    var deviceId: String = ""
    var nickname: String = ""
    var owner: String = ""
    var productid: String = ""
    var roomId: String = ""
    var roomName: String = ""
    ///
    var items: [SCNetResponseConsumablesItemModel] = []
    
    init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        deviceId <- map["deviceId"]
        nickname <- map["nickname"]
        owner <- map["owner"]
        productid <- map["productid"]
        roomId <- map["roomId"]
        items <- map["consumablesList"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseConsumablesSectionModel>().map(JSON: json ?? [:])
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseConsumablesSectionModel>().mapArray(JSONArray: jsonArray)
    }
}


public class SCNetResponseConsumablesItemModel: Mappable, SCNetResponseModelProtocol {
    var balance: Int = 0
    var id: String = ""
    var imageUrl: String = ""
    var name: String = ""
    
    init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        balance <- map["balance"]
        id <- map["consumablesId"]
        imageUrl <- map["consumablesImgUrl"]
        name <- map["consumablesName"]
    }
    
    static func serialize(json: [String: Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseConsumablesItemModel>().map(JSON: json ?? [:])
    }
    
    static func serialize(jsonArray: [[String : Any]]) -> [SCNetResponseModelProtocol] {
        return Mapper<SCNetResponseConsumablesItemModel>().mapArray(JSONArray: jsonArray)
    }
}


/*
 网络请求响应设备消息记录信息模型
 */
public class SCNetResponseDeviceNotificaitonRecordsInfoModel: Mappable, SCNetResponseModelProtocol {
    var current: Int = 0
    var pages: Int = 0
    var size: Int = 0
    var total: Int = 0
    var items: [SCNetResponseDeviceNotificaitonRecordModel] = []
    
    init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        current <- map["current"]
        pages <- map["pages"]
        size <- map["size"]
        total <- map["total"]
        items <- map["list"]
        
        if total == 0 {
            total = Int((map.JSON["total"] as? String) ?? "0") ?? 0
        }
    }
    
    static func serialize(json: [String : Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseDeviceNotificaitonRecordsInfoModel>().map(JSON: json ?? [:])
    }
}

/*
 网络请求响应设备消息记录信息模型
 */
public class SCNetResponseDeviceNotificaitonRecordModel: Mappable, SCNetResponseModelProtocol {
    /// 别名
    var alias: String = ""
    /// 创建者
    var createBy: String = ""
    /// 创建时间
    var createTime: String = ""
    /// 是否删除，0-正常，-1已删除
    var deleteFlag: String = ""
    /// 设备id
    var deviceId: String = ""
    /// 主键id
    var id: String = ""
    /// 消息
    var msg: String = ""
    /// 结果：-1-失败、0-成功、1-免扰消息
    var result: Int = 0
    /// 状态：1-已读、0-未读
    var status: Int = 0
    /// 标签
    var tag: String = ""
    /// 租户id
    var tenantId: String = ""
    /// 消息标题
    var title: String = ""
    /// 消息通知模板id
    var tplId: String = ""
    /// 更新者
    var updateBy: String = ""
    /// 更新时间
    var updateTime: String = ""
    /// 用户id
    var userId: String = ""
    /// 地区
    var zone: String = ""
    
    init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        alias <- map["alias"]
        createBy <- map["createBy"]
        createTime <- map["createTime"]
        deleteFlag <- map["deleteFlag"]
        deviceId <- map["deviceId"]
        id <- map["id"]
        msg <- map["msg"]
        result <- map["result"]
        status <- map["status"]
        tag <- map["tag"]
        tenantId <- map["tenantId"]
        title <- map["title"]
        tplId <- map["tplId"]
        updateBy <- map["updateBy"]
        updateTime <- map["updateTime"]
        userId <- map["userId"]
        zone <- map["zone"]
    }
    
    static func serialize(json: [String : Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseDeviceNotificaitonRecordModel>().map(JSON: json ?? [:])
    }
}


/*
 网络请求响应设备消息记录信息模型
 */
public class SCNetResponseShareNotificaitonRecordsInfoModel: Mappable, SCNetResponseModelProtocol {
    var current: Int = 0
    var pages: Int = 0
    var size: Int = 0
    var total: Int = 0
    var items: [SCNetResponseShareNotificaitonRecordModel] = []
    
    init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        current <- map["current"]
        pages <- map["pages"]
        size <- map["size"]
        total <- map["total"]
        items <- map["list"]
        
        if total == 0 {
            total = Int((map.JSON["total"] as? String) ?? "0") ?? 0
        }
    }
    
    static func serialize(json: [String : Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseShareNotificaitonRecordsInfoModel>().map(JSON: json ?? [:])
    }
}

class SCNetResponseShareNotificaitonRecordModel: Mappable, SCNetResponseModelProtocol {
    /// 创建者
    var createBy: String = ""
    /// 创建时间
    var createTime: String = ""
    /// 是否删除，0-正常，-1已删除
    var deleteFlag: String = ""
    /// 消息发送者
    var from: String = ""
    /// 主键id
    var id: String = ""
    /// 消息体
    var msg: String = ""
    /// 设备昵称或家庭名称
    var name: String = ""
    /// 图片地址，用户图片或设备图片（产品图片）
    var photoUrl: String = ""
    /// 结果：-1-失败、0-成功、1-免扰消息
    var result: Int = 0
    /// 分享记录id
    var shareId: String = ""
    /// 状态，0-正常；1-已同意；2-已拒绝
    var status: Int = 0
    /// 设备或家庭id
    var targetId: String = ""
    /// 租户id
    var tenantId: String = ""
    /// 标题
    var title: String = ""
    /// 消息接收者
    var to: String = ""
    /// 类型,0-共享设备消息，1-共享家庭消息
    var type: Int = 0
    /// 更新者
    var updateBy: String = ""
    /// 更新时间
    var updateTime: String = ""
    /// 用户名，发送消息的用户的名称
    var username: String = ""
    /// 地区
    var zone: String = ""
 
    public init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        createBy <- map["createBy"]
        createTime <- map["createTime"]
        deleteFlag <- map["deleteFlag"]
        from <- map["from"]
        id <- map["id"]
        msg <- map["msg"]
        name <- map["name"]
        photoUrl <- map["photoUrl"]
        result <- map["result"]
        shareId <- map["shareId"]
        status <- map["status"]
        targetId <- map["targetId"]
        tenantId <- map["tenantId"]
        title <- map["title"]
        to <- map["to"]
        type <- map["type"]
        updateBy <- map["updateBy"]
        updateTime <- map["updateTime"]
        username <- map["username"]
        zone <- map["zone"]
    }
    
    static func serialize(json: [String : Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseShareNotificaitonRecordModel>().map(JSON: json ?? [:])
    }
}


/*
 网络请求响应OSS上传模型
 */
public class SCNetResponseUploadAccessModel: Mappable, SCNetResponseModelProtocol {
    var accessId: String = ""
    var bucket: String = ""
    var secret: String = ""
    var directory: String = ""
    var expirationTime: String = ""
    var endPoint: String = ""
    var policy: String = ""
    var signature: String = ""
    var cdnDomain: String = ""
    
    var expirationTimeInGMTFormat: String = ""
    
    init() {}
    required public init?(map: Map) { }
    public func mapping(map: Map) {
        accessId <- map["accessid"]
        bucket <- map["bucket"]
        secret <- map["secret"]
        directory <- map["dir"]
        expirationTime <- map["expire"]
        endPoint <- map["host"]
        policy <- map["policy"]
        signature <- map["signature"]
        cdnDomain <- map["cdnDomain"]
    }
    
    static func serialize(json: [String : Any]?) -> SCNetResponseModelProtocol? {
        return Mapper<SCNetResponseUploadAccessModel>().map(JSON: json ?? [:])
    }
}
