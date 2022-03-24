//
//  SCBindDeviceBluetoothService.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/30.
//

import UIKit
import CoreBluetooth

enum SCBindDeviceBluetoothStep: Int {
    /// 普通状态
    case none = 0
    /// 开始
    case start
    /// 蓝牙开启成功
    case poweredOn
    /// 扫描到设备
    case foundDevice
    /// 等待连接
    case waitConnectDevice
    /// 连接上设备
    case connectedWidthDevice
    /// 发现了符合的特征
    case discoverCharacteristic
    /// 发送数据中
    case sendingData
    /// 收到设备返回的数据
    case receivedData
    /// 循环获取绑定结果
    case loopGetBindingResult
    /// 获得绑定结果
    case gotBindingResult
    /// 获取锁定控制权
    case loopLocking
    /// 绑定成功
    case success
    
    var name: String {
        switch self {
        case .none:
            return "none"
        case .start:
            return "start"
        case .poweredOn:
            return "Bluetooth powered on"
        case .foundDevice:
            return "Found devices"
        case .waitConnectDevice:
            return "Wait connect device"
        case .connectedWidthDevice:
            return "Connected with device"
        case .discoverCharacteristic:
            return "Discover characteristic"
        case .sendingData:
            return "Sending data"
        case .receivedData:
            return "Received device data"
        case .loopGetBindingResult:
            return "Loop to get the binding result"
        case .gotBindingResult:
            return "Got the binding result"
        case .loopLocking:
            return "Loop locking device"
        case .success:
            return "Bind successfully"
        }
    }
}

class SCBindDeviceBluetoothService {
    static let shared = SCBindDeviceBluetoothService()
    
    var bleState: CBManagerState?
    
//    private let serviceUuidString = "A00A"
//    private let writeCharacteristicUuidString = "B002"
//    private let readCharacteristicUuidString = "B001"
    private let serviceUuidString = "00010203-0405-0607-0809-0A0B0C0D1910"
    private let writeCharacteristicUuidString = "00010203-0405-0607-0809-0A0B0C0D2F10"
    private let readCharacteristicUuidString = "00010203-0405-0607-0809-0A0B0C0D2B10"
    private var filterPeripheralNames: [String] = ["Let", "w", "baby", "Midas"]
    private var filterPeripheralUuids: [String] = []
    
    private var currentPeripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?
    private var readCharacteristic: CBCharacteristic?
    private var peripherals: [CBPeripheral] = []
    
    private var centerUpdateStateBlock: ((CBManagerState) -> Void)?
    private var discoverPeripheralsBlock: (([CBPeripheral]) -> Void)?
    private var connectedPeripheralBlock: ((CBPeripheral) -> Void)?
    
    private var config: SCBindDeviceConfig = SCBindDeviceConfig()
    private var bindKey: String = ""
    var step: SCBindDeviceBluetoothStep = .none {
        willSet {
            if newValue != self.step {
                self.stepBlock?(newValue)
            }
        }
        didSet {
            if self.step != .none {
                self.writeBindLog(step: self.step)
            }
        }
    }
    
    /// 绑定超时时间
    private var timeoutDuration: TimeInterval = 120
    /// 连接设备超时时间
    private var connectionTimeoutDuration: TimeInterval = 30
    /// 开始时间
    private var startTime: TimeInterval = 0
    /// 开始连接设备时间
    private var startConnectTime: TimeInterval = 0
    /// 定时器
    private var timer: Timer?
    private var sendDataTimer: Timer?
    /// 配网步骤回调闭包
    private var stepBlock: ((SCBindDeviceBluetoothStep) -> Void)?
    /// 配网完成回调闭包
    private var completionBlock: ((SCBindDeviceAccessPointResultType) -> ())?
    
    private var timeBlock: ((String) -> Void)?
    
    /// wifi信息
    private var wifiInfo: SCBindDeviceAccessPointWifiData?
    
    /// sn
    private (set) var sn: String = ""
    /// mac
    private var mac: String = ""
    /// 设备类型
    private var deviceType: Int = 0
    /// 设备id
    private (set) var deviceId: String = ""
    /// 产品ID
    private (set) var productId: String = ""
    
    private var timeCount: Int = 0
    
    private var allPeripherals: [CBPeripheral] = []
    
