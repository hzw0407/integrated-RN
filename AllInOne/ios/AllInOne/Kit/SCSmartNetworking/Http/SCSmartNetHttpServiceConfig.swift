//
//  SCSmartHttpServiceConfig.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/1.
//

import UIKit
import Alamofire
import AWSCore

/// http请求回调闭包
public typealias SCSmartNetHttpServiceResponseBlock = (_ response: SCSmartNetHttpServiceResponse) -> Void
/// http请求成功回调闭包
public typealias SCSmartNetHttpServiceSuccessResponseBlock = (_ response: SCSmartNetHttpServiceSuccessResponse) -> Void
/// http请求失败回调闭包
public typealias SCSmartNetHttpServiceFailureResponseBlock = (_ error: SCSmartNetworkingError) -> Void

/// 默认HTTP头部
let SCSmartNetHttpDefaultHeaders = ["Content-Type":"application/json"]

/// 默认http请求头
public typealias SCSmartNetHttpServiceHeaders = [String: String]

/*
 http请求成功响应
 */
public struct SCSmartNetHttpServiceSuccessResponse {
    var code: Int = 0
    var json: [String: Any]?
    var data: Data?
    var string: String?
    var custom: Any?
    var error: SCSmartNetworkingError?
}
/*
 http请求响应
 */
public struct SCSmartNetHttpServiceResponse {
    var code: Int = -1
    var json: [String: Any]?
    var data: Data?
    var string: String?
    var custom: Any?
    var error: SCSmartNetworkingError?
    var isCache: Bool = false
}
/*
 验证码类型
 */
public enum SCSmartNetHttpAuthCodeType: String {
    /// 注册
    case register = "register"
    /// 登录
    case login = "login"
    /// 重置密码
    case resetPassword = "reset_password"
    /// 修改邮箱
    case modifyEmail = "modify_email"
    /// 修改手机
    case modifyPhone = "modify_phone"
}

/*
 服务器类型
 */
public enum SCSmartServerType {
    /// 生产
    case product
    /// 测试
    case test
    /// 开发
    case develop
    
    var domainBasicUrl: String {
        switch self {
        case .product:
            return "https:appaiot.3irobotix.net"
        case .test:
            return "https://test-sz-cn-appaiot.3irobotix.net"
        case .develop:
            return "https://dev-sz-cn-appaiot.3irobotix.net"
        }
    }
}

/*
 http服务配置
 */
class SCSmartHttpServiceConfig {
    /// 获取域名的地址
    var domainBaseUrl: String {
        return self.serverType.domainBasicUrl
    }
    /// 基地址
    var baseUrl: String = ""
    /// 工程类型
    var projectType: String = ""
    /// 租户ID
    var tenantId: String = ""
    /// APP版本
    var version: String = ""
    /// 地区
    var zone: String = ""
    /// 语言
    var lang: String = "en"
    
    var serverType: SCSmartServerType = .test
}

/*
 请求接口
 */
enum SCSmartHttpServiceApi {
    // MARK: - user center
    /// 域名列表
    case domainsList
    /// 注册
    case register
    /// 登录
    case login
    /// 验证码登录
    case loginWithAuthCode
    /// token登录
    case loginWithToken
    /// 获取验证码
    case getAuthCode
    /// 退出登录
    case logout
    /// 修改密码
    case changePassword
    /// 重置密码
    case resetPassword
    /// 获取头像
    case getAvatar
    /// 获取昵称
    case getNickname
    /// 用户简介
    case getProfile
    /// 修改头像
    case modifyAvatar
    /// 修改昵称
    case modifyNickname
    /// 修改email
    case modifyEmail
    /// 修改手机号
    case modifyPhone
    /// 设置国家
    case setCountry
    /// 删除账号
    case deleteAccount
    
    // MARK: - device
    /// 获取设备信息
    case getDeviceInfo
    
