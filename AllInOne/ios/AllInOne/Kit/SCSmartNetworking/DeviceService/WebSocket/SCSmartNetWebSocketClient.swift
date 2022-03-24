//
//  SCSmartNetWebSocketClient.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/8.
//

import UIKit
import Starscream

/// 发送心跳包时间间隔
private let kHeartBeatTimeInterval: TimeInterval = 10
/// 重连时间间隔
private let kReconnectTimeInterval: TimeInterval = 3
/// 最大重连次数
private let kReconnectMaxCount: Int = 10
/// 最小连接时间间隔
private let kConnectMinTimeInterval: TimeInterval = 2

public protocol SCSmartWebSocketClientDelegate: AnyObject {
    /// The connection is successful.
    func socket(didConnected socket: SCSmartNetWebSocketClient)
    /// Receives a message.
    func socket(_ socket: SCSmartNetWebSocketClient, didReceiveMessage data: Data)
    /// Closes the connection.
    func socket(_ socket: SCSmartNetWebSocketClient, disconnect error: Error)
}

extension SCSmartWebSocketClientDelegate {
    func socket(didConnected socket: SCSmartNetWebSocketClient) { }
    func socket(_ socket: SCSmartNetWebSocketClient, didReceiveMessage data: Data) { }
    func socket(_ socket: SCSmartNetWebSocketClient, disconnect error: Error) { }
}

public class SCSmartNetWebSocketClient {
    /// Connection Status
    public var isConnected: Bool = false
    
    private var socket: WebSocket?
    /// 自动重连定时器
    private var autoReconnectTimer: Timer?
    /// 发送心跳定时器
    private var heartBeatTimer: Timer?
    /// 代理
    private var delegates: [SCSmartWebSocketClientDelegate] = []
    /// webSocket 服务器地址
    private var host: String = ""
    /// 最后连接时间(防止短时间内重复连接)
    private var lastConnectTime: TimeInterval = 0
    /// 重连次数
    private var reconnectCount: Int = 0
    /// 是否为手动断开连接，手动断开连接不需要自动重连
    private var isDisconnectByManually: Bool = false
    
    private var isFirstConnect: Bool = false
    
    func connect(host: String) {
        guard let url = URL(string: host) else { return }
        if host == self.host {
            return
        }
        self.host = host
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        if self.socket != nil {
            self.socket?.disconnect(closeCode: CloseCode.normal.rawValue)
            self.socket?.delegate = self
            self.socket = nil
        }
        self.isFirstConnect = true
        self.socket = WebSocket(request: request)
        self.socket?.delegate = self
        self.connect()
    }
    
    /// Reconnect by manually
    public func reconnectByManually() {
        self.isDisconnectByManually = false
        self.connect()
    }
    
    public func disconnect() {
        self.socket?.disconnect()
        self.isDisconnectByManually = true
    }
    
    private func connect() {
        if Date().timeIntervalSince1970 - self.lastConnectTime  < kConnectMinTimeInterval {
            // 短时间内再次连接
            return
        }
        if self.host.count == 0 { return }
        
        self.socket?.connect()
        self.lastConnectTime = Date().timeIntervalSince1970
    }
    
    /// 开始自动重连
    private func autoReconnect() {
        if self.isDisconnectByManually {
            return
        }
        SCMainAsyncQueue {
            if self.autoReconnectTimer != nil { return }
            self.autoReconnectTimer = Timer.scheduledTimer(timeInterval: kReconnectTimeInterval, target: self, selector: #selector(self.autoReconnectTimerAction), userInfo: nil, repeats: true)
            self.autoReconnectTimer?.fire()
        }
    }
    
    /// 开始心跳包发送定时器
    private func startHeartBeatTimer() {
        SCMainAsyncQueue {
            if self.heartBeatTimer != nil { return }
            self.heartBeatTimer = Timer.scheduledTimer(timeInterval: kHeartBeatTimeInterval, target: self, selector: #selector(self.heartBeatTimerAction), userInfo: nil, repeats: true)
            self.heartBeatTimer?.fire()
        }
    }
    
    /// 结束发送心跳包定时器
    private func stopHeartBeatTimer() {
        self.heartBeatTimer?.invalidate()
        self.heartBeatTimer = nil
    }
    
    /// 自动重连
    @objc private func autoReconnectTimerAction() {
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
        self.connect()
        
        SCSDKLog("ws auto reconnect count:\(self.reconnectCount)")
    }
    
    /// 发送心跳
    @objc private func heartBeatTimerAction() {
        if self.isConnected {
            let msg = ["service": "heart-beat"]
            guard let msgData = try? JSONSerialization.data(withJSONObject: msg, options: .prettyPrinted) else { return }
            guard let msgString = String(data: msgData, encoding: .utf8) else { return }
            self.socket?.write(string: msgString)
        }
        else {
            self.autoReconnect()
        }
    }
    
    public func sendMessage(string: String, success: SCSuccessHandler?, failure: SCFailureError?) {
        if !self.isConnected {
            self.autoReconnect()
            failure?(NSError(domain: "ws disconnect", code: -1))
            return
        }
        self.socket?.write(string: string, completion: nil)
        SCSDKLog("ws write msg:\(string)")
    }
    
    public func sendMessage(message: [String: Any], success: SCSuccessHandler?, failure: SCFailureError?) {
        if !self.isConnected {
            self.autoReconnect()
            failure?(NSError(domain: "ws disconnect", code: -1))
            return
        }
        guard let msgData = try? JSONSerialization.data(withJSONObject: message, options: .prettyPrinted) else { return }
        guard let msgString = String(data: msgData, encoding: .utf8) else { return }
        self.socket?.write(string: msgString, completion: {
                    
        })
        SCSDKLog("ws write msg:\(msgString)")
    }
    
    /// Adds a socket channel delegate.
    public func addDelegate(delegate: SCSmartWebSocketClientDelegate) {
        self.delegates.append(delegate)
    }
    
    /// Removes a socket channel delegate.
    public func removeDelegate(delegate: SCSmartWebSocketClientDelegate) {
        self.delegates.removeAll { obj in
            let objStr = String(describing: Unmanaged<AnyObject>.passUnretained(obj).toOpaque())
            let delegateStr = String(describing: Unmanaged<AnyObject>.passUnretained(delegate).toOpaque())
            return objStr == delegateStr
        }
    }
}

extension SCSmartNetWebSocketClient: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
   
        var body: Any?
        switch event {
        case .connected(let dictionary):
            self.isConnected = true
            self.delegates.forEach { delegate in
                delegate.socket(didConnected: self)
            }
            self.startHeartBeatTimer()
            break
        case .disconnected(let string, let code):
            self.isConnected = false
            SCSDKLog("ws didClose code:\(code), reason:\(string)")
            self.stopHeartBeatTimer()
            self.autoReconnect()
            self.delegates.forEach { delegate in
                delegate.socket(self, disconnect: NSError(domain: string, code: Int(code), userInfo: nil))
            }
        case .text(let string):
            body = string
            break
        case .binary(let data):
            body = data
            
            break
        case .pong(let optional):
            
            break
        case .ping(let optional):
            
            break
        case .error(let optional):
            self.isConnected = false
            break
        case .viabilityChanged(let bool):
            
            break
        case .reconnectSuggested(let bool):
            
            break
        case .cancelled:
            self.isConnected = false
            break
        }
        
        if body != nil {
            self.delegates.forEach { delegate in
//                let model = SCSmartWebSocketResponseModel()
//                model.message = body
            }
        }
        
        SCSDKLogDebug("ws receive event: \(event)")
    }
    
    

}
