//
//  SCSmartNetDeviceService.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/1.
//

import UIKit

typealias SCSmartNetDeviceServiceBlock = (_ response: SCSmartNetDeviceServiceResponse) -> Void
typealias SCSmartNetDeviceServicePropertyPushBlock = ([String: Any]) -> Void
fileprivate let SCNetDeviceServiceTimeoutInterval: TimeInterval = 10

class SCSmartNetDeviceServiceCallbackModel {
    var hashValue: Int?
    var callback: SCSmartNetDeviceServiceBlock?
    /// 时间戳，用于计算超时，发送命令时赋值
    var timestamp: TimeInterval = 0
    
    init(_ hashValue: Int?, timestamp: TimeInterval?, callback: SCSmartNetDeviceServiceBlock?) {
        self.hashValue = hashValue
        self.callback = callback
        if timestamp != nil {
            self.timestamp = timestamp!
        }
    }
}

class SCSmartNetDeviceService {
    /// 长连接是否在线
    var isConnected: Bool {
        switch self.serviceType {
        case .mqtt:
            return self.mqttService.isConnected
        case .webSocket:
            return self.webSocketService.isConnected
        }
    }
    /// websocket服务
    private lazy var webSocketService: SCSmartNetWebSocketService = {
        let service = SCSmartNetWebSocketService()
        service.delegate = self
        return service
    }()
    /// MQTT服务
    private lazy var mqttService: SCSmartNetMQTTService = {
        let service = SCSmartNetMQTTService()
        service.delegate = self
        return service
    }()
    /// 长连接类型
    private var serviceType: SCSmartDeviceServiceType = .mqtt
    /// websocket地址
    private var wss: String = ""
    /// MQTT配置信息
    private var mqttConfig: SCSmartNetMQTTConfig = SCSmartNetMQTTConfig()
    
    private var tenantId: String = ""
    
    private var productId: String = ""
    private var sn: String = ""
    