    /// 获取产品列表
    case getProductList
    /// 获取产品信息
    case getProductInfoList
    /// 获取产品类型列表
    case getProductTypeList
    /// 获取产品信息
    case getProductInfo
    /// APP绑定设备
    case appBindDevice
    /// 设备绑定APP结果
    case deviceBindAppResult
    /// 修改设备昵称
    case modifyDeviceNickname
    /// 获取设备在线状态
    case getDeviceOnlineStatus
    /// 获取设备状态
    case getDeviceStatus
    /// 设置默认设备
    case setDefaultDevice
    /// 获取用户的分享信息
    case getShareInfo
    /// 分享设备给其他用户
    case shareDeviceToUser
    /// 删除分享信息
    case deleteShare
    /// 回复用户的分享
    case replyShareByUser
    /// 触发设备升级
    case triggerDeviceUpgrade
    /// 解绑设备
    case unbindDevice
    /// 上传文件
    case uploadFile
    /// 获取FAQ列表
    case getFaqList
    /// 获取协议类型
    case getUserProtocolType
    /// 获取协议内容
    case getUserProtocolContent
    /// 获取产品说明书下载地址
    case getProductManualDownloadUrl
    
    /// 上传配网步骤日志
    case uploadConfigNetStepLog
    /// 上传配网错误日志
    case uploadConfigNetErrorLog
    /// 上传错误日志
    case uploadAppErrorLog
    /// 上传运行日志
    case uploadAppLog
    
    /// 添加家庭
    case addFamily
    /// 获取家庭详情
    case getFamilyDetail
    /// 根据用户ID获取所有家庭信息(包含房间列表，设备ID列表)
    case getFamilyListWithRoomsDeviceIds
    /// 根据用户ID获取所有家庭列表
    case getFamilyList
    ///根据家庭ID查询设备耗材
    case getConsumablesInfoByFamilyId
    /// 修改家庭
    case modifyFamily
    /// 删除家庭
    case deleteFamily
    
    /// 添加家庭房间
    case addFamilyRoom
    /// 修改家庭房间
    case modifyFamilyRoom
    /// 删除家庭房间
    case deleteFamilyRooms
    /// 修改房间绑定设备昵称
    case modifyFamilyRoomDeviceNickname
    /// 将设备移动到另一个房间
    case moveDeviceToOtherRoom
    /// 将设备移动到常用房间
    case moveDeviceToUsedRoom
    /// 将房间设备移动到顶部位置
    case moveRoomDeviceToTop
    /// 根据房间ID获取对应绑定关系
    case getDeviceListByFamilyRoom
    /// 设置默认房间设备
    case setRoomDefaultDevice
    /// 更新家庭房间排序
    case updateFamilyRoomsSort
    
    /// 添加家庭成员
    case addFamilyMember
    /// 获取等待确认家庭分享列表
    case getWaitReplyByFamilyShare
    /// 回复家庭分享
    case replyFamilyShare
    /// 退出家庭
    case exitFamilyByUser
    /// 删除家庭成员
    case deleteFamilyMember
    /// 获取家庭分享记录
    case getFamilyShareRecord
    /// 获取家庭成员列表
    case getFamilyMemberList
    /// 获取家庭成员详情信息
    case getFamilyMemberDetail
    
    /// 根据家庭ID查询设备列表
    case getDeviceListByFamily
    /// 根据设备ID查询设备列表
    case getDeviceListByUid
    /// 用户家庭房间绑定设备
    case bindDeviceByRoom
    /// 用户家庭房间解绑设备
    case unbindDeviceByRoom
    /// 用户家庭绑定分享设备
    case bindShareDeviceByFamily
    /// 用户家庭解绑分享设备
    case unbindShareDeviceByFamily
    /// 根据用户ID解绑分享设备
    case unbindShareDeviceByUid
    /// 将设备移出常用
    case moveDeviceOutUsed
    /// 更新房间设备列表排序
    case updateRoomDevicesSort
    
    
    /// 获取所有反馈列表
    case getAllFeedbackList
    /// 获取反馈记录
    case getFeedbackRecord
    /// 上传反馈问题
    case uploadFeedback
    /// 删除反馈记录
    case deleteFeedbackRecord
    