    private lazy var bleManager: SCBluetoothManager = {
        let ble = SCBluetoothManager { [weak self] central in
            guard let `self` = self, let state = central?.state else { return }
            if state == .poweredOn {
                self.step = .poweredOn
                SCSDKLog("蓝牙开启成功")
            }
            else {
                if state == .unauthorized {
                    SCSDKLog("蓝牙开权限未开启")
                }
                else if state == .poweredOff {
                    SCSDKLog("蓝牙已关闭")
                }
                else {
                    SCSDKLog("蓝牙开启失败")
                }
            }
            self.bleState = state
            self.centerUpdateStateBlock?(state)
        } discoverPeripheralHandle: { [weak self] central, peripheral, advertisementData in
            guard let `self` = self else { return }
            guard let peripheral = peripheral else { return }
//            if self.allPeripherals.filter({ $0.identifier.uuidString == peripheral.identifier.uuidString }).count == 0 {
//                self.allPeripherals.append(peripheral)
//                
//                let name = peripheral.name ?? ""
//                var macString: String?
//                if let serviceDict = advertisementData?[CBAdvertisementDataServiceDataKey] as? [AnyHashable: Any] {
//                    let key = CBUUID(string: "FE95")
//                    let range = NSRange(location: 5, length: 6)
//                    if let serviceData = serviceDict[key] as? Data, serviceData.count > range.location + range.length {
//                        var macData = (serviceData as NSData).subdata(with: range)
//                        macData = macData.transfromBigOrSmall()
//                        macString = macData.hexString("")
//                        peripheral.mac = macString
//                    }
//                }
//                
//                let _ = advertisementData?[CBAdvertisementDataManufacturerDataKey] as? Data
//                #if DEBUG
//                SCSDKLog("发现设备 name：\(name), uuid:\(peripheral.identifier.uuidString), mac str:\(macString)")
//                SCSDKLog("ad:\(advertisementData)")
//                #endif
//            }
            
            let containsUUid = self.filterPeripheralUuids.first(where: { uuid in
                return peripheral.identifier.uuidString == uuid
            }) != nil
            let containsName = self.filterPeripheralNames.first(where: { name in
                return (peripheral.name ?? "").hasPrefix(name)
            }) != nil
            if containsUUid || containsName || true {
                if !self.peripherals.contains(peripheral) {
                    let name = peripheral.name ?? ""
                    var serviceString: String?
                    if let serviceDict = advertisementData?[CBAdvertisementDataServiceDataKey] as? [AnyHashable: Any] {
//                        let key = CBUUID(string: "FE95")
                        let key = CBUUID(string: "FF98")
                        let productRange = NSRange(location: 2, length: 8)
                        let macRange = NSRange(location: 11, length: 6)
                        if let serviceData = serviceDict[key] as? Data {
                            serviceString = serviceData.hexString("")
                            if serviceData.count > macRange.location + macRange.length {
                                var macData = (serviceData as NSData).subdata(with: macRange)
                                macData = macData.transfromBigOrSmall()
                                let macString = macData.hexString("")
                                peripheral.mac = macString
                            }
                            if serviceData.count > productRange.location + productRange.length {
                                var productIdData = (serviceData as NSData).subdata(with: productRange)
//                                productIdData = productIdData.transfromBigOrSmall()
                                if productIdData.count >= 8 {
                                    let productIdBytes = productIdData.bytes
                                    var productId: UInt64 = 0
                                    for i in 0..<productIdBytes.count {
                                        productId += UInt64(productIdBytes[i]) << UInt64(8 * i)
                                    }
                                    peripheral.productId = String(productId)
                                }
                            }
                        }
                    }
                    
                    if peripheral.productId != nil {
                        self.peripherals.append(peripheral)
                        self.discoverPeripheralsBlock?(self.peripherals)
                        self.step = .foundDevice
                        
                        SCSDKLog("发现新的设备-- name:\(peripheral.name ?? ""), uuid:\(peripheral.identifier.uuidString), mac:\(peripheral.mac ?? "nil"), productId:\(peripheral.productId ?? ""), service:\(serviceString ?? "nil")")
                    } 
                }
            }
        } connectedPeripheralHandle: { [weak self] central, peripheral in
            SCSDKLog("连接上设备 -- name:\(peripheral?.name ?? ""), uuid:\(peripheral?.identifier.uuidString)")
            if peripheral != nil {
                self?.currentPeripheral = peripheral
                self?.step = .connectedWidthDevice
            }
            
        } connectPeripheralFailHandle: { central, peripheral, error in
            
        } disconnectPeripheralHandle: { central, peripheral, error in
            
        } discoverServicesHandle: { peripheral, error in
            
        } discoverCharacteristicsHandle: { [weak self] peripheral, service, error in
            guard let `self` = self else { return }
            SCSDKLog("servie uuid:\(service?.uuid.uuidString)")
            if let service = service, service.uuid.uuidString == self.serviceUuidString {
                if let chars = service.characteristics {
                    for ch in chars {
                        SCSDKLog("characteristic uuid:\(ch.uuid.uuidString)")
                    }
                }
                var hasRead = false
                var hasWrite = false
                if let characteristic = service.characteristics?.filter({ $0.uuid.uuidString == self.writeCharacteristicUuidString }).first {
                    self.writeCharacteristic = characteristic
                    hasWrite = true
                    SCSDKLog("发现写特征：\(characteristic.uuid.uuidString)")
                }
                if let characteristic = service.characteristics?.filter({ $0.uuid.uuidString == self.readCharacteristicUuidString }).first {
                    self.readCharacteristic = characteristic
                    hasRead = true
                    SCSDKLog("发现读特征：\(characteristic.uuid.uuidString)")
                    
                    self.bleManager.readCharacteristic(peripheral: peripheral!, characteristic: characteristic)
                }
                if hasRead && hasWrite {
                    self.step = .discoverCharacteristic
                }
            }
        } readDataHandle: { [weak self] peripheral, characteristic, data in
            SCSDKLog("收到蓝牙收据 dataLength:\(data.count)")
            guard let `self` = self else { return }
            let encryptString = String(data: data, encoding: .utf8) ?? ""
            SCSDKLog("收到蓝牙字符串数据：\(encryptString)")
            let decryptString = SCSmartAESCode.aesDecrypt(content: encryptString, key: SCSmartNetworking.sharedInstance.aesKey)
            let jsonData = decryptString.data(using: .utf8) ?? Data()
            if let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) as? [String: Any] {
                SCSDKLog("收到最终json数据:\n\(json)")
                self.sn = (json["sn"] as? String) ?? ""
                self.mac = (json["mac"] as? String) ?? ""
                self.productId = (json["productId"] as? String) ?? ""
                self.step = .receivedData
            }
        }

