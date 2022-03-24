//
//  SCSmartNetMQTTService.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/8.
//

import UIKit
import MQTTClient
import sqlcipher

enum SCNetMQTTTopicType: Int {
    /// 设备上报的属性信息
    case propertyPostByDevice
    /// 设置设备属性
    case propertySetToDevice
    /// 设备回复属性设置
    case propertySetReplyByDevice
    /// 获取设备属性
    case propertyGetToDevice
    /// 设备回复属性获取
    case propertyGetReplyByDevice
    
    /// 设置设备服务
    case serviceSetToDevice
    /// 设备回复服务设置
    case serviceSetReplyByDevice
    
    /// 设备事件上报
    case eventPostByeDevice
    
    /// 通知设备ota
    case otaSetToDevice
    /// 设备上报ota进度
    case otaProgressPostByDevice
    /// 设备上报ota当前版本
    case otaVersionPostByDevice
    
    
    func method(identifier: String? = nil) -> String {
        switch self {
        case .propertyPostByDevice:
            return "prop.post"
        case .propertySetToDevice:
            return "prop.set"
        case .propertyGetToDevice:
            return "prop.get"
        case .serviceSetToDevice:
            return "service.\(identifier ?? "")"
        case .eventPostByeDevice:
            return "event.\(identifier ?? "")"
        case .otaSetToDevice:
            return "ota.upgrade"
        case .otaProgressPostByDevice:
            return "ota.progress"
        case .otaVersionPostByDevice:
            return "ota.inform"
        default:
            return ""
        }
    }
    
    func topic(productId: String, sn: String, identifier: String? = nil) -> String {
        switch self {
        case .propertyPostByDevice:
            return "/mqtt/\(productId)/\(sn)/thing/event/property/post"
        case .propertySetToDevice:
            return "/mqtt/\(productId)/\(sn)/thing/service/property/set"
        case .propertySetReplyByDevice:
            return "/mqtt/\(productId)/\(sn)/thing/service/property/set_reply"
        case .propertyGetToDevice:
            return "/mqtt/\(productId)/\(sn)/thing/service/property/get"
        case .propertyGetReplyByDevice:
            return "/mqtt/\(productId)/\(sn)/thing/service/property/get_reply"
        case .serviceSetToDevice:
            return "/mqtt/\(productId)/\(sn)/thing/service_invoke/\(identifier ?? "#")"
        case .serviceSetReplyByDevice:
            return "/mqtt/\(productId)/\(sn)/thing/service_invoke_reply/\(identifier ?? "#")"
        case .eventPostByeDevice:
            return "/mqtt/\(productId)/\(sn)/thing/event/\(identifier ?? "#")/post"
        case .otaSetToDevice:
            return "/ota/device/upgrade/\(productId)/\(sn)"
        case .otaProgressPostByDevice:
            return "/ota/device/progress/\(productId)/\(sn)"
        case .otaVersionPostByDevice:
            return "/ota/device/inform/\(productId)}/\(sn)"
        }
    }
    
    func subscribeTopic(productId: String, sn: String) -> String {
        switch self {
        case .propertyPostByDevice:
            return "/mqtt/\(productId)/\(sn)/thing/event/property/post"
        case .propertySetReplyByDevice:
            return "/mqtt/\(productId)/\(sn)/thing/service/property/set_reply"
        case .propertyGetReplyByDevice:
            return "/mqtt/\(productId)/\(sn)/thing/service/property/get_reply"
        case .serviceSetReplyByDevice:
            return "/mqtt/\(productId)/\(sn)/thing/service_invoke_reply/#"
        case .eventPostByeDevice:
            return "/mqtt/\(productId)/\(sn)/thing/event/#"
        case .otaProgressPostByDevice:
            return "/ota/device/progress/\(productId)/\(sn)"
        case .otaVersionPostByDevice:
            return "/ota/device/inform/\(productId)}/\(sn)"
        default:
            return ""
        }
    }
}

protocol SCSmartNetMQTTServiceDelegate: AnyObject {
    func status(_ service: SCSmartNetMQTTService, isConnected: Bool)
    
    func receiveMessage(_ service: SCSmartNetMQTTService, data: Data, topic: String)
}

/*
 mqtt 服务
 */
class SCSmartNetMQTTService {
    /// 代理
    weak var delegate: SCSmartNetMQTTServiceDelegate?
    /// 长连接是否建立
    var isConnected: Bool {
        return self.client.isConnected
    }
    /// mqtgt客户端
    private lazy var client: SCSmartNetMQTTClient = SCSmartNetMQTTClient()
    
    /// 建立mqtt连接
    func connect(config: SCSmartNetMQTTConfig) {
        self.client.connect(config: config, delegate: self)
    }
    /// 断开连接
    func disconnect() {
        self.client.disconnect()
    }
    /// 重连
    func reconnect() {
        self.client.reconnect()
    }
    /// 发送消息
    func sendData(_ topic: String, json: [String: Any], qos: MQTTQosLevel = .atMostOnce) {
        self.client.sendData(topic, json: json, qos: qos)
    }
    /// 发送消息
    func sendData(_ topic: String, data: Data, qos: MQTTQosLevel = .atMostOnce) {
        self.client.sendData(topic, data: data, qos: qos)
    }
    
    /// 订阅多个主题
    func subscribe(multTopics topics: [String]) {
        self.client.subscribe(multTopics: topics)
    }
    
    /// 取消所有订阅
    func unsubscribeAllTopics(handler: ((Bool) -> Void)? = nil) {
        self.client.unsubscribeAllTopics(handler: handler)
    }
    
    func getTopic(type: SCNetMQTTTopicType) -> String {
        
        
        return ""
    }
}

extension SCSmartNetMQTTService: SCSmartNetMQTTClientDelegate {
    /// 状态改变
    func status(_ client: SCSmartNetMQTTClient, isConnected: Bool) {
        self.delegate?.status(self, isConnected: isConnected)
    }
    /// 收到消息
    func receiveMessage(_ client: SCSmartNetMQTTClient, data: Data, topic: String) {
        self.delegate?.receiveMessage(self, data: data, topic: topic)
    }
}