    /// 设置远程推送
    case setRemoteNotification
    /// 获取远程推送设置
    case getRemoteNotificationConfig
    /// 获取设备消息列表
    case getDeviceNotificationRecord
    /// 获取分享消息列表
    case getShareNotificationRecord
    /// 回复分享消息里的分享
    case replyByShareNotificationRecord
     
    //获取个人中心历史分享记录
    case getShareHistory
    /// 回复分享
    case replyForShare
    
    //获取分享设备列表
    case getShareDevice
    //获取接受设备列表
    case getAcceptList
    
    /// 获取耗材列表
    case getConsumablesList
    
    /// 获取国内上传地址
    case getUploadAccessForChina
    /// 获取国外上传地址
    case getUploadAccessForForeign
    
    var path: String {
        switch self {
        case .domainsList:
            return "/network-service/domains/list"
        case .register:
            return "/user-center/auth/register"
        case .login:
            return "/user-center/auth/login"
        case .loginWithAuthCode:
            return "/user-center/auth/login/authcode"
        case .loginWithToken:
            return "/user-center/auth/login/token"
        case .getAuthCode:
            return "/user-center/auth/obtain/authcode"
        case .logout:
            return "/user-center/auth/logout"
        case .changePassword:
            return "/user-center/app/user/password/change"
        case .resetPassword:
            return "/user-center/auth/password/forget"
        case .getAvatar:
            return "/user-center/app/user/avatar"
        case .getNickname:
            return "/user-center/app/user/nickname"
        case .getProfile:
            return "/user-center/app/user/profile"
            
        case .modifyAvatar:
            return "/user-center/app/user/modify/avatar"
        case .modifyNickname:
            return "/user-center/app/user/modify/nickname"
        case .modifyEmail:
            return "/user-center/app/user/modify/email"
        case .modifyPhone:
            return "/user-center/app/user/modify/phone"
        case .setCountry:
            return "/user-center/app/user/set/country"
        case .deleteAccount:
            return "/user-center/app/user/del"
           
        case .getProductList:
            return "/smart-home-service/app/productInfo/getProductInfoByTenantId"
        case .getProductInfoList:
            return "/product-service/inner/productInfo/list/ids"
        case .getProductTypeList:
            return "/smart-home-service/app/productInfo/getClassifyByParentId"
        case .getProductInfo:
            return "/product-service/productInfo/getInfo"
        case .getDeviceInfo:
            return "/device-service/app/device/info"
        case .appBindDevice:
//            return "/device-service/app/bind"
            return "/device-service/app/bind/override"
        case .deviceBindAppResult:
            return "/device-service/app/bind/confirm"
        case .modifyDeviceNickname:
//            return "/smart-home-service/smartHome/roomDevice/modifyNickname"
            return "/device-service/app/modify/nickname"
        case .getDeviceOnlineStatus:
            return "/device-service/app/device/online"
        case .getDeviceStatus:
            return "/device-service/app/device/status"
        case .setDefaultDevice:
            return "/device-service/app/setDefault"
        case .getShareInfo:
            return "/device-service/app/shared/device"
        case .shareDeviceToUser:
            return "/device-service/app/share"
        case .deleteShare:
            return "/device-service/app/shared/del"
        case .replyShareByUser:
            return "/device-service/app/shared/reply"
        case .triggerDeviceUpgrade:
            return "/device-service/app/trigger/upgrade"
        case .unbindDevice:
            return "/device-service/app/unbind"
            
        case .uploadFile:
            return "/storage-management/storage/oss/inner/uploadFile"
            
        case .getFaqList:
            return "/content-service/app/faq"
        case .getUserProtocolType:
            return "/content-service/app/metadata/policy/type"
        case .getUserProtocolContent:
            return "/content-service/app/policy"
        case .getProductManualDownloadUrl:
            return "/content-service/app/specification"
            
        case .uploadConfigNetStepLog:
            return "/log-service/log/app/report/config"
        case .uploadConfigNetErrorLog:
            return "/log-service/log/app/report/error/network"
        case .uploadAppErrorLog:
            return "/log-service/log/app/report/error"
        case .uploadAppLog:
            return "/log-service/log/app/report/runtime"
        
        case .addFamily:
            return "/smart-home-service/smartHome/familyInfo/add"
        case .getFamilyDetail:
            return "/smart-home-service/smartHome/user/getFamilyRoomInfoVoByFamilyId"
        case .getFamilyListWithRoomsDeviceIds:
            return "/smart-home-service/smartHome/user/getFamilyRoomInfoVoByUserId"
        case .getFamilyList:
            return "/smart-home-service/smartHome/familyInfo/list"
        case .getConsumablesInfoByFamilyId:
            return "/smart-home-service/smartHome/consumablesInfo/getConsumablesInfoByFamilyId"
        case .modifyFamily:
            return "/smart-home-service/smartHome/familyInfo/modify"
        case .deleteFamily:
            return "/smart-home-service/smartHome/familyInfo"
            
        case .addFamilyRoom:
            return "/smart-home-service/smartHome/roomInfo/add"
        case .modifyFamilyRoom:
            return "/smart-home-service/smartHome/roomInfo/modify"
        case .deleteFamilyRooms:
            return "/smart-home-service/smartHome/roomInfo/deleteByIds"
        case .modifyFamilyRoomDeviceNickname:
            return "/smart-home-service/smartHome/roomDevice/modifyNickname"
        case .moveDeviceToOtherRoom:
            return "/smart-home-service/smartHome/roomDevice/moveRoom"
        case .moveDeviceToUsedRoom:
            return "/smart-home-service/smartHome/roomDevice/moveCommonRoom"
        case .moveRoomDeviceToTop:
            return "/smart-home-service/smartHome/roomDevice/moveTop"
        case .getDeviceListByFamilyRoom:
            return "/smart-home-service/smartHome/roomDevice/roomBind"
        case .setRoomDefaultDevice:
            return "/smart-home-service/smartHome/roomDevice/setDefault"
        case .updateFamilyRoomsSort:
            return "/smart-home-service/smartHome/roomInfo/updateOrder"
            
        case .addFamilyMember:
            return "/smart-home-service/smartHome/userShare/bind"
        case .getWaitReplyByFamilyShare:
            return "/smart-home-service/smartHome/userShare/waitingList"
        case .replyFamilyShare:
            return "/smart-home-service/smartHome/userShare/action"
        case .exitFamilyByUser:
            return "/smart-home-service/smartHome/userShare/abandon"
        case .deleteFamilyMember:
            return "/smart-home-service/smartHome/userShare/revoke"
        case .getFamilyShareRecord:
            return "/smart-home-service/smartHome/userShare/shareHistory"
        case .getFamilyMemberList:
            return "/smart-home-service/smartHome/userFamily/list"
        case .getFamilyMemberDetail:
            return "/smart-home-service/smartHome/userFamily/info"
            
        case .getDeviceListByFamily:
            return "/smart-home-service/smartHome/user/getDeviceInfoByFamilyId"
        case .getDeviceListByUid:
            return "/smart-home-service/smartHome/user/getDeviceInfoByUserId"
        case .bindDeviceByRoom:
            return "/smart-home-service/smartHome/device/bind"
        case .unbindDeviceByRoom:
            return "/smart-home-service/smartHome/device/untie"
        case .bindShareDeviceByFamily:
            return "/smart-home-service/smartHome/device/shareBind"
        case .unbindShareDeviceByFamily:
            return "/smart-home-service/smartHome/device/shareUntie"
        case .unbindShareDeviceByUid:
            return "/smart-home-service/smartHome/device/userUntieDevice"
        case .moveDeviceOutUsed:
            return "/smart-home-service/smartHome/device/untieBatch"
        case .updateRoomDevicesSort:
            return "/smart-home-service/smartHome/roomDevice/updateOrder"
            
        case .getAllFeedbackList:
            return "/content-service/app/feedback/all"
        case .getFeedbackRecord:
            return "/content-service/app/feedback/page"
        case .uploadFeedback:
            return "/content-service/app/feedback/report"
        case .deleteFeedbackRecord:
            return "/content-service/app/feedback/batch"
            
        case .setRemoteNotification:
            return "/jpush-service/app/notice/setting/setting"
        case .getRemoteNotificationConfig:
            return "/jpush-service/app/notice/setting/get"
        case .getDeviceNotificationRecord:
            return "/jpush-service/app/record/page"
        case .getShareNotificationRecord:
            return "/jpush-service/app/share/record/page"
        case .replyByShareNotificationRecord:
            return "/jpush-service/app/share/record/change/status"
            
        case .getShareDevice:
            return "/smart-home-service/smartHome/user/getShareDevicesByUserId"
            
        case .getShareHistory:
            return "/device-service/app/shared/history"
        case .replyForShare:
            return "/device-service/app/shared/reply"
            
        case .getAcceptList:
            return "/smart-home-service/smartHome/user/getAcceptDevicesByUserId"
        
        case .getConsumablesList:
            return "/product-service/consumablesConfig/list"
            
            
        case .getUploadAccessForChina:
            return "/storage-management/storage/oss/getAccessUrl"
        case .getUploadAccessForForeign:
            return "/storage-management/storage/aws/getAccessUrl"
        }
        
  
    
    }
    