    private let serviceQueue = DispatchQueue(label: "scnet.deviceservice.queue", qos: DispatchQoS.default, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
    
    /// 超时计时器
    private var timeoutTimer: Timer?
    
    private var messageCallbacks: [String: SCSmartNetDeviceServiceCallbackModel] = [:]
    
    private var propertyCallbacks: [SCSmartNetDeviceServicePropertyPushBlock?] = []
    
    private var propertySubscribeTopic: String = ""
    
    private var replySubscribeTopics: [String] = []
    
    init() {
        self.setupTimer()
    }
    
    /// 重连
    func reconnect() {
        if self.serviceType == .webSocket {
            self.webSocketService.reconnectByManually()
        }
        else if self.serviceType == .mqtt {
            self.mqttService.reconnect()
        }
    }
    
    /// 主动断开连接，不会触发重连
    func disconnect() {
        if self.serviceType == .webSocket {
            self.webSocketService.disconnect()
        }
        else if self.serviceType == .mqtt {
            self.mqttService.disconnect()
        }
    }
    
    func set(mqttHost: String, mqttPort: Int) {
        self.mqttConfig.host = mqttHost
        self.mqttConfig.port = UInt32(mqttPort)
        
        if self.serviceType == .webSocket {
            self.webSocketService.connect(host: wss)
        }
        else if self.serviceType == .mqtt {
            self.connectMqttService()
        }
    }
    
    /// 设置ws地址和MQTT地址
    /// - Parameters:
    ///   - wss: ws地址
    ///   - mqttUrl: mqtt地址
    func set(wss: String, mqttUrl: String) {
//        if wss == self.wss { return }
        self.wss = wss
        self.mqttConfig.url = mqttUrl
        
        if self.serviceType == .webSocket {
            self.webSocketService.connect(host: wss)
        }
        else if self.serviceType == .mqtt {
            self.connectMqttService()
        }
    }
    
    /// 设置长连接类型
    /// - Parameter type: 长连接类型
    func set(serviceType type: SCSmartDeviceServiceType) {
        if type == self.serviceType { return }
        
        self.serviceType = type
        if type == .webSocket {
            self.webSocketService.connect(host: self.wss)
        }
        else if type == .mqtt {
            self.connectMqttService()
        }
    }
    
    /// 设置用户名和token，MQTT连接使用
    /// - Parameters:
    ///   - username: 用户名
    ///   - mqttToken: token
    func set(username: String, mqttToken: String, tenantId: String) {
        self.mqttConfig.username = username
        self.mqttConfig.password = mqttToken
        self.mqttConfig.clientId = "\(username)"
        self.tenantId = tenantId
        
        self.connectMqttService()
    }
    
    func set(productId: String, sn: String) {
        self.productId = productId
        self.sn = sn
        self.unsubscribeAll()
        self.autoSubscribeTopics()
        
        self.propertySubscribeTopic = SCNetMQTTTopicType.propertyPostByDevice.subscribeTopic(productId: self.productId, sn: self.sn)
        self.replySubscribeTopics = [
            SCNetMQTTTopicType.propertySetReplyByDevice.subscribeTopic(productId: self.productId, sn: self.sn),
            SCNetMQTTTopicType.propertyGetReplyByDevice.subscribeTopic(productId: self.productId, sn: self.sn),
            SCNetMQTTTopicType.serviceSetReplyByDevice.subscribeTopic(productId: self.productId, sn: self.sn)
        ]
    }
    
    func unsubscribeAll() {
        self.mqttService.unsubscribeAllTopics()
    }
    
    func setProperty(_ target: AnyObject?, message: [String: Any], callback: SCSmartNetDeviceServiceBlock?) {
        var hashValue: Int = 0
        if target != nil {
            let point = Unmanaged<AnyObject>.passUnretained(target!).toOpaque()
            hashValue = point.hashValue
        }
        self.serviceQueue.sync { [weak self] in
            guard let `self` = self else { return }
            let type = SCNetMQTTTopicType.propertySetToDevice
            let topic = type.topic(productId: self.productId, sn: self.sn)
            var body: [String: Any] = [:]
            let msgId = self.makeMessageId()
            body["msgId"] = msgId
            body["version"] = "1.0"
            body["tenantId"] = self.tenantId
            body["method"] = type.method()
            body["params"] = message
            
            SCSDKLog("device set property topic:\(topic),\n message:\(body)")
            
            self.mqttService.sendData(topic, json: body)
            
            if callback != nil {
                self.messageCallbacks[msgId] = SCSmartNetDeviceServiceCallbackModel(hashValue, timestamp: Date().timeIntervalSince1970, callback: callback)
            }
        }
    }
    
    func getProperty(_ target: AnyObject?, message: [String: Any], callback: SCSmartNetDeviceServiceBlock?) {
        var hashValue: Int = 0
        if target != nil {
            let point = Unmanaged<AnyObject>.passUnretained(target!).toOpaque()
            hashValue = point.hashValue
        }
        self.serviceQueue.sync { [weak self] in
            guard let `self` = self else { return }
            let type = SCNetMQTTTopicType.propertyGetToDevice
            let topic = type.topic(productId: self.productId, sn: self.sn)
            var body: [String: Any] = [:]
            let msgId = self.makeMessageId()
            body["msgId"] = msgId
            body["version"] = "1.0"
            body["tenantId"] = self.tenantId
            body["method"] = type.method()
            body["params"] = message
            
            SCSDKLog("device set getProperty topic:\(topic),\n message:\(body)")
            self.mqttService.sendData(topic, json: body)
            
            if callback != nil {
                self.messageCallbacks[msgId] = SCSmartNetDeviceServiceCallbackModel(hashValue, timestamp: Date().timeIntervalSince1970, callback: callback)
            }
        }
    }
    
    func setService(_ target: AnyObject?, identifer: String, message: [String: Any], callback: SCSmartNetDeviceServiceBlock?) {
        var hashValue: Int = 0
        if target != nil {
            let point = Unmanaged<AnyObject>.passUnretained(target!).toOpaque()
            hashValue = point.hashValue
        }
        self.serviceQueue.sync { [weak self] in
            guard let `self` = self else { return }
            let type = SCNetMQTTTopicType.serviceSetToDevice
            let topic = type.topic(productId: self.productId, sn: self.sn, identifier: identifer)
            var body: [String: Any] = [:]
            let msgId = self.makeMessageId()
            body["msgId"] = msgId
            body["version"] = "1.0"
            body["tenantId"] = self.tenantId
            body["method"] = type.method(identifier: identifer)
            body["params"] = message
            
            SCSDKLog("device set service topic:\(topic),\n message:\(body)")
            self.mqttService.sendData(topic, json: body)
            
            if callback != nil {
                self.messageCallbacks[msgId] = SCSmartNetDeviceServiceCallbackModel(hashValue, timestamp: Date().timeIntervalSince1970, callback: callback)
            }
        }
    }
    
    func subscribePropertyPush(callback: SCSmartNetDeviceServicePropertyPushBlock?) {
        self.propertyCallbacks.append(callback)
    }
    
    private func autoSubscribeTopics() {
//        let types:[SCNetMQTTTopicType] = [.propertyPostByDevice, .propertySetReplyByDevice, .propertyGetReplyByDevice, .serviceSetReplyByDevice, .eventPostByeDevice, .otaProgressPostByDevice, .otaVersionPostByDevice]
        let types: [SCNetMQTTTopicType] = [.propertyPostByDevice, .propertySetReplyByDevice, .propertyGetReplyByDevice, .serviceSetReplyByDevice]
        let topics = types.map{ $0.subscribeTopic(productId: self.productId, sn: self.sn) }
        self.mqttService.subscribe(multTopics: topics)
    }
    
    /// 连接MQTT
    private func connectMqttService() {
        if self.serviceType != .mqtt { return }
        if !self.mqttConfig.checkConfigReady() { return }
        self.mqttService.connect(config: self.mqttConfig)
    }
}

// MARK: - SCSmartNetWebSocketServiceDelegate
extension SCSmartNetDeviceService: SCSmartNetWebSocketServiceDelegate {
    /// 长连接已建立
    func socket(didConnected socket: SCSmartNetWebSocketService) {
        
    }
    /// 长连接已断开
    func socket(_ socket: SCSmartNetWebSocketService, disconnect error: Error) {
        
    }
    /// 收到消息
    func socket(_ socket: SCSmartNetWebSocketService, didReceiveMessage data: Data) {
        
    }
}

// MARK: - SCSmartNetMQTTServiceDelegate
extension SCSmartNetDeviceService: SCSmartNetMQTTServiceDelegate {
    /// 长连接状态改变
    func status(_ service: SCSmartNetMQTTService, isConnected: Bool) {
        if isConnected { // 重订阅
            if self.productId.count > 0 && self.sn.count > 0 {
                self.set(productId: self.productId, sn: self.sn)
            }
        }
    }
    