        return ble
    }()
    
    func startScan(centerUpdateStateHandle: ((CBManagerState) -> Void)?, discoverPeripheralsHandle: (([CBPeripheral]) -> Void)?) {
//        self.filterPeripheralUuids = filterPeripheralUuids
//        self.filterPeripheralNames = filterPeripheralNames
        if self.bleState != nil {
            self.centerUpdateStateBlock?(self.bleState!)
        }
        self.discoverPeripheralsBlock = discoverPeripheralsHandle
        self.centerUpdateStateBlock = centerUpdateStateHandle
        self.startScan()
    }
    
    func connect(config: SCBindDeviceConfig, peripheral: CBPeripheral,
                 stepHandler: ((SCBindDeviceBluetoothStep) -> Void)?,
                 completionHandler: ((SCBindDeviceAccessPointResultType) -> Void)?,
                 timeHandler: ((String) -> Void)? = nil) {
        SCSDKLog("开始连接蓝牙设备-- uuid:\(peripheral.identifier.uuidString), name: \(peripheral.name ?? "nil"), mac:\(peripheral.mac ?? "nil")")
        self.stepBlock = stepHandler
        self.completionBlock = completionHandler
        self.timeBlock = timeHandler
        self.config = config
                
        self.step = .start
        self.startTime = Date().timeIntervalSince1970
        self.startTimer()
        
        self.bindKey = self.getBineKey()
        self.initData()
        self.step = .waitConnectDevice
        self.startConnectTime = Date().timeIntervalSince1970
        self.bleManager.connect(peripheral: peripheral)
    }
    
    func stopScan() {
        self.bleManager.cancelScan()
    }
    