    var method: HTTPMethod {
        switch self {
        case .domainsList, .getAvatar, .getNickname, .getProfile,
                .getDeviceInfo, .getDeviceOnlineStatus, .getDeviceStatus,  .triggerDeviceUpgrade, .getProductTypeList,
                .getFaqList, .getUserProtocolType, .getUserProtocolContent, .getProductManualDownloadUrl,
                .getDeviceListByUid, .getDeviceListByFamily, .getFamilyDetail, .getFamilyListWithRoomsDeviceIds, .getFamilyList, .getFamilyMemberDetail, .getRemoteNotificationConfig, .getShareDevice, .getAcceptList, .getConsumablesList, .getConsumablesInfoByFamilyId, .getProductList, .getProductInfo:
            return .get
        case .modifyAvatar, .modifyEmail, .modifyPhone, .modifyNickname, .setCountry,
                .modifyDeviceNickname:
            return .put
        case .deleteAccount, .deleteShare, .deleteFamily, .deleteFeedbackRecord:
            return .delete
        case .modifyFamilyRoomDeviceNickname, .setRemoteNotification:
            return .put

        case .getShareInfo,.uploadFeedback:

            return .post
        default:
            return .post
        }
    }
    
    var contentType: String {
        switch self {
        case .uploadFile:
            return "multipart/form-data"
        default:
            return "application/json"
        }
    }
    
