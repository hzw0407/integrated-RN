//
//  SCResetPasswordViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/7.
//

import UIKit

class SCResetPasswordViewModel: SCBasicViewModel {
    var items: [SCLoginInputModel] = [] {
        didSet {
            for item in items {
                if item.type == .username {
                    self.username = item.content
                    if SCRegex.matches(phone: item.content) {
                        self.username = "86-" + item.content
                    }
                }
                else if item.type == .password {
                    self.password = item.content
                }
                else if item.type == .confirmPassword {
                    self.confirmPassword = item.content
                }
                else if item.type == .authCode {
                    self.authCode = item.content
                }
            }
        }
    }
        
    var username: String = ""
    
    var password: String = ""
    
    var confirmPassword: String = ""
    
    var authCode: String = ""
    
    func checkResetEnable() -> Bool {
        return self.username.count > 0 && self.password.count > 0 && self.confirmPassword.count > 0 && self.authCode.count > 0
    }
    
    func resetPassword(success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.resetPasswordRequest(username: self.username, password: self.password, authCode: self.authCode) {
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
    
    func getAuthCode(success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.getAuthCodeRequest(username: self.username, type: .resetPassword) {
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
