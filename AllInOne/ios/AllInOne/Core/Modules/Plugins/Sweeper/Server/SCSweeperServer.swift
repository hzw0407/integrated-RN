//
//  SCSwepperPropertyServer.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/2/16.
//

import UIKit
import sqlcipher

class SCSweeperServer {
    /// 主机状态
    var statusType: SCSweeperStatusType = .standby
    /// 错误码
    var faultType: SCSwepperFaultType = .FAULT_NONE
    /// 吸力 0-100
    var suctionLevel: Int = 0
    /// 水量 0-100
    var waterLevel: Int = 0
    /// 扫拖模式
    var sweeperModeType: SCSweeperSweeperOrMopModeType = .swepperOrMop
    /// 电池电量 0-100
    var battery: Int = 0
    /// 声音开关
    var voiceSwitch: Bool = false
    /// 音量
    var voiceVolume: Int = 0
    /// 记忆图
    var hasMemoryMap: Bool = false
    ///
    var chargeState: Int = 0
    /// 设备工作模式类型
    var workModeType: SCSweeperWorkModeType = .none
    /// 清扫方案类型
    var planType: SCSweeperCleaningPlanType = .normal
    
    var aiSwitch: Bool = false
    
    private var reloadDataBlock: (() -> Void)?
    
    convenience init(reloadDataHandler: (() -> Void)?) {
        self.init()
        self.reloadDataBlock = reloadDataHandler
    }
    
    func setup() {
        /// 订阅属性
        SCPluginNet.sharedInstance.subscribeDevicePropertyPush { [weak self] json in
            guard let `self` = self else { return }
            guard let content = json["params"] as? [String: Any] else { return }
            self.parsePropertiesData(json: content)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) { [weak self] in
            self?.getAllProperties()
        }
    }
    
    func getAllProperties() {
        let propertyTypes: [SCSweeperPropertyType] = [.status, .fault, .wind, .water, .chargeState, .alarm, .volume, .quantity]
        let properties = propertyTypes.map { return $0.rawValue }
        SCPluginNet.sharedInstance.getDeviceProperty(message: ["property": properties], callback: { [weak self] response in
            guard let json = response.json else { return }
            guard let content = json["data"] as? [String: Any] else { return }
            self?.parsePropertiesData(json: content)
        })
    }
    
    func parsePropertiesData(json: [String: Any]) {
        if let status = json[SCSweeperPropertyType.status.rawValue] as? Int {
            self.statusType = SCSweeperStatusType(rawValue: status) ?? .standby
        }
        else if let faultCode = json[SCSweeperPropertyType.fault.rawValue] as? Int {
            self.faultType = SCSwepperFaultType(rawValue: faultCode) ?? .FAULT_NONE
        }
        else if let alarm = json[SCSweeperPropertyType.alarm.rawValue] as? Int {
            self.voiceSwitch = alarm == 1
        }
        else if let volume = json[SCSweeperPropertyType.volume.rawValue] as? Int {
            self.voiceVolume = volume
        }
        else if let chargeState = json[SCSweeperPropertyType.chargeState.rawValue] as? Int {
            self.chargeState = chargeState
        }
        else if let quantity = json[SCSweeperPropertyType.quantity.rawValue] as? Int {
            self.battery = quantity
        }
        else if let water = json[SCSweeperPropertyType.water.rawValue] as? Int {
            self.waterLevel = water
        }
        else if let wind = json[SCSweeperPropertyType.wind.rawValue] as? Int {
            self.suctionLevel = wind
        }
        self.reloadDataBlock?()
    }
    
    func clear() {
        SCPluginNet.sharedInstance.unsubscribeAll()
    }
    
    /// 点击清扫按钮
    func cleanAction() {
        SCBPLog("点击清扫按钮，此时主机状态:\(self.statusType.rawValue)")
        if self.statusType == .upgrade { return }
        if self.statusType == .goback { return }
        
        if self.statusType.isFree {
            if !self.hasMemoryMap {
                SCBPLog("没有记忆图，弹窗提示建图")
                self.alertNewCreatMapView()
                #if DEBUG
//                self.startClean()
                #endif
                return
            }
            else {
                SCBPLog("点击开始清扫")
                self.startClean()
                return
            }
        }
        else if self.statusType == .pause {
            SCBPLog("点击继续清扫")
            self.startClean()
        }
        else if self.statusType.isCleaning {
            self.pauseClean()
        }
    }
    
    /// 点击基站按钮
    func stationAction() {
        SCBPLog("点击基站按钮，此时主机状态:\(self.statusType.rawValue)")
        if self.statusType == .upgrade { return }
        if self.statusType == .charging {
            
        }
        else if self.statusType == .goback {
            SCBPLog("点击停止回充")
            self.stopRecharge()
        }
        else {
            SCBPLog("点击开始回充")
            self.startRecharge()
        }
    }
    
    /// 切换清扫方案类型
    func changeCleanPlanType(type: SCSweeperCleaningPlanType, callback: ((Bool) -> Void)?) {
        
    }
}

extension SCSweeperServer {
    /// 开始清扫
    func startClean() {
        let message: [String: Any] = [:]
        SCProgressHUD.showWaitHUD()
        SCPluginNet.sharedInstance.setDeviceService(identifer: SCSweeperServiceType.startClean.rawValue, message: message) { response in
            SCProgressHUD.hideHUD()
        }
    }
    
    /// 暂停清扫
    func pauseClean() {
        let message: [String: Any] = [:]
        SCProgressHUD.showWaitHUD()
        SCPluginNet.sharedInstance.setDeviceService(identifer: SCSweeperServiceType.pauseClean.rawValue, message: message) { response in
            SCProgressHUD.hideHUD()
        }
    }
    
    /// 回充
    func startRecharge() {
        let message: [String: Any] = [:]
        SCProgressHUD.showWaitHUD()
        SCPluginNet.sharedInstance.setDeviceService(identifer: SCSweeperServiceType.startRecharge.rawValue, message: message) { response in
            SCProgressHUD.hideHUD()
            
        }
    }
    
    /// 停止回充
    func stopRecharge() {
        let message: [String: Any] = [:]
        SCProgressHUD.showWaitHUD()
        SCPluginNet.sharedInstance.setDeviceService(identifer: SCSweeperServiceType.stopRecharge.rawValue, message: message) { response in
            SCProgressHUD.hideHUD()
        }
    }
    
    /// 开始探索建图
    func startExploreCreateMap() {
        
    }
}

extension SCSweeperServer {
    func alertNewCreatMapView() {
        SCSweeperAlertSheetView.alert(message: tempLocalize("尚无地图，请创建一张地图"), supplement: tempLocalize("推荐使用“快速建图”功能，只建图，不清洁，可迅速创建全屋地图。"), actionsTitles: [tempLocalize("快速建图"), tempLocalize("自动清洁建图"), tempLocalize("取消")]) { [weak self] index in
            guard let `self` = self else { return }
            if index == 0 { // 快速建图
                SCBPLog("点击快速建图")
                self.startExploreCreateMap()
            }
            else if index == 1 { // 自动清洁建图，需要将清扫模式修改为自动清扫模式
                SCBPLog("点击自动清洁建图")
                if self.aiSwitch { // AI开启，启动自定义清洁模式进行建图
                     SCBPLog("AI开启，启动自定义清洁模式进行建图")
                    
                } else { // AI关闭，启动扫拖模式进行建图
                    SCBPLog("AI关闭，启动扫拖模式进行建图")
                    
                }
            }
            else if index == 2 {
                SCBPLog("点击取消")
            }
        }
    }
}
