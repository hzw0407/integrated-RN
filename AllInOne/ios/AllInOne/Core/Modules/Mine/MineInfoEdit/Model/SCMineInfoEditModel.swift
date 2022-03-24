//
//  SCMineInfoEditModel.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/15.
//

import UIKit

enum SCMineInfoEditTextCellType: Int {
    /// 无右边箭头
    case noArrow
    /// 有子标题和箭头
    case textAndArrow
    /// 只有箭头
    case arrow
    /// 开关
    case switchAction
}

class SCMineInfoEditModel: SCBasicModel {
    var title: String = ""
    var subTitle: String = ""
    var beginTime: String = ""
    var endTime: String = ""
    var day: String = ""
    var cellType: SCMineInfoEditTextCellType = .noArrow
    var cornerRadiusTop: Bool = false
    var cornerRadiusBottom: Bool = false
    var isEnable: Bool = true
    var isSwitchOn: Bool = false
    
}


class SCMineSettingLanguageModel: SCBasicModel {
    var title: String = ""
    var isSelected: Bool = false
    var cornerRadiusTop: Bool = false
    var cornerRadiusBottom: Bool = false
    var type: SCLanguageType = .English
}

//public class SCMineConsumableModel{
//    var consumablesList:NSArray = []
//    var deviceId: String = ""
//    var nickname: String = ""
//    var owner: String = ""
//    var productId: String = ""
//    var roomId: String = ""
//    var roomName: String = ""
//  
//    
//    
//    
//    var title: String = ""
//    var subTitle: String = ""
//    var cornerRadiusTop: Bool = false
//    var cornerRadiusBottom: Bool = false
//}

class SCMineConsumableHeaderModel: SCBasicModel {
    var name: String = ""
    var location: String = ""
}

class SCMineHouseSelectModel: SCBasicModel {
    var title: String = ""
    var isSelected: Bool = false
    var id:String = ""
    var tenantId:String = ""
    var memberNum:String = ""
    var familyName:String = ""
    var createTime:String = ""
    var creatorId:String = ""
    var deviceNum:String = ""
    var deleteFlag:String = ""
    
}