    var isQueryParam: Bool {
        switch self {
        case .deleteShare:
            return true
        default:
            return false
        }
    }
}

extension String {
    var mimeTypeByFileName: String {
        let ext = (self.components(separatedBy: ".").last ?? "").lowercased()
        switch ext {
        case "png":
            return "image/png"
        case "bmp", "dib":
            return "image/bmp"
        case "jpg", "jpeg":
            return "image/jpeg"
        case "gif":
            return "image/gif"
        case "mp3":
            return "audio/mpeg"
        case "mp4", "mpg4", "m4v", "mp4v":
            return "video/mp4"
        case "js":
            return "application/javascript"
        case "pdf":
            return "application/pdf"
        case "text", "txt":
            return "text/plan"
        case "json":
            return "application/json"
        case "xml":
            return "text/xml"
        default:
            return "zip/zip"
        }
    }
}

/*
 APP日志类型
 */
public enum SCNetHttpLogType {
    /// app配网步骤日志
    case configNetStep
    /// app配网错误日志
    case configNetError
    /// app错误日志
    case appError
    /// app日志
    case app
    
    var api: SCSmartHttpServiceApi {
        switch self {
        case .configNetStep:
            return .uploadConfigNetStepLog
        case .configNetError:
            return .uploadConfigNetErrorLog
        case .appError:
            return .uploadAppErrorLog
        case .app:
            return .uploadAppLog
        }
    }
    
