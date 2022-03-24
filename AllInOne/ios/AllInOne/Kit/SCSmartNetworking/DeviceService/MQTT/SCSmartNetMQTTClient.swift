//
//  SCSmartNetMQTTClient.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/8.
//

import UIKit
import MQTTClient

/// 重连时间间隔
private let kReconnectTimeInterval: TimeInterval = 2
/// 最大重连次数
private let kReconnectMaxCount: Int = 10
/// 最小连接时间间隔
private let kConnectMinTimeInterval: TimeInterval = 2
/// 没有收到消息的最大时间
private let kReceiveMessageMaxTimeInterval: TimeInterval = 10


protocol SCSmartNetMQTTClientDelegate: AnyObject {
    func status(_ client: SCSmartNetMQTTClient, isConnected: Bool)
    
    func receiveMessage(_ client: SCSmartNetMQTTClient, data: Data, topic: String)
}

class SCSmartNetMQTTClient: NSObject {
    /// 是否在线
    var isConnected: Bool {
        get {
            let isConnected = self.session?.status == .connected
            return isConnected
        }
    }
    
    /// 代理
    weak var delegate: SCSmartNetMQTTClientDelegate?
    
    /// 服务器保活时间间隔(服务器监听时间间隔会乘以1.5)
    var serverKeepAliveInterval: Int = 10
    /// 会话
    private var session: MQTTSession?
    /// 重连次数
    private var reconnectCount: Int = 0
    /// 是否为主动断开连接，主动断开连接不需要自动重连
    private var isDisconnect: Bool = false
    /// 自动重连定时器
    private var autoReconnectTimer: Timer?
    /// 客户端配置
    private var config: SCSmartNetMQTTConfig?
    /// 已经订阅的主题
    private var subscribedTopics: [String] = []
    /// 正在订阅的主题
    private var subsribingTopics: [String] = []
    /// 串行队列
    private let queue: DispatchQueue = DispatchQueue(label: "wynet.mqtt.queue")
    
    private var subscribeTimer: Timer?
    private var checkPingTimer: Timer?
    
    private var lastReceiveMessageTime: TimeInterval = 0
    
    
    override init() {
        super.init()
        #if DEBUG
        MQTTLog.setLogLevel(.debug)
        #endif
    }
    
    /// 连接服务器
    func connect(config: SCSmartNetMQTTConfig, delegate: SCSmartNetMQTTClientDelegate) {
        if self.config != nil && self.config!.checkConfigEquel(config: config) {
            if !self.isConnected {
                self.reconnect()
            }
            return
        }
        self.delegate = delegate
        self.config = config
        self.connect()
    }
    
    /// 连接服务器
    private func connect() {
        self.queue.async {
            guard let config = self.config, (config.url.count != 0 || config.host.count != 0)else { return }
            SCSDKLog("mqtt connect url:\(self.config!.url), host:\(self.config!.host), port:\(self.config!.port), clientId:\(self.config!.clientId), username:\(self.config!.username), password:\(self.config!.password)")
            
            if self.session != nil {
                self.disconnect()
            }
            
            self.isDisconnect = false
//            let transport = MQTTWebsocketTransport()
//            transport.url = URL(string: config.url)
            
//            let transport = MQTTCFSocketTransport()
//            transport.host = config.host
//            transport.port = config.port
            
            let transport = MQTTSSLSecurityPolicyTransport()
            transport.host = config.host
            transport.port = config.port
            transport.tls = true
//            let clientPath = Bundle.main.path(forResource: "mqtt_certificate", ofType: "p12")
//            transport.certificates = MQTTSSLSecurityPolicyTransport.clientCerts(fromP12: clientPath, passphrase: "sc666888")
            
            let policy = MQTTSSLSecurityPolicy(pinningMode: .certificate)
            policy?.allowInvalidCertificates = true
            policy?.validatesDomainName = false
            policy?.validatesCertificateChain = false
            let caPath = Bundle.main.path(forResource: "server", ofType: "der")!
            let data = NSData(contentsOfFile: caPath)!
            let caData = data as NSData
            policy?.pinnedCertificates = [caData]

            transport.securityPolicy = policy
            
            self.session = MQTTSession()
            self.session?.delegate = self
            self.session?.transport = transport
            self.session?.userName = config.username
            self.session?.password = config.password
            self.session?.clientId = config.clientId
            
//            self.session?.certificates = nil
            
            // 监听连接状态
            self.session?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            
            self.session?.keepAliveInterval = UInt16(self.serverKeepAliveInterval)
            
            self.queue.async {
                self.session?.connectAndWaitTimeout(1)
            }
        }
    }
    
