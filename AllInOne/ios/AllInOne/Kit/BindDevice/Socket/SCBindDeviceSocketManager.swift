//
//  SCBindDeviceSocketManager.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/29.
//

import UIKit
import CocoaAsyncSocket


/// 与设备本地通信的命令类型
enum SCBindDeviceSocketManagerCommandType: Int {
    /// 连接超时
    case connectTimeout = -1
    /// 接收数据超时
    case readDataTimeout = -2
    /// 写入数据到设备
    case writeDataToDevice = 101
    /// 读取设备的数据
    case receiveDataFromDevice = 102
    /// 停止与设备通信
    case stop = 105
}

struct SCBindDeviceAccessPointWifiData {
    /// 用户ID
    var uid: String = ""
    /// WiFi名称
    var ssid: String = ""
    /// WiFi密码
    var password: String = ""
    /// http域名
    var httpHost: String = ""
    /// http端口号
    var httpPort: Int = 0
    /// mqtt 域名
    var mqttHost: String = ""
    /// 端口号
    var mqttPort: Int = 0
    /// 绑定key
    var key: String = ""
    
    var json: [String: Any] {
        var json: [String: Any] = [:]
        json["uid"] = uid
        json["ssid"] = ssid
        json["pwd"] = password
        json["key"] = key
        json["http_host"] = self.httpHost
        if self.httpPort > 0 {
//            json["http_port"] = self.httpPort
        }
        json["mqtt_host"] = self.mqttHost
        if self.mqttPort > 0 {
            json["mqtt_port"] = self.mqttPort
        }
        return json
    }
    
    var aesData: Data {
        let jsonData = (try? JSONSerialization.data(withJSONObject: self.json, options: .fragmentsAllowed)) ?? Data()
        let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
        let encryptString = SCSmartAESCode.aesEncrypt(content: jsonString, key: SCSmartNetworking.sharedInstance.aesKey)
        SCSDKLog("wifi encrypt:\(encryptString)")
        let data = encryptString.data(using: .utf8) ?? Data()
        return data
    }
}

/*
 与设备的本地通信管理类
 */
class SCBindDeviceSocketManager: NSObject {
    static let sharedInstance = SCBindDeviceSocketManager()
    /// 超时时间
    private var timeoutDuration: TimeInterval = 30
    /// 开始时间
    private var startTimeInterval: TimeInterval = 0
    /// socket
    private var socket: GCDAsyncSocket?
    /// 域名
    private var host: String = "192.168.5.1"
    /// 端口号
    private var port: UInt16 = 6008
    /// 定时器
    private var timer: Timer?
    /// 发送的data
    private var sendData: Data?
    /// 接收消息的回调
    private var finishedCallback: ((SCBindDeviceSocketManagerCommandType, [String: Any]?) -> Void)?
    /// 连接上设备的回调
    private var connectedCallback: (() -> Void)?
    /// 接收的head数据
    private var receiveHead: SCBindDeviceAccessPointHeadData?
    /// 用于拼接body数据
    private var receiveBodyData: Data = Data()
    /// 是否开始连接，开始时置为true，连接成功后置为false
    private var isStart: Bool = false
    /// 头部标志
    private var headFlag: Int = 0x51589158
    
    /// 开始连接设备，并与设备通信
    /// - Parameters:
    ///   - userId: uid
    ///   - ssid: WiFi名称
    ///   - password: WiFi密码
    ///   - key: 绑定key
    ///   - domain: 域名模型
    ///   - callback: 回调
    func start(uid: String, ssid: String, password: String, key: String, domain: SCNetResponseDomainModel, connectedCallback: @escaping (() -> Void), finishedCallback: @escaping ((SCBindDeviceSocketManagerCommandType, [String: Any]?) -> Void)) {
        if self.socket != nil {
            self.stop()
        }
        
        self.isStart = true
        self.connectedCallback = connectedCallback
        self.finishedCallback = finishedCallback
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        self.startTimer()
        self.connect()
        
        var body = SCBindDeviceAccessPointWifiData()
        body.uid = uid
        body.ssid = ssid
        body.password = password
        body.key = key
        body.httpHost = domain.deviceApiHost
        body.httpPort = domain.deviceApiPort
        body.mqttHost = domain.mqttHost
        body.mqttPort = domain.mqttPort
//        body.otaHost = domain.deviceOtaHost
//        body.otaPort = domain.deviceOtaPort
        
        #if DEBUG
//        body.httpHost = "dev-sz-cn-devaiot.3irobotix.net"
        if body.httpHost == "test-sz-cn-devtaiot.3irobotix.net" {
            body.httpHost = "test-sz-cn-devaiot.3irobotix.net"
        }
        else if body.httpHost == "dev-sz-cn-devtaiot.3irobotix.net" {
            body.httpHost = "dev-sz-cn-devaiot.3irobotix.net"
        }
        #endif
        
        let bodyData = body.aesData
        let headData = self.headData(type: .writeDataToDevice, length: bodyData.count)

        self.sendData = headData + bodyData
        
        self.receiveHead = nil
        self.receiveBodyData = Data()
        self.startTimeInterval = Date().timeIntervalSince1970
        
        SCSDKLog("TCP socket: start json:\(body.json)")
    }
    
