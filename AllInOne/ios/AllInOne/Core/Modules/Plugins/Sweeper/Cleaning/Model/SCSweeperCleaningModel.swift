//
//  SCSweeperCleaningModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/2/17.
//

import UIKit
import sqlcipher

class SCSweeperCleaningCustomPlanRoomModel {
    /// 房间ID
    var roomId: Int = 0
    /// 房间名称
    var roomName: String = ""
    /// 吸力
    var suctionLevel: Int = 0
    /// 水量
    var waterLevel: Int = 0
    /// 扫拖模式
    var sweeperMode: Int = 0
    /// 清扫次数
    var cleanCount: Int = 0
    
    var isSelected: Bool = false
}