    /// 重新连接
    func reconnect() {
        self.connect()
    }
    
    /// 主动断开连接
    func disconnect() {
//        self.queue.async {
            self.isDisconnect = true
            self.unsubscribeAllTopics()
            self.session?.disconnect()
            self.session?.delegate = nil
            // 移除状态监听
            self.session?.removeObserver(self, forKeyPath: "status")
            self.session = nil
//        }
    }
    
    /// 向对应主题发布消息, 设置qos
    func sendData(_ topic: String, json: [String: Any], qos: MQTTQosLevel = .atMostOnce) {
        self.queue.async {
            if let data = try? JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) {
                self.session?.publishData(data, onTopic: topic, retain: false, qos: qos)
            }
        }
    }
    
    /// 发送消息
    func sendData(_ topic: String, data: Data, qos: MQTTQosLevel = .atMostOnce) {
        self.session?.publishData(data, onTopic: topic, retain: false, qos: qos)
    }
    
    /// 订阅多个主题
    func subscribe(multTopics topics: [String]) {
        self.queue.async { [weak self] in
            guard let `self` = self else { return }
            var topicsText = ""
            var topicNumbers = [String: NSNumber]()
            for topic in topics {
                if let _ = self.subscribedTopics.filter({ $0 == topic }).first { // 已经订阅不需要重复订阅
                    continue
                }
                topicsText += topic + "\n"
                topicNumbers[topic] = NSNumber(value: MQTTQosLevel.atMostOnce.rawValue)
                if let _ = self.subsribingTopics.filter({ $0 == topic }).first {
                    
                }
                else {
                    self.subsribingTopics.append(topic)
                }
            }
            if topicsText.count == 0 {
                return
            }
            SCSDKLog("mqtt subscribe start topics:\(topics.joined(separator: ","))")
            self.session?.subscribe(toTopics: topicNumbers, subscribeHandler: { (error, qoses) in
                if let error = error {
                    SCSDKLog("mqtt subscribe fail topics:\(topics.joined(separator: ",")), error:\(error.localizedDescription)")
                }
                else {
                    SCSDKLog("mqtt subscribe success topics:\(topics.joined(separator: ","))")
                    
                    for topic in topics {
                        self.subscribedTopics.append(topic)
                    }
                    
                    var temp: [String] = []
                    for topic in self.subsribingTopics {
                        if let _ = self.subscribedTopics.filter({ $0 == topic }).first {
                            continue
                        }
                        temp.append(topic)
                    }
                    self.subsribingTopics = temp
                }
            })
            self.startSubscribeTiemr()
        }
    }
    
    /// 取消所有订阅
    func unsubscribeAllTopics(handler: ((Bool) -> Void)? = nil) {
        let topics = self.subscribedTopics
        if topics.count == 0 {
            return
        }
        self.queue.async {
            self.subsribingTopics.removeAll()
            self.subscribedTopics.removeAll()
            SCSDKLog("mqtt unsubscribe topics:\(topics.joined(separator: ","))")
            self.session?.unsubscribeTopics(topics, unsubscribeHandler: { (error) in
                if let error = error {
                    SCSDKLog("mqtt unsubscribe fail topics:\(topics.joined(separator: ",")), error:\(error.localizedDescription)")
                    handler?(false)
                }
                else {
                    SCSDKLog("mqtt unsubscribe success topics:\(topics.joined(separator: ","))")
                    handler?(true)
                }
            })
            self.stopSubscribeTimer()
        }
    }
    
    /// 发送心跳
    private func sendPingMessage() {
        guard let data = MQTTMessage.pingreq()?.wireFormat else { return }
        self.session?.transport.send(data)
    }
    
    /// 开始自动重连
    func autoReconnect(_ isManual: Bool = false) {
        if isManual {
            self.isDisconnect = false
        }
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if self.isDisconnect {
                return
            }
            
            if self.autoReconnectTimer != nil {
                return
            }
            
            self.autoReconnectTimer = Timer.scheduledTimer(timeInterval: kReconnectTimeInterval, target: self, selector: #selector(self.autoReconnectTimerAction), userInfo: nil, repeats: true)
            self.autoReconnectTimer?.fire()
        }
    }
    
    /// 自动重连
    @objc private func autoReconnectTimerAction() {
        self.queue.async {
            if self.isConnected {
                self.autoReconnectTimer?.invalidate()
                self.autoReconnectTimer = nil
                self.reconnectCount = 0
                return
            }
            if self.reconnectCount > kReconnectMaxCount {
                self.autoReconnectTimer?.invalidate()
                self.autoReconnectTimer = nil
                self.reconnectCount = 0
                return
            }
            self.reconnectCount += 1
            self.session?.connectAndWaitTimeout(1)
        }
    }
    
    /// 开始检查
    private func startCheckPingTiemr() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if self.checkPingTimer != nil {
                return
            }
            self.checkPingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkPingTimerAction), userInfo: nil, repeats: true)
            self.checkPingTimer?.fire()
        }
    }
    
    private func stopCheckPingTiemr() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.checkPingTimer?.invalidate()
            self.checkPingTimer = nil
        }
    }
    
    private func startSubscribeTiemr() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if self.subscribeTimer != nil {
                return
            }
            self.subscribeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.subscriberTimerAction), userInfo: nil, repeats: true)
        }
    }
    
    private func stopSubscribeTimer() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.subscribeTimer?.invalidate()
            self.subscribeTimer = nil
        }
    }
    
    @objc private func subscriberTimerAction() {
        if self.subsribingTopics.count > 0 {
            self.subscribe(multTopics: self.subsribingTopics)
        }
        else {
            self.stopSubscribeTimer()
        }
    }
    
    @objc private func checkPingTimerAction() {
        self.queue.async {
            if Date().timeIntervalSince1970 - self.lastReceiveMessageTime > kReceiveMessageMaxTimeInterval {
                SCSDKLog("mqtt 接收消息时间间隔超过\(kReceiveMessageMaxTimeInterval), 发送心跳")
                self.sendPingMessage()
            }
        }
    }
}


