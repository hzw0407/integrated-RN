//
//  SCBindDeviceService.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/30.
//

import UIKit
import CoreBluetooth

/*
 绑定设备时数据交互的通信类型
 */
enum SCBindDeviceCommunicationType {
    /// 访问接入点，AP模式
    case accessPoint
    /// 通过蓝牙绑定
    case bluetooth
    /// 灵活链路组
    case smartLink
}

/*
 绑定设备的方式
 */
enum SCBindDeviceStyle {
    /// 设备绑定APP
    case deviceBindApp
    /// APP绑定设备
    case appBindDevice
}

/*
 绑定配置
 */
struct SCBindDeviceConfig {
    /// 用户id
    var uid: String = ""
    /// Wi-Fi名称
    var ssid: String = ""
    /// Wi-Fi密码
    var password: String = ""
    /// 域名
    var domain: SCNetResponseDomainModel = SCNetResponseDomainModel()
    /// 房间ID
    var familyId: String = ""
}

class SCBindDeviceService {
    static let shared = SCBindDeviceService()
    
    /// 配置
    private var communicationType: SCBindDeviceCommunicationType = .accessPoint
    
    private var apService: SCBindDeviceAccessPointService = SCBindDeviceAccessPointService()
    private var bleService: SCBindDeviceBluetoothService = SCBindDeviceBluetoothService()
    
    
//    /// 开始AP配网
//    /// - Parameters:
//    ///   - config: 配网参数
//    ///   - stepHandler: 步骤回调
//    ///   - completionHandler: 完成回调
//    func startByAccessPoint(config: SCBindDeviceConfig, stepHandler: ((SCBindDeviceAccessPointStep) -> Void)?, completionHandler: ((SCBindDeviceAccessPointResultType) -> Void)?, timeHandler: ((String) -> Void)? = nil) {
//        self.communicationType = .accessPoint
//        self.apService.start(config: config, stepHandler: stepHandler, completionHandler: completionHandler, timeHandler: timeHandler)
//    }
    
    func startByBluetooth(config: SCBindDeviceConfig, discoverPeripheralsHandle: (([CBPeripheral]) -> Void)?, stepHandler: ((SCBindDeviceBluetoothStep) -> Void)?, completionHandler: ((SCBindDeviceAccessPointResultType) -> Void)?, timeHandler: ((String) -> Void)? = nil) {
        self.communicationType = .bluetooth
        self.bleService.start(config: config, discoverPeripheralsHandle: discoverPeripheralsHandle, stepHandler: stepHandler, completionHandler: completionHandler, timeHandler: timeHandler)
    }
    
    func connect(peripheral: CBPeripheral) {
//        self.bleService.connect(peripheral: peripheral)
    }
    
    func stop() {
        switch self.communicationType {
        case .accessPoint:
            self.apService.stop()
            break
        case .bluetooth:
            self.bleService.stop()
            break
        default:
            break
        }
    }
}