    /// 开始连接设备，并与设备通信
    /// - Parameters:
    ///   - userId: uid
    ///   - ssid: WiFi名称
    ///   - password: WiFi密码
    ///   - host: 服务器域名
    ///   - port: 端口号
    ///   - key: 绑定key
    ///   - callback: 回调
    func start(uid: String, ssid: String, password: String, host: String, port: Int, key: String, connectedCallback: @escaping (() -> Void), finishedCallback: @escaping ((SCBindDeviceSocketManagerCommandType, [String: Any]?) -> Void)) {
        if self.socket != nil {
            self.stop()
        }
        
        self.isStart = true
        self.connectedCallback = connectedCallback
        self.finishedCallback = finishedCallback
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        self.startTimer()
        self.connect()
        
        var body = SCBindDeviceAccessPointWifiData()
        body.uid = uid
        body.ssid = ssid
        body.password = password
//        body.host = host
//        body.port = port
        body.key = key
        let bodyData = body.aesData
        let headData = self.headData(type: .writeDataToDevice, length: bodyData.count)

        self.sendData = headData + bodyData
        
        #if DEBUG
        do {
            var msg = SCDeviceAccessPointWifiData()
            msg.userId = Int32(uid) ?? 0
            msg.ssid = self.get32CharsByString(string: ssid)
            msg.password = self.get32CharsByString(string: password)
            msg.key = self.get16CharsByString(string: key)
            msg.host = self.get32CharsByString(string: host)
            msg.port = Int32(port)
            let msgData = NSData(bytes: &msg, length: MemoryLayout<SCBindDeviceAccessPointWifiData>.size) as Data
            let headData = self.headData(type: .writeDataToDevice, length: msgData.count)
            self.sendData = headData + msgData
        }
        #endif
        
        self.receiveHead = nil
        self.receiveBodyData = Data()
        self.startTimeInterval = Date().timeIntervalSince1970
        
        SCSDKLog("TCP socket: start uid:\(uid), ssid:\(ssid), pwd:\(password), host:\(host), prot:\(port), key:\(key)")
    }
    
    /// 停止与设备的本地通信
    func stop() {
        SCSDKLog("TCP socket: stop connect")
        self.isStart = false
        self.socket?.write(self.headData(type: .stop, length: MemoryLayout<SCBindDeviceAccessPointWifiData>.size), withTimeout: -1, tag: 0)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) { [weak self] in
            guard let `self` = self else { return }
            self.stopTimer()
            self.socket?.disconnect()
            self.socket = nil
            self.sendData = nil
        }
    }
    
    /// 开始连接设备
    private func connect() {
        try? self.socket?.connect(toHost: self.host, onPort: self.port)
        SCSDKLog("TCP socket: connect host:\(self.host), port:\(self.port), current wifi:\(SCLocalNetwork.sharedInstance.getSsid() ?? "nil")")
    }
    
    /// 开启定时器
    private func startTimer() {
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
                guard let `self` = self else { return }
                self.timerHandler()
            })
        }
    }
    
    /// 停止定时器
    private func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    /// 定时任务
    private func timerHandler() {
        guard let socket = self.socket else { return }
        if Date().timeIntervalSince1970 - self.startTimeInterval > self.timeoutDuration {
            if socket.isConnected {
                SCSDKLog("TCP socket: read data timeout \(self.timeoutDuration)s")
                self.finishedCallback?(SCBindDeviceSocketManagerCommandType.readDataTimeout, nil)
            }
            else {
                SCSDKLog("TCP socket: connect device timeout \(self.timeoutDuration)s")
                self.finishedCallback?(SCBindDeviceSocketManagerCommandType.connectTimeout, nil)
            }
            self.stop()
            return
        }
        if socket.isConnected {
            self.socket?.readData(withTimeout: -1, tag: 0)
            socket.write(self.sendData, withTimeout: -1, tag: 0)
            SCSDKLog("TCP socket: write data length: \(self.sendData?.count ?? 0)")
        }
        else if self.isStart {
            self.connect()
        }
    }
    
    /// 头部data
    private func headData(type: SCBindDeviceSocketManagerCommandType, length: Int) -> Data {
        var head = SCBindDeviceAccessPointHeadData()
        head.head_flag = 0x51589158
        head.cmd_id = UInt32(type.rawValue)
        head.len = UInt32(length)
        let headData = NSData(bytes: &head, length: MemoryLayout<SCBindDeviceAccessPointHeadData>.size) as Data
        return headData
    }
}

