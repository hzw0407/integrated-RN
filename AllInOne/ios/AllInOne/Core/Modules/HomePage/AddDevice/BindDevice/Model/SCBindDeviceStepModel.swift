//
//  SCBindDeviceStepModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/15.
//

import UIKit

enum SCBindDeviceStepStatus: Int {
    case normal
    case loading
    case success
    case fail
}

enum SCBindDeviceStepType: Int {
    /// 手机连接设备
    case connectDevice
    /// 向设备传输信息
    case sendDataToDevice
    /// 设备连接网络
    case deviceConnectNet
}

class SCBindDeviceStepModel: NSObject {
    var type: SCBindDeviceStepType = .connectDevice
    var status: SCBindDeviceStepStatus = .normal
    var content: String {
        switch self.type {
        case .connectDevice:
            switch status {
            case .loading:
                return tempLocalize("手机连接设备中...")
            case .success:
                return tempLocalize("手机连接设备成功")
            case .fail:
                return tempLocalize("手机连接设备失败")
            default:
                return tempLocalize("手机连接设备")
            }
        case .sendDataToDevice:
            switch status {
            case .loading:
                return tempLocalize("向设备传输信息中...")
            case .success:
                return tempLocalize("向设备传输信息成功")
            case .fail:
                return tempLocalize("向设备传输信息失败")
            default:
                return tempLocalize("向设备传输信息")
            }
        case .deviceConnectNet:
            switch status {
            case .loading:
                return tempLocalize("设备连接网络中...")
            case .success:
                return tempLocalize("设备连接网络成功")
            case .fail:
                return tempLocalize("设备连接网络失败")
            default:
                return tempLocalize("设备连接网络")
            }
        }
    }
}