//   private func connect(peripheral: CBPeripheral) {
//        if self.step.rawValue >= SCBindDeviceBluetoothStep.connectedWidthDevice.rawValue { return }
//        self.bindKey = self.getBineKey()
//        self.initData()
//        self.step = .waitConnectDevice
//        self.startConnectTime = Date().timeIntervalSince1970
//        self.bleManager.cancelScan()
//        self.bleManager.connect(peripheral: peripheral)
//    }
    
    func start(config: SCBindDeviceConfig,
               discoverPeripheralsHandle: (([CBPeripheral]) -> Void)?,
               stepHandler: ((SCBindDeviceBluetoothStep) -> Void)?,
               completionHandler: ((SCBindDeviceAccessPointResultType) -> Void)?,
               timeHandler: ((String) -> Void)? = nil) {
        self.stepBlock = stepHandler
        self.completionBlock = completionHandler
        self.timeBlock = timeHandler
        self.config = config
        
        self.discoverPeripheralsBlock = discoverPeripheralsHandle
        
        self.step = .start
        
        self.peripherals.removeAll()
        self.startTime = Date().timeIntervalSince1970
        self.startScan()
        self.startTimer()
    }
    
    /// 停止配网
    func stop(isTimeout: Bool = false) {
        self.stopScan()
        self.stopConnect()
        self.stopTimer()
        if self.step != .none && self.step != .success && !isTimeout {
            self.completionBlock?(SCBindDeviceAccessPointResultType.interrupt)
        }
//        self.step = .none
    }
    
    private func startScan() {
        self.peripherals.removeAll()
        self.bleManager.startScan()
    }
    
    private func stopConnect() {
        self.bleManager.disconnect()
//        self.bleManager.stop()
    }
    
    /// 开始定时器
    private func startTimer() {
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
                self?.timerHandler()
            })
            self.timeCount = 0
        }
    }
    
    /// 停止定时器
    private func stopTimer() {
        self.timeCount = 0
        self.timer?.invalidate()
        self.timer = nil
        self.stopSendDataTimer()
    }
    
    /// 定时执行函数
    private func timerHandler() {
        if self.step.rawValue >= SCBindDeviceBluetoothStep.waitConnectDevice.rawValue {
            self.timeCount += 1
            
            if Date().timeIntervalSince1970 - self.startConnectTime > self.timeoutDuration {
                self.timeoutHandler()
                return
            }
        }
        self.timeBlock?("log:" + self.bindKey + "_" + self.step.name + "_name:\(self.currentPeripheral?.name ?? "nil")" + "_" + String(self.timeCount))
        
        if self.step == .discoverCharacteristic {
            self.step = .sendingData
            self.startSendDataTimer()
        }
        if self.step == .receivedData || self.step == .loopGetBindingResult {
            self.step = .loopGetBindingResult
            SCSmartNetworking.sharedInstance.getDeviceBindAppResultRequest(bindKey: self.bindKey, familyId: self.config.familyId) { [weak self] response in
                guard let `self` = self else { return }
                if let model = response, self.sn == model.sn {
                    self.deviceId = model.deviceId
                    self.step = .gotBindingResult
                    self.step = .success
                    
                }
            } failure: { error in
                
            }
            
//#if DEBUG
//SCSmartNetworking.sharedInstance.getDeviceInfoRequest(sn: self.sn, mac: self.mac) { [weak self] info in
//    if let info = info, info.id.count > 0 {
//        self?.deviceId = info.id
//        self?.productId = info.productId
//        self?.step = .success
//    }
//} failure: { error in
//
//}
//#endif
        }
        if self.step == .gotBindingResult || self.step == .loopLocking {
            
        }
        if self.step == .success {
            self.stopTimer()
            self.completionBlock?(.success)
        }
    }
    
    private func startSendDataTimer() {
        if self.sendDataTimer == nil {
            self.sendDataTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
                guard let `self` = self else { return }
                self.sendDataTimerHandle()
            })
        }
    }
    
    private func stopSendDataTimer() {
        self.sendDataTimer?.invalidate()
        self.sendDataTimer = nil
    }
    
    private func sendDataTimerHandle() {
        if self.step.rawValue >= SCBindDeviceBluetoothStep.receivedData.rawValue {
            self.stopSendDataTimer()
            SCSDKLog("sendWifiTimerAction 已收到sn")
            return
        }
        SCSDKLog("sendWifiInfo - bindkey :\(wifiInfo?.key)")
//        let data = self.wifiInfo!.toData()
        let data = self.wifiInfo!.aesData
        guard let peripheral = self.currentPeripheral, let characteristic = self.writeCharacteristic else { return }
        self.bleManager.write(peripheral: peripheral, characteristic: characteristic, data: data)
        SCSDKLog("发送数据")
        guard let readCharacteristic = self.readCharacteristic else { return }
        self.bleManager.readCharacteristic(peripheral: peripheral, characteristic: readCharacteristic)
    }
}

