//
//  SCSmartSDK.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/10/19.
//

import UIKit

/// Server environment.
enum SCServerEnvironment: Int {
    case daily
    case prepare
    case release
}

public class SCSmartSDK {
    public static let sharedInstance = SCSmartSDK()
    
    /// Debug mode, default is false. Verbose log will print into console if opened.
    var debugMode: Bool = false
    
    /// Application group identifier.
    var appGroupId: String = ""
    
    /// Latitude of the location.
    var latitude: Double = 0
    
    /// Longitude of the location.
    var longitude: Double = 0
    
    /// Server environment, defaults is release. Please do not set in production environment.
    var env: SCServerEnvironment = .release
    
    /// Channel.
    var channel: String = ""
    
    /// UUID of the iOS device. Will be created at app first launch.
    var uuid: String = ""
    
    /// App version, default value is from Info.plist -> CFBundleShortVersionString.
    var appVersion: String = ""
    
    /// Device product name. For example: iPhone XS Max.
    var deviceProductName: String = ""
    
    /// App SDK lang, default value is from mainBundle -> preferredLocalizations -> [0].
    var lang: String = ""
    
    private (set) var appEnv: String = ""
    private (set) var gwHost: String = ""
    private (set) var mbHost: String = ""
    private (set) var port: Int = 0
    private (set) var useSSL: Bool = false
}
