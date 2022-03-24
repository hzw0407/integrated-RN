//
//  SCMineResetModel.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/20.
//

import UIKit

class SCMineResetModel: SCBasicModel {
    var oldPwd: String = ""
    var newPwd1: String = ""
    var newPwd2: String = ""
    var number: String = "" //手机号或者邮箱
    
    var username: String = "" //手机号或者邮箱
    var password: String = "" //密码
    var authCode: String = "" //验证码
    
  //用旧密码修改的接口
    func changePasswordRequest(success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
     
        if self.oldPwd == self.newPwd1  {
            SCProgressHUD.showHUD(tempLocalize("新密码和旧密码不能相同"))
            return
        }
        
        SCSmartNetworking.sharedInstance.changePasswordRequest(oldPassword: self.oldPwd, newPassword: self.newPwd1) {
            SCProgressHUD.showHUD(tempLocalize("修改成功"))
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
    
    //获取验证码
    func getAuthCode(type:SCSmartNetHttpAuthCodeType,success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        
        if SCRegex.matches(phone: self.number) {
            self.number = "86-" + self.number
        }
        SCSmartNetworking.sharedInstance.getAuthCodeRequest(username: self.number, type: type) {
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
    
    //通过邮箱或者手机号验证码修改密码
    func resetPassword(success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        if SCRegex.matches(phone: self.username) {
            self.username = "86-" + self.username
        }
        SCSmartNetworking.sharedInstance.resetPasswordRequest(username: self.username, password: self.password, authCode: self.authCode) {
         
            SCProgressHUD.showHUD(tempLocalize("修改成功"))
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
    
    
    //修改手机号
    func modifyPhone(success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        if SCRegex.matches(phone: self.username) {
            self.username = "86-" + self.username
        }
        
        SCSmartNetworking.sharedInstance.modifyPhoneRequest(phone: self.username, authCode: self.authCode) {
            SCProgressHUD.showHUD(tempLocalize("绑定成功"))
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
    
    //修改邮箱
    func modifyEmail(success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        if SCRegex.matches(phone: self.username) {
            self.username = "86-" + self.username
        }
        
        SCSmartNetworking.sharedInstance.modifyEmailRequest(email: self.username, authCode: self.authCode) {
            SCProgressHUD.showHUD(tempLocalize("绑定成功"))
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
    
    //注销账号
    func deleteAccount(success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
     
        SCSmartNetworking.sharedInstance.deleteAccountRequest {
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
