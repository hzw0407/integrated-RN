//
//  ReactNativeManager.swift
//  falala
//
//  Created by 何志武 on 2022/3/12.
//

import UIKit
import React

class ReactNativeManager: NSObject {
    
    var bridge: RCTBridge?
    static let manager = ReactNativeManager();
    
    private override init() {
        super.init()
        self.bridge = RCTBridge.init(delegate: self as RCTBridgeDelegate, launchOptions: nil)
    }
    
    
    class func deaultManager() ->ReactNativeManager {
        //返回初始化好的静态变量值
        return manager
    }
    
}

extension ReactNativeManager: RCTBridgeDelegate {
    func sourceURL(for bridge: RCTBridge!) -> URL! {
    #if DEBUG

        return RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index", fallbackResource: nil)

    #else

        return Bundle.main.url(forResource: "index", withExtension: "jsbundle")
    #endif
    }
    
    
}
