//
//  SCWXApiManager.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/10.
//

import UIKit

fileprivate let kAuthCope = "snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact"
fileprivate let kAuthOpenID = ""
fileprivate let kAuthState = "xxx"
fileprivate let kAppId: String = ""
fileprivate let kAppSecret: String = ""
fileprivate let kUniversalLink: String = ""

class SCWXApiManager: NSObject {
    static let sharedInstance = SCWXApiManager()
        
    func register() {
        WXApi.registerApp(kAppId, universalLink: kUniversalLink)
    }
    
    func authLogin(viewController: UIViewController) {
        let req = SendAuthReq()
        req.scope = kAuthCope
        req.state = kAuthState
        req.openID = kAuthOpenID
        WXApi.sendAuthReq(req, viewController: viewController, delegate: self) { result in
            
        }
    }
}

extension SCWXApiManager: WXApiDelegate {
    func onReq(_ req: BaseReq) {
        
    }
    
    func onResp(_ resp: BaseResp) {
        if let authResp = resp as? SendAuthResp {
            print("code:\(authResp.code),state:\(authResp.state),errcode:\(authResp.errStr)")
            
            let url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=\(kAppId)&secret=\(kAppSecret)&code=\(authResp.code)&grant_type=authorization_code"
            /*
             {
               "access_token": "ACCESS_TOKEN",
               "expires_in": 7200,
               "refresh_token": "REFRESH_TOKEN",
               "openid": "OPENID",
               "scope": "SCOPE",
               "unionid": "o6_bmasdasdsad6_2sgVt7hMZOPfL"
             }
             */
        }
    }
}