extension SCBindDeviceSocketManager: GCDAsyncSocketDelegate {
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        SCSDKLog("TCP socket: connected")
        self.isStart = false
        self.connectedCallback?()
        self.timerHandler()
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        SCSDKLog("TCP socket: disconnect\(err == nil ? "" : "error: \(err!.localizedDescription)")")
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        // 1.截取前4个字节，与头部标记对比
        // 2.头部标记匹配成功后，截取data的前20个字节，转成Head
        // 3.匹配cmd并获取Head中的长度，将剩余数据和下个包数据拼装body data，并转成json
        
        print("TCP socket: read length \(data.count)")
        var resultData = data
        let headLength = MemoryLayout<SCBindDeviceAccessPointHeadData>.size
        if data.count >= headLength {
            let flagData = (data as NSData).subdata(with: NSRange(location: 0, length: 4))
            let flagBytes = flagData.bytes
            let flag = Int(flagBytes[3]) << 24 + Int(flagBytes[2]) << 16 + Int(flagBytes[1]) << 8 + Int(flagBytes[0])
            if flag == self.headFlag {
                let headData = (data as NSData).subdata(with: NSRange(location: 0, length: headLength))
                var head: SCBindDeviceAccessPointHeadData = SCBindDeviceAccessPointHeadData()
                (headData as NSData).getBytes(&head, range: NSRange(location: 0, length: headData.count))
                SCSDKLog("TCP socket: read head data length:\(headData.count), cmd:\(head.cmd_id)")
                self.receiveHead = head
                self.receiveBodyData = Data()
                resultData = (data as NSData).subdata(with: NSRange(location: headLength, length: data.count - headLength))
            }
        }
        guard let head = self.receiveHead, let commandType = SCBindDeviceSocketManagerCommandType(rawValue: Int(head.cmd_id)) else { return }
        let needLength = Int(head.len) - self.receiveBodyData.count
        if resultData.count >= needLength {
            let subdata = (resultData as NSData).subdata(with: NSRange(location: 0, length: needLength))
            self.receiveBodyData += subdata
            if commandType == .receiveDataFromDevice {
                let encryptString = String(data: self.receiveBodyData, encoding: .utf8) ?? ""
                SCSDKLog("收到AP字符串数据：\(encryptString)")
                let decryptString = SCSmartAESCode.aesDecrypt(content: encryptString, key: SCSmartNetworking.sharedInstance.aesKey)
                let jsonData = decryptString.data(using: .utf8) ?? Data()
                if let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) as? [String: Any] {
                    self.finishedCallback?(commandType, json)
                    SCSDKLog("TCP socket: read data length:\(data.count), cmd:\(commandType) json:\(json)")
                }
            }
        }
    }
}

extension SCBindDeviceSocketManager {
    func get32CharsByString(string: String) ->  (Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8) {
        let data = string.data(using: .utf8) ?? Data()
        let dataT = (data as NSData)
        let count = 32
        var ints = [Int8].init(repeating: 0, count: count)
        var int : Int8 = 0
        for i in 0..<count {
            if i < data.count {
                dataT.getBytes(&int, range: NSMakeRange(i, 1))
                ints[i] = int
            }
        }
        return (ints[0], ints[1], ints[2], ints[3], ints[4], ints[5], ints[6], ints[7], ints[8], ints[9],
                ints[10],ints[11],ints[12],ints[13],ints[14],ints[15],ints[16],ints[17],ints[18],ints[19],
                ints[20],ints[21],ints[22],ints[23],ints[24],ints[25],ints[26],ints[27],ints[28],ints[29],
                ints[30],ints[31])
    }
    
    func get16CharsByString(string: String) ->  (Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8) {
        let data = string.data(using: .utf8) ?? Data()
        let dataT = (data as NSData)
        let count = 32
        var ints = [Int8].init(repeating: 0, count: count)
        var int : Int8 = 0
        for i in 0..<count {
            if i < data.count {
                dataT.getBytes(&int, range: NSMakeRange(i, 1))
                ints[i] = int
            }
        }
        return (ints[0], ints[1], ints[2], ints[3], ints[4], ints[5], ints[6], ints[7], ints[8], ints[9],
                ints[10],ints[11],ints[12],ints[13],ints[14],ints[15])
    }
}
