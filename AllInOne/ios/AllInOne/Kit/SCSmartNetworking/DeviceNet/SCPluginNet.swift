//
//  SCPluginNet.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/2/15.
//

import UIKit

class SCPluginNet {
    var tenantId: String {
        return SCSmartNetworking.sharedInstance.user?.tenantId ?? ""
    }
    
    var uid: String {
        return SCSmartNetworking.sharedInstance.user?.id ?? ""
    }
    
    static let sharedInstance = SCPluginNet()
    
    /// 设置设备属性
    /// - Parameters:
    ///   - message: 消息体
    ///   - callback: 回调
    func setDeviceProperty(message: [String: Any], callback: SCSmartNetDeviceServiceBlock?) {
        SCSmartNetworking.sharedInstance.setDeviceProperty(message: message, callback: callback)
    }
    
    /// 获取设备属性
    /// - Parameters:
    ///   - message: 消息体
    ///   - callback: 回调
    func getDeviceProperty(message: [String: Any], callback: SCSmartNetDeviceServiceBlock?) {
        SCSmartNetworking.sharedInstance.getDeviceProperty(message: message, callback: callback)
    }

    /// 设置设备服务
    /// - Parameters:
    ///   - identifer: 服务类型
    ///   - message: 消息体
    ///   - callback: 回调
    func setDeviceService(identifer: String, message: [String: Any], callback: SCSmartNetDeviceServiceBlock?) {
        SCSmartNetworking.sharedInstance.setDeviceService(identifer: identifer, message: message, callback: callback)
    }
    
    /// 订阅设备属性推送
    /// - Parameter callback: 回调
    func subscribeDevicePropertyPush(callback: SCSmartNetDeviceServicePropertyPushBlock?) {
        SCSmartNetworking.sharedInstance.subscribeDevicePropertyPush(callback: callback)
    }
    
    func unsubscribeAll() {
        SCSmartNetworking.sharedInstance.unsubscribeAll()
    }
    
//    func download(url: String, needBackgroundDownload: Bool = false, progress: SCProgressHandler? = nil, success: SCSuccessData?, failure: SCFailureError?) {
//        SCSmartNetworking.sharedInstance.download(url: url, outFilePath: nil, needBackgroundDownload: needBackgroundDownload) { value in
//            progress?(value)
//        } success: { data in
//            success?(data)
//        } failure: { error in
//            failure?(error)
//        }
//
//    }
    
    func downloadByOssOrAws(direction: String, serviceType: SCSmartNetHttpUploadServiceType, progress: SCProgressHandler? = nil, success: SCSuccessData?, failure: SCFailureError?) {
        SCSmartNetworking.sharedInstance.downloadByOssOrAws(direction: direction, serviceType: serviceType, progress: { value in
            progress?(value)
        }, success: { data in
            success?(data)
        }, failure: { error in
            failure?(error)
        })
    }
}