extension SCBindDeviceBluetoothService {
    private func initData() {
        var info = SCBindDeviceAccessPointWifiData()
        info.uid = self.config.uid
        info.ssid = self.config.ssid
        info.password = self.config.password
        info.key = self.bindKey
        info.httpHost = self.config.domain.deviceApiHost
        info.httpPort = self.config.domain.deviceApiPort
        info.mqttHost = self.config.domain.mqttHost
        info.mqttPort = self.config.domain.mqttPort
#if DEBUG
//info.httpHost = "dev-sz-cn-devaiot.3irobotix.net"
        if info.httpHost == "test-sz-cn-devtaiot.3irobotix.net" {
            info.httpHost = "test-sz-cn-devaiot.3irobotix.net"
        }
        else if info.httpHost == "dev-sz-cn-devtaiot.3irobotix.net" {
            info.httpHost = "dev-sz-cn-devaiot.3irobotix.net"
        }
#endif
//
//        info.ssid = self.config.ssid
//        info.password = self.config.password
//        info.host = "ota.3irobotix.net"
//        info.port = 8005
//        info.uid = 92537
//        info.bindKey = self.bindKey
//        info.traceId = UInt32(Date().timeIntervalSince1970)
        self.wifiInfo = info
    }
    
    /// 超时
    private func timeoutHandler() {
        self.completionBlock?(.timeout)
        self.stop(isTimeout: true)
    }
    
    /// 获取绑定key
    private func getBineKey() -> String {
        let texts = """
        0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
        """.components(separatedBy: ",")
        let count = texts.count
        let one1 = texts[Int(arc4random() % UInt32(count))]
        let one2 = texts[Int(arc4random() % UInt32(count))]
        let one3 = texts[Int(arc4random() % UInt32(count))]
        let one4 = texts[Int(arc4random() % UInt32(count))]
        let key = one1 + one2 + one3 + one4
//        let bindKey = String(format: "%08d", WYNet.user?.id ?? 0) + key
        let bindKey = key
        return bindKey
    }
    
    /// 写入步骤日志
    private func writeBindLog(step: SCBindDeviceBluetoothStep) {
        let stepText = step.name
        let text = self.bindKey + "_" + stepText + "_" + "_wifi:\(SCLocalNetwork.sharedInstance.getSsid() ?? "nil")_" + getNowDateText()
//        self.delegate?.bindStepChangedLog(communicationType: .accessPoint, text: text, sn: self.sn)
        SCSDKLog("Bind device: \(text)")
    }
}


//struct SCConfigNetWifiInfoModel {
//    var ssid: String = ""
//    var password: String = ""
//    var host: String = ""
//    var port: UInt32 = 0
//    var uid: UInt32 = 0
//    var bindKey: String = ""
//    var traceId: UInt32 = 0
//
//    func toData() -> Data {
//        let json = ["uid": self.uid, "ssid": self.ssid, "pwd": self.password, "host": self.host, "port": self.port, "key": self.bindKey, "id": self.traceId] as [String: Any]
//        let data = try? JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.fragmentsAllowed)
//        return data ?? Data()
//    }
//
//    func toAesData() -> Data {
//        let json = ["uid": self.uid, "ssid": self.ssid, "pwd": self.password, "host": self.host, "port": self.port, "key": self.bindKey, "id": self.traceId] as [String: Any]
//        let jsonData = (try? JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.fragmentsAllowed)) ?? Data()
//        let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
//        let encryptString = SCSmartAESCode.aesEncrypt(content: jsonString, key: SCSmartNetworking.sharedInstance.aesKey)
//        let data = encryptString.data(using: .utf8) ?? Data()
//        SCSDKLog("wifi result encrypt:\(encryptString), encrypt key:\(SCSmartNetworking.sharedInstance.aesKey)")
//        return data
//    }
//}
