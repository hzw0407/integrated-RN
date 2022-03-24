//
//  SCFeedbackTypeModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/30.
//

import UIKit
import SwiftTheme

enum SCFeedbackType: String {
    /// 产品
    case product = "1"
    /// 智能场景
    case smartScene = "2"
    /// 账号
    case account = "3"
    
    var name: String {
        switch self {
        case .product:
            return "设备"
        case .smartScene:
            return "智能场景"
        case .account:
            return ""
        }
    }
}

class SCFeedbackTypeModel {
    /// 类型。1-产品、2-智能场景、3-账号
    var type: SCFeedbackType = .product
    var title: String = ""
    var imageUrl: String = ""
    var image: ThemeImagePicker?
    var deviceId: String = ""
    var productId: String = ""
}
