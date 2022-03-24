//
//  AppDelegate.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/10/19.
//

import UIKit
import IQKeyboardManager

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var backgroundSessionCompletionHandler: (() -> Void)?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        SCThemes.set(.basic)

        let tabBarController = SCTabBarController()
        
//        let url = URL.init(string: "http://192.168.31.161:8081/index.bundle?platform=ios")
//        let rootView = RCTRootView.init(bundleURL: url!, moduleName: "RNView", initialProperties: nil, launchOptions: nil)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = tabBarController

        SCDataBase.setup()
        SCUserCenter.sharedInstance.setup()

        IQKeyboardManager.shared().isEnabled = true

        SCPerformanceTool.startListening()
        
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        self.window?.makeKeyAndVisible()
//        let vc = ViewController()
//        self.window?.rootViewController = vc
        
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
            self.backgroundSessionCompletionHandler = completionHandler
        }

}


