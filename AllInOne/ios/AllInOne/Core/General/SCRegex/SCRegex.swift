//
//  SCRegex.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/26.
//

import UIKit
import PySwiftyRegex

class SCRegex {
    static let phoneRe = re.compile("^[1][3,4,5,6,7,8,9][0-9]{9}$")
    static let emailRe = re.compile("^[a-zA-Z0-9_.-]+@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*\\.[a-zA-Z0-9]{2,6}$")
    
    static let passworkRe = re.compile("^[0-9a-zA-Z]{6,32}$")
    
    static let numberRe = re.compile("^[0-9]+$")
    
    static let snRe = re.compile("^(?:([a-z,A-Z,0-9]{16}|[a-z,A-Z,0-9]{30}))$")
    
    static let ipv4AddressRe = re.compile("^(?:(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))$")
    
    static let containChineseRe = re.compile("[\u{4e00}-\u{9fa5}]+")

    static let deviceNameRe = re.compile("^(?=[0-9a-zA-Z@_.]+$)")
    
    static let letter = re.compile("[a-zA-Z]")
    
    static let ssidPwdRe = re.compile("[a-zA-Z0-9\\@\\#\\$\\%\\^\\&\\*\\-\\=\\+\\_]")

    
    static func matches(chinese:String)->Bool
    {
        if let _ = containChineseRe.match(chinese) {
            return true
        }else{
            return false
        }
    }
    
    static func matches(phone:String)->Bool
    {
        //不足11位的直接返回
        guard phone.count == 11 else {
            return false
        }
        
        if let _ = phoneRe.match(phone) {
            return true
        }else{
            return false
        }
    }
    
    static func matches(email:String)->Bool
    {
        guard email.count > 6 else {
            return false
        }
        
        if let _ = emailRe.match(email) {
            return true
        }else{
            return false
        }
    }
    
//    static func matches(password:String)->Bool
//    {
//        if password.count < 6 || password.count > 32 {
//            SCProgressHUD.showHUD(tempLocalize("login_password_length_limit"))
//            return false
//        }
//        return true
////        if let _ = passworkRe.match(password) {
////            return true
////        }else{
////            WYToast.show(kLocalize("password_format_error"))
////            return false
////        }
//    }
    
    static func matches(number:String)->Bool{
        guard number.count > 0 else {
            return false
        }
        
        if let _ = numberRe.match(number) {
            return true
        }else{
            return false
        }
    }
    
    static func matches(sn:String)->Bool{
        guard (sn.count == 16 || sn.count == 30),sn.hasPrefix("RS") else {
            return false
        }
        
        if let _ = snRe.match(sn){
            return true
        }else{
            return false
        }
    }
    
    static func matches(ipaddress:String)->Bool{
        guard ipaddress.count > 0 else {
            return false
        }
        
        if let _ = ipv4AddressRe.match(ipaddress){
            return true
        }else{
            return false
        }
    }
    
    static func matches(ssidpwd:String)->Bool{
        let result = ssidPwdRe.findall(ssidpwd, 0, ssidpwd.count)
//        SSLog("test_>:\(result.count), length:\(ssidpwd.count)")
        return result.count == ssidpwd.count
    }
}

struct Regex {
    static func validatePhone(phone:String)->Bool{
        let phoneRe = "^1[3|4|5|7|8][0-9]\\d{8}$"
        let phonePre = NSPredicate(format: "SELF MATCHES %@", phoneRe)
        return phonePre.evaluate(with: phone)
    }
    
    static func validateEmail(email:String)->Bool{
        let emailRe = "^\\w*([-+.]\\w+)*@([A-Za-z0-9]+[-.])+[A-Za-z0-9]{2,5}$"
        let emailPre = NSPredicate(format: "SELF MATCHES %@", emailRe)
        return emailPre.evaluate(with: email)
    }
    
    static func validateNumber(number:String)->Bool
    {
        let numberRe = "^[0-9]+$"
        let numberPre = NSPredicate(format: "SELF MATCHES %@", numberRe)
        return numberPre.evaluate(with: number)
    }

    static func validateDeviceName(number:String)->Bool
    {
        let deviceNameRe = "^\\:[a-z0-9_]+\\:$"
        let deviceNamePre = NSPredicate(format: "SELF MATCHES %@", deviceNameRe)
        return deviceNamePre.evaluate(with: deviceNameRe)
    }
    
    static func hasLetter(string:String)->Bool
    {
        let pattern = "[a-zA-Z]"
        guard let regx = try? NSRegularExpression(pattern: pattern, options: []) else {
            return false
        }
        let matchs = regx.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        return matchs.count > 0
    }
}