    /// 收到消息
    func receiveMessage(_ service: SCSmartNetMQTTService, data: Data, topic: String) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
            SCSDKLog("mqtt res topic:\(topic), content json:\(json.description)")
            if topic == self.propertySubscribeTopic {
                var tempArray: [SCSmartNetDeviceServicePropertyPushBlock] = []
                for callback in self.propertyCallbacks {
                    if let callback = callback {
                        tempArray.append(callback)
                        callback(json)
                    }
                }
                self.propertyCallbacks = tempArray
            }
            else if let _ = self.replySubscribeTopics.first(where: { return topic.hasPrefix($0) }) {
                if let msgId = json["msgId"] as? String {
                    let item = self.messageCallbacks[msgId]
                    var response = SCSmartNetDeviceServiceResponse()
                    response.msgId = msgId
                    response.code = (json["code"] as? Int) ?? -1
                    response.data = json["data"] as? [String: Any]
                    response.json = json
                    item?.callback?(response)
                }
            }
        }
        else {
            SCSDKLog("mqtt res topic:\(topic), content data length:\(data.count)")
        }
        
    }
}


extension SCSmartNetDeviceService {
    private func makeMessageId() -> String {
        let time = Date().timeIntervalSince1970
        let random = arc4random() % UInt32(999) + 100
        let id = String(UInt64(time)) + String(random)
        return id
    }
}

extension SCSmartNetDeviceService {
    private func setupTimer() {
        SCMainAsyncQueue { [weak self] in
            if self?.timeoutTimer != nil { return }
            self?.timeoutTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                self?.timeoutTimerHandler()
            })
            self?.timeoutTimer?.fire()
        }
    }
    
    private func timeoutTimerHandler() {
        self.serviceQueue.async { [weak self] in
            guard let `self` = self else { return }
            let nowTimestamp = Date().timeIntervalSince1970
            for (msgId, item) in self.messageCallbacks {
                if nowTimestamp - item.timestamp > SCNetDeviceServiceTimeoutInterval {
                    var response = SCSmartNetDeviceServiceResponse()
                    response.msgId = msgId
                    response.error = .timeout
                    SCMainAsyncQueue {
                        item.callback?(response)
                        item.callback = nil
                        self.messageCallbacks.removeValue(forKey: msgId)
                    }
                }
            }
        }
    }
}
