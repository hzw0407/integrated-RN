//
//  SCChangePasswordViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/7.
//

import UIKit

class SCChangePasswordViewModel: SCBasicViewModel {
    var items: [SCLoginInputModel] = [] {
        didSet {
            for item in items {
                if item.type == .password {
                    self.password = item.content
                }
                else if item.type == .confirmPassword {
                    self.confirmPassword = item.content
                }
                else if item.type == .oldPassword {
                    self.oldPassword = item.content
                }
            }
        }
    }
            
    var password: String = ""
    
    var confirmPassword: String = ""
    
    var oldPassword: String = ""
    
    func checkResetEnable() -> Bool {
        return self.oldPassword.count > 0 && self.password.count > 0 && self.confirmPassword.count > 0
    }
    
    func changePassword(success: @escaping (() -> Void)) {
        if self.password != self.confirmPassword {
            SCProgressHUD.showHUD(tempLocalize("两次输入的密码不一致"))
            return
        }
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.changePasswordRequest(oldPassword: self.oldPassword, newPassword: self.password) {
            SCProgressHUD.hideHUD()
            success()
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
