//
//  SCSweeperModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/1/12.
//

import UIKit

/*
 扫地机属性
 */
enum SCSweeperPropertyType: String {
    /// 工作状态 0: 睡眠 1: 待机 2: 暂停 3: 回充中 4: 充电中 5: 扫地中 6: 扫拖中 7: 拖地中 8: 升级中
    case status = "status"
    /// 设备异常码 0 ~ 3000
    case fault = "fault"
    /// 风机档位 0: 关 1: 节能 2: 标准 3: 强劲
    case wind = "wind"
    /// 水量大小 0: 低 1: 中 2: 高
    case water = "water"
    /// 扫拖模式 0: 扫地 1: 扫拖 2: 拖地
    case mode = "mode"
    /// 生产厂商
    case manufacturer = "manufacturer"
    /// 设备类型
    case model = "model"
    /// 固件版本
    case firmware = "firmware"
    /// mac地址
    case mac = "mac"
    /// 序列号
    case serialNumber = "serial_number"
    /// 电池电量 0 ~ 100
    case quantity = "quantity"
    /// 充电状态
    case chargeState = "charge_state"
    /// 提示音 0: 关 1: 开
    case alarm = "alarm"
    /// 音量 0 ~ 10
    case volume = "volume"
    /// 主刷寿命 0 ~ 100
    case mainBrush = "main_brush"
    /// 边刷寿命 0 ~ 100
    case sideBrush = "side_brush"
    /// 海帕寿命 0 ~ 100
    case hypa = "hypa"
    /// 拖布寿命 0 ~ 100
    case mopLife = "mop_life"
    /// 网络信息
    case netStatus = "net_status"
    
    var isReadOnly: Bool {
        switch self {
        case .fault, .manufacturer, .model, .firmware, .mac, .serialNumber, .quantity, .chargeState, .mainBrush, .sideBrush, .hypa, .mopLife, .netStatus:
            return true
        default :
            return false
        }
    }
}


enum SCSweeperServiceType: String {
    /// 开始清洁
    case startClean = "start_clean"
    /// 暂停清扫
    case pauseClean = "pause_clean"
    /// 开始扫地
    case startSweep = "start_sweep"
    /// 开始扫拖
    case startSweepMop = "start_sweep_mop"
    /// 开始拖地
    case startMop = "start_mop"
    /// 开始回充
    case startRecharge = "start_recharge"
    /// 停止回充
    case stopRecharge = "stop_recharge"
}


enum SCSweeperStatusType: Int {
    /// 休眠
    case sleep = 0
    /// 待机
    case standby
    /// 暂停
    case pause
    /// 回充中
    case goback
    /// 充电中
    case charging
    /// 扫地中
    case sweep
    /// 拖地中
    case mop
    /// 扫拖中
    case sweepOrMop
    /// 升级中
    case upgrade
    
    /// 空闲
    var isFree: Bool {
        return self == .sleep || self == .standby || self == .charging
    }
    
    /// 清扫中
    var isCleaning: Bool {
        return self == .sweep || self == .mop || self == .sweepOrMop
    }
}

//enum SCSweeperSuctionLevelType: Int {
//    
//}

/*
 清扫模式
 */
enum SCSweeperSweeperOrMopModeType: Int {
    /// 扫地
    case swepper = 0
    /// 扫拖
    case swepperOrMop = 1
    /// 拖地
    case mop
}

/*
 工作模式
 */
enum SCSweeperWorkModeType: Int {
    case none = -1
    
    case explore = 45
    case explorePause
    case exploreGoHome
    case exploreBroken
    case exploreIdle
    
    var exploreStatus: Bool {
        return [SCSweeperWorkModeType.explore, SCSweeperWorkModeType.explorePause, SCSweeperWorkModeType.exploreGoHome, SCSweeperWorkModeType.exploreBroken, SCSweeperWorkModeType.exploreIdle].contains(self)
    }
}

/*
 清扫方案类型
 */
enum SCSweeperCleaningPlanType {
    case normal
    /// 自动清扫
    case auto
    /// 自定义清扫
    case custom
}
