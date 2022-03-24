//
//  SCBindDeviceAccessPointService.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/30.
//

import UIKit
import sqlcipher

enum SCBindDeviceAccessPointResultType {
    /// 成功
    case success
    /// 中断
    case interrupt
    /// 连接设备超时
    case connectWithDeviceTimeout
    /// 绑定超时
    case timeout
}

enum SCBindDeviceAccessPointStep: Int {
    /// 普通状态
    case none
    /// 开始
    case start
    /// 连接上设备热点
    case connectedHotspotByDevice
    /// 与设备建立本地连接
    case connectedWidthDevice
    /// 收到设备返回的数据
    case receivedData
    /// 连接上网络
    case connectedNet
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
        case .connectedHotspotByDevice:
            return "Connected hotspot by device"
        case .connectedWidthDevice:
            return "Establish a local connection with the device"
        case .receivedData:
            return "Received device data"
        case .connectedNet:
            return "Connected to the internet"
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

class SCBindDeviceAccessPointService {
    static let shared = SCBindDeviceAccessPointService()
    
    private var config: SCBindDeviceConfig = SCBindDeviceConfig()
    private var bindKey: String = ""
    var step: SCBindDeviceAccessPointStep = .none {
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
    /// 定时器
    private var timer: Timer?
    /// 配网步骤回调闭包
    private var stepBlock: ((SCBindDeviceAccessPointStep) -> Void)?
    /// 配网完成回调闭包
    private var completionBlock: ((SCBindDeviceAccessPointResultType) -> ())?
    
    private var timeBlock: ((String) -> Void)?
    
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
    
    /// 开始AP配网
    /// - Parameters:
    ///   - config: 配网参数
    ///   - stepHandler: 步骤回调
    ///   - completionHandler: 完成回调
    func start(config: SCBindDeviceConfig, stepHandler: ((SCBindDeviceAccessPointStep) -> Void)?, completionHandler: ((SCBindDeviceAccessPointResultType) -> Void)?, timeHandler: ((String) -> Void)? = nil) {
        self.stepBlock = stepHandler
        self.completionBlock = completionHandler
        self.timeBlock = timeHandler
        self.config = config
        
        self.step = .start
        
        self.bindKey = self.getBineKey()
        self.startTime = Date().timeIntervalSince1970
        
//        self.step = .connectedHotspotByDevice
        
        self.startTimer()
        
        SCBindDeviceSocketManager.sharedInstance.start(uid: self.config.uid, ssid: self.config.ssid, password: self.config.password, key: self.bindKey, domain: self.config.domain) { [weak self] in
            self?.step = .connectedWidthDevice
        } finishedCallback: { [weak self] command, json in
            guard let `self` = self else { return }
            if command == .receiveDataFromDevice, let json = json {
                self.sn = (json["sn"] as? String) ?? ""
                self.mac = (json["mac"] as? String) ?? ""
                self.productId = (json["productId"] as? String) ?? ""
                self.step = .receivedData
                SCBindDeviceSocketManager.sharedInstance.stop()
            }
        }
    }
    
    /// 停止配网
    func stop(isTimeout: Bool = false) {
        SCBindDeviceSocketManager.sharedInstance.stop()
        self.stopTimer()
        if self.step != .none && self.step != .success && !isTimeout {
            self.completionBlock?(SCBindDeviceAccessPointResultType.interrupt)
        }
//        self.step = .none
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
    }
    
    /// 定时执行函数
    private func timerHandler() {
        self.timeCount += 1
        self.timeBlock?("log:" + self.bindKey + "_" + self.step.name + "_wifi:\(SCLocalNetwork.sharedInstance.getSsid() ?? "nil")" + "_" + String(self.timeCount))
        if Date().timeIntervalSince1970 - self.startTime > self.timeoutDuration {
            self.timeoutHandler()
            return
        }
        if self.step == .receivedData || self.step == .connectedNet || self.step == .loopGetBindingResult {
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
//            #if DEBUG
//            SCSmartNetworking.sharedInstance.getDeviceInfoRequest(sn: self.sn, mac: self.mac) { [weak self] info in
//                if let info = info, info.id.count > 0 {
//                    self?.deviceId = info.id
//                    self?.productId = info.productId
//                    self?.step = .success
//                }
//            } failure: { error in
//
//            }
//            #endif

        }
//        #if DEBUG
//        if self.step == .receivedData || self.step == .connectedNet || self.step == .loopGetBindingResult {
//            SCSmartNetworking.sharedInstance.getDeviceInfoRequest(sn: self.sn, mac: self.mac) { info in
//                self.deviceId = info?.id ?? ""
//                self.step = .gotBindingResult
//                self.step = .success
//            } failure: { error in
//
//            }
//        }
//        #endif
        if self.step == .gotBindingResult || self.step == .loopLocking {
            
        }
        if self.step == .success {
            self.stopTimer()
            self.completionBlock?(.success)
        }
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
    private func writeBindLog(step: SCBindDeviceAccessPointStep) {
        let stepText = step.name
        let text = self.bindKey + "_" + stepText + "_" + "_wifi:\(SCLocalNetwork.sharedInstance.getSsid() ?? "nil")_" + getNowDateText()
//        self.delegate?.bindStepChangedLog(communicationType: .accessPoint, text: text, sn: self.sn)
        SCSDKLog("Bind device: \(text)")
    }
}
