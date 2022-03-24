//
//  SCPersonInformationViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/7.
//

import UIKit

enum SCPersonInformationType: Int {
    case uid = 0
    case changePassword
    case bindPhone
    case bindEmail
    case deleteAccount
    
    var name: String {
        switch self {
        case .uid:
            return tempLocalize("用户ID")
        case .changePassword:
            return tempLocalize("修改密码")
        case .bindPhone:
            return tempLocalize("绑定手机")
        case .bindEmail:
            return tempLocalize("绑定邮箱")
        case .deleteAccount:
            return tempLocalize("注销账号")
        }
    }
    
    var hasArrow: Bool {
        switch self {
        case .uid:
            return false
        default:
            return true
        }
    }
}

class SCPersonInformationViewModel: SCBasicViewModel {
    
    func deleteAccount(success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.deleteAccountRequest {
            SCProgressHUD.hideHUD()
            success()
            SCSmartNetworking.sharedInstance.clearUser()
            SCUserCenter.sharedInstance.pushToLogin()
        } failure: { error in
            if error.code > 0 {
                SCProgressHUD.showHUD(error.msg)
            }
            else {
                SCProgressHUD.hideHUD()
            }
        }

    }
}
