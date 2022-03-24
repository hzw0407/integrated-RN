//
//  SCNetworkReachabilityManager.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/3.
//

import Alamofire

let SCNetworkReachabilityStatusChangedNotificationKey = "SCNetworkReachabilityStatusChangedNotificationKey"

public class SCNetworkReachabilityManager {
    static let shared: SCNetworkReachabilityManager = SCNetworkReachabilityManager()
    
    var isReachable: Bool {
        return self.reachabilityManager?.isReachable ?? false
    }
    
    var isReachableOnWWAN: Bool {
        return self.reachabilityManager?.isReachableOnWWAN ?? false
    }
    
    var isReachableOnEthernetOrWiFi: Bool {
        return self.reachabilityManager?.isReachableOnEthernetOrWiFi ?? false
    }
    
    public var reachabilityHost: String = "www.apple.com"
    var reachabilityManager: NetworkReachabilityManager?
    
    func startListenForReachability() {
        if self.reachabilityManager == nil {
            let reachability = NetworkReachabilityManager(host: self.reachabilityHost)
            reachability?.listener = { status in
                SCMainAsyncQueue {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: SCNetworkReachabilityStatusChangedNotificationKey), object: nil)
                }
                
                if self.isReachable {
                    if !SCLocalNetwork.sharedInstance.pingStatus {
                        SCLocalNetwork.sharedInstance.pingLocalNet()
                    }
                }
            }
            
            reachability?.startListening()
            
            self.reachabilityManager = reachability
        }
        
    }
}
