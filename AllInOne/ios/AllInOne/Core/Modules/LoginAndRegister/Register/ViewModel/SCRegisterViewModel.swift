//
//  SCRegisterViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/3.
//

import UIKit

class SCRegisterViewModel: SCBasicViewModel {
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
    
    var country: SCCountryModel?
    
    var username: String = ""
    
    var password: String = ""
    
    var confirmPassword: String = ""
    
    var authCode: String = ""
    
    func checkRegisterEnable() -> Bool {
        return self.username.count > 0 && self.password.count > 0 && self.country != nil && self.confirmPassword.count > 0 && self.authCode.count > 0
    }
    
    func register(success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        #if DEBUG
        self.authCode = ""
        #endif
        SCSmartNetworking.sharedInstance.registerRequest(username: self.username, password: self.password, authCode: self.authCode) {
            SCProgressHUD.hideHUD()
            SCProgressHUD.showHUD(tempLocalize("注册成功"))
            
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
        SCSmartNetworking.sharedInstance.getAuthCodeRequest(username: self.username, type: .register) {
            SCProgressHUD.hideHUD()
            SCProgressHUD.showHUD(tempLocalize("发送成功"))
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