extension SCSmartNetMQTTClient {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch self.session?.status {
        case .closed:
            // 非主动断开时，重连
            SCSDKLog("MQTT关闭链接")
            if !self.isDisconnect {
                self.autoReconnect()
            }
            break
        case .connected:
            SCSDKLog("MQTT连接成功")
            self.isDisconnect = false
            // 取消延迟
            
            // 连接成功订阅全局主题以及发送用户上线提醒
//            self.resubscribeTopices()
            break
        case .connecting:
            SCSDKLog("MQTT连接中")
            break
        case .error:
            SCSDKLog("MQTT连接错误")
            // 非主动断开时，重连
            if !self.isDisconnect {
                self.autoReconnect()
            }
            break
        case .disconnecting:
            SCSDKLog("MQTT正在断开连接")
            if !self.isDisconnect {
                SCSDKLog("MQTT disconnecting autoReconnect")
                self.autoReconnect()
            }
            break
        default:
            break
        }
        
        self.delegate?.status(self, isConnected: self.isConnected)
    }
}

extension SCSmartNetMQTTClient: MQTTSessionDelegate {
    func newMessage(_ session: MQTTSession!, data: Data!, onTopic topic: String!, qos: MQTTQosLevel, retained: Bool, mid: UInt32) {
        self.delegate?.receiveMessage(self, data: data, topic: topic)
    }
    
    func received(_ session: MQTTSession!, type: MQTTCommandType, qos: MQTTQosLevel, retained: Bool, duped: Bool, mid: UInt16, data: Data!) {
        self.lastReceiveMessageTime = Date().timeIntervalSince1970
    }
}
