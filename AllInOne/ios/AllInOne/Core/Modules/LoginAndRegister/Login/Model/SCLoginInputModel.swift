//
//  SCLoginInputModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/24.
//

import UIKit

enum SCLoginInputType: Int {
    case normal = 0
    // 用户名输入
    case username
    /// 密码输入
    case password
    /// 确认密码输入
    case confirmPassword
    /// 旧密码输入
    case oldPassword
    /// 验证码输入
    case authCode
    /// 地区选择
    case country
}

class SCLoginInputModel {
    /// 标题
    var title: String {
        switch self.type {
        case .country:
            return tempLocalize("选择国家/地区")
        default:
            return ""
        }
    }
    /// 内容
    var content: String = ""
    /// 输入提示
    var placeholder: String? {
        switch self.type {
        case .username:
            return tempLocalize("请输入手机号/邮箱")
        case .password:
            return tempLocalize("请输入密码")
        case .confirmPassword:
            return tempLocalize("请再次输入密码")
        case .oldPassword:
            return tempLocalize("请输入旧密码")
        case .authCode:
            return tempLocalize("请输入验证码")
        default:
            return nil
        }
    }
    /// 类型
    var type: SCLoginInputType = .normal
    /// 密码是否显示
    var isPasswordShow: Bool = false
    /// 是否显示背景框
    var isbgViewShow: Bool {
        switch self.type {
        case .normal,.country:
            return false
        default:
            return true
        }
    }
    
    
   
  
    /// 验证码倒计时，等于0时可以点击，否则不能点击
    var countDown: Int = 0
    
    var hasTopLine: Bool = true
    
    var hideShowOrHideButton: Bool = false
    
    /// 键盘类型
    var keyboardType: UIKeyboardType {
        switch self.type {
        case .authCode:
            return .numberPad
        default:
            return .emailAddress
        }
    }
    
    /// 是否是
    var isSecureTextEntry: Bool {
        switch self.type {
        case .password, .confirmPassword, .oldPassword:
            return !self.isPasswordShow
        default:
            return false
        }
    }
    
    var hasTitle: Bool {
        switch self.type {
        case .country:
            return true
        default:
            return false
        }
    }
    
    var hasSecret: Bool {
        switch self.type {
        case .password, .confirmPassword, .oldPassword:
            return true
        default:
            return false
        }
    }
    
    var hasArrow: Bool {
        switch self.type {
        case .country:
            return true
        default:
            return false
        }
    }
    
    var hasSelect: Bool {
        switch self.type {
        case .country:
            return true
        default:
            return false
        }
    }
    
    var hasAuthCode: Bool {
        switch self.type {
        case .authCode:
            return true
        default:
            return false
        }
    }
    
    var contentAlignment: NSTextAlignment {
        switch self.type {
        case .country:
            return .right
        default:
            return .left
        }
    }
}

