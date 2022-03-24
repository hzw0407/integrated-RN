//
//  SCSmartNetWebSocketService.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/1.
//

import UIKit

protocol SCSmartNetWebSocketServiceDelegate: AnyObject {
    func socket(didConnected socket: SCSmartNetWebSocketService)
    
    func socket(_ socket: SCSmartNetWebSocketService, disconnect error: Error)
    
    func socket(_ socket: SCSmartNetWebSocketService, didReceiveMessage data: Data)
}

class SCSmartNetWebSocketService {
    weak var delegate: SCSmartNetWebSocketServiceDelegate?
    
    var isConnected: Bool {
        return self.client.isConnected
    }
    
    private lazy var client: SCSmartNetWebSocketClient = {
        let client = SCSmartNetWebSocketClient()
        client.addDelegate(delegate: self)
        return client
    }()
    
    func connect(host: String) {
        self.client.connect(host: host)
    }
    
    func disconnect() {
        self.client.disconnect()
    }
    
    /// Reconnect by manually
    public func reconnectByManually() {
        self.client.reconnectByManually()
    }
    
    public func sendMessage(string: String, success: SCSuccessHandler?, failure: SCFailureError?) {
        self.client.sendMessage(string: string, success: success, failure: failure)
    }
    
    public func sendMessage(message: [String: Any], success: SCSuccessHandler?, failure: SCFailureError?) {
        self.client.sendMessage(message: message, success: success, failure: failure)
    }
}

extension SCSmartNetWebSocketService: SCSmartWebSocketClientDelegate {
    func socket(didConnected socket: SCSmartNetWebSocketClient) {
        self.delegate?.socket(didConnected: self)
    }
    
    func socket(_ socket: SCSmartNetWebSocketClient, disconnect error: Error) {
        self.delegate?.socket(self, disconnect: error)
    }
    
    func socket(_ socket: SCSmartNetWebSocketClient, didReceiveMessage data: Data) {
        self.delegate?.socket(self, didReceiveMessage: data)
    }
}