    var value: String {
        switch self {
        case .configNetStep:
            return "configNetStep"
        case .configNetError:
            return "configNetError"
        case .appError:
            return "appError"
        case .app:
            return "app"
        }
    }
}

public enum SCSmartNetHttpUploadServiceType: Int {
    /// 图片
    case image = 1
    /// 地图
    case map = 2
    /// APP日志
    case appLog = 3
    /// 设备日志
    case deviceLog = 4
    /// 视频
    case video = 5
    /// 更新包
    case update = 6
    /// 所有
    case all = 7
    
    var ext: String {
        switch self {
        case .image:
            return "jpg"
        case .map:
            return "map"
        case .appLog:
            return "zip"
        case .deviceLog:
            return "zip"
        case .video:
            return "map4"
        case .update:
            return "zip"
        case .all:
            return "zip"
        }
    }
    
    var mimeTypeByFileName: String {
        switch self.ext {
        case "png":
            return "image/png"
        case "bmp", "dib":
            return "image/bmp"
        case "jpg", "jpeg":
            return "image/jpeg"
        case "gif":
            return "image/gif"
        case "mp3":
            return "audio/mpeg"
        case "mp4", "mpg4", "m4v", "mp4v":
            return "video/mp4"
        case "js":
            return "application/javascript"
        case "pdf":
            return "application/pdf"
        case "text", "txt":
            return "text/plan"
        case "json":
            return "application/json"
        case "xml":
            return "text/xml"
        default:
            return "zip/zip"
        }
    }
}


extension AWSRegionType {
    static func type(endPoint: String) -> AWSRegionType {
        switch endPoint {
        case "us-east-1":
            return AWSRegionType.USEast1
        case "us-east-2":
            return AWSRegionType.USEast2
        case "us-west-1":
            return AWSRegionType.USWest1
        case "us-west-2":
            return AWSRegionType.USWest2
        case "eu-west-1":
            return AWSRegionType.EUWest1
        case "eu-west-2":
            return AWSRegionType.EUWest2
        case "euwest-3":
            return AWSRegionType.EUWest3
        case "eu-central-1":
            return AWSRegionType.EUCentral1
        case "eu-north-1":
            return AWSRegionType.EUNorth1
        case "ap-east-1":
            return AWSRegionType.APEast1
        case "ap-southeast-1":
            return AWSRegionType.APSoutheast1
        case "ap-northeast-1":
            return AWSRegionType.APNortheast1
        case "ap-northeast-2":
            return AWSRegionType.APNortheast2
        case "ap-southeast-2":
            return AWSRegionType.APSoutheast2
        case "ap-southeast-3":
            return AWSRegionType.APSoutheast3
        case "ap-south-1":
            return AWSRegionType.APSouth1
        case "sa-east-1":
            return AWSRegionType.SAEast1
        case "cn-north-1":
            return AWSRegionType.CNNorth1
        case "cn-northwest-1":
            return AWSRegionType.CNNorthWest1
        case "ca-central-1":
            return AWSRegionType.CACentral1
        case "us-gov-west-1":
            return AWSRegionType.USGovWest1
        case "us-gov-east-1":
            return AWSRegionType.USGovEast1
        case "me-south-1":
            return AWSRegionType.MESouth1
        case "af-south-1":
            return AWSRegionType.AFSouth1
        case "eu-south-1":
            return AWSRegionType.EUSouth1
        default:
            return AWSRegionType.APNortheast2
            break
        }
    }
}
