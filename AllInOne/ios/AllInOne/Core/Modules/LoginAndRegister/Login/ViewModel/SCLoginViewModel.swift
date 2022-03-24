//
//  SCLoginViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/26.
//

import UIKit

enum SCLoginStyle {
    case username
    case authCode
    case wechat
}

class SCLoginViewModel: SCBasicViewModel {
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
                else if item.type == .authCode {
                    self.authCode = item.content
                }
            }
        }
    }
    
    var country: SCCountryModel?
    
    var username: String = ""
    
    var password: String = ""
    
    var authCode: String = ""
    
    var loginStyle: SCLoginStyle = .username
    
    func checkLoginEnable() -> Bool {
        return self.username.count > 0 && self.password.count > 0 && self.country != nil
    }
    
    func login(success: @escaping (() -> Void)) {
        if self.loginStyle == .username {
            SCProgressHUD.showWaitHUD()
            SCSmartNetworking.sharedInstance.loginRequest(username: self.username, password: self.password) { user in
                SCProgressHUD.hideHUD()
                if let user = user {
                    success()
                }
            } failure: { error in
                if error.code == SCSmartNetworkingCodeType.usernamePasswordError.rawValue {
                    SCProgressHUD.showHUD(tempLocalize("用户名或密码错误"))
                }
                else {
                    SCProgressHUD.hideHUD()
                }
            }
        }
        else {
            SCProgressHUD.showWaitHUD()
            SCSmartNetworking.sharedInstance.loginRequestWithAuthCode(username: self.username, authCode: self.authCode) { user in
                SCProgressHUD.hideHUD()
                if let user = user {
                    success()
                }
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
    
    func getAuthCode(success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.getAuthCodeRequest(username: self.username, type: .login) {
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
