//
//  SCAccountTypeModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/25.
//

import UIKit

enum SCAccountType: Int {
    case wechat
    case aijia
    
    var image: ThemeImagePicker {
        switch self {
        case .wechat:
            return "HomePage.AccountTypeController.wechatImage"
        case .aijia:
            return "HomePage.AccountTypeController.aijiaImage"
        }
    }
    
    var name: String {
        switch self {
        case .wechat:
            return tempLocalize("微信好友")
        case .aijia:
            return tempLocalize("艾加账号")
        }
    }
}


enum SCAccountTypeSourceType: Int {
    case shareDevice
    case addMember
}
