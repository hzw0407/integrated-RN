//
//  SCSmartNetHttpAuthentication.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/16.
//

import UIKit
import Alamofire

/// 客户端证书名称
fileprivate let kClientTrustName = "client"
/// 客户端证书密码
fileprivate let kClientTrustPassword = "hj2WtyHYYEvBTxDb"
/// 服务端证书名称
fileprivate let kServerTrustName = "server"

/*
 SSL认证
 */
class SCSmartNetHttpAuthentication {
    class func setup(manager: SessionManager) {
        manager.delegate.sessionDidReceiveChallenge = { (session: URLSession, challenge: URLAuthenticationChallenge) in
            return self.alamofireCertificateTrust(seesion: session, challenge: challenge)
        }
    }
    
    class func alamofireCertificateTrust(seesion: URLSession, challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        let method = challenge.protectionSpace.authenticationMethod
//        return self.clientTrust(session: seesion, challenge: challenge)
        if method == NSURLAuthenticationMethodServerTrust {
            return self.serverTrust(session: seesion, challenge: challenge)
        }
        else if method == NSURLAuthenticationMethodClientCertificate {
            return self.clientTrust(session: seesion, challenge: challenge)
        }
        else {
            return (.cancelAuthenticationChallenge, nil)
        }
    }
    
    /// 客户端认证
    class func clientTrust(session: URLSession, challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        let disposition = URLSession.AuthChallengeDisposition.useCredential
        var credential: URLCredential?
        
        let path: String = Bundle.main.path(forResource: kClientTrustName, ofType: "p12")!
        let PKCS12Data = NSData(contentsOfFile: path)!
        let key = kSecImportExportPassphrase as NSString
        let options = [key: kClientTrustPassword] as NSDictionary
        
        var items: CFArray?
        let error = SecPKCS12Import(PKCS12Data, options, &items)
        
        if error == errSecSuccess {
            if let itemArr = items as? NSArray, let item = itemArr.firstObject as? Dictionary<String, AnyObject> {
                let identityPointer = item["identity"]
                let secIdentityRef = identityPointer as! SecIdentity
                
                let chainPointer = item["chain"]
                let chainRef = chainPointer as? [Any]
                
                credential = URLCredential.init(identity: secIdentityRef, certificates: chainRef, persistence: URLCredential.Persistence.forSession)
            }
        }
        return (disposition, credential)
    }
    
    /// 服务端认证
    class func serverTrust(session: URLSession, challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        
        var disposition = URLSession.AuthChallengeDisposition.useCredential
        var credential: URLCredential?
        
        let serverTrust: SecTrust = challenge.protectionSpace.serverTrust!
        let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)!
        let remoteCertificateData = CFBridgingRetain(SecCertificateCopyData(certificate))!
        
        let cerPath = Bundle.main.path(forResource: kServerTrustName, ofType: "cer")!
        let cerUrl = URL(fileURLWithPath: cerPath)
        let localCertificateData = try! Data(contentsOf: cerUrl)
        
        if (remoteCertificateData.isEqual(localCertificateData) == true) {
            disposition = URLSession.AuthChallengeDisposition.useCredential
//            credential = URLCredential(trust: serverTrust)
            credential = self.clientCredential()
        }
        else {
            disposition = URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge
        }
        return (disposition, credential)
    }
    
    class func clientCredential() -> URLCredential? {
        var credential: URLCredential?
        
        let path: String = Bundle.main.path(forResource: kClientTrustName, ofType: "p12")!
        let PKCS12Data = NSData(contentsOfFile: path)!
        let key = kSecImportExportPassphrase as NSString
        let options = [key: kClientTrustPassword] as NSDictionary
        
        var items: CFArray?
        let error = SecPKCS12Import(PKCS12Data, options, &items)
        
        if error == errSecSuccess {
            if let itemArr = items as? NSArray, let item = itemArr.firstObject as? Dictionary<String, AnyObject> {
                let identityPointer = item["identity"]
                let secIdentityRef = identityPointer as! SecIdentity
                
                let chainPointer = item["chain"]
                let chainRef = chainPointer as? [Any]
                
                credential = URLCredential.init(identity: secIdentityRef, certificates: chainRef, persistence: URLCredential.Persistence.forSession)
            }
        }
        return credential
    }
}
