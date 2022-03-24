//
//  SCSmartSDK+Log.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/10/19.
//

import UIKit

public func SCSDKLog(level: Int, module: String, file: String = #file, func: String = #function, line: Int = #line, text: String?) {
    let fileName = (file as NSString).lastPathComponent
    var logText = fileName + " :\(line) " + (text ?? "nil")
    logText = getNowDateText() + " " + logText
    
    if level == 0 {
        
    }
    else if level == 1 {
        
    }
    else if level == 2 {
        
    }
    else if level == 3 {
        
    }
    
    print(logText)
    
    if !(level == 0 && SCSmartSDK.sharedInstance.debugMode) {
        logText += "\n"
        SCSmartLogger.sharedInstance.writeTextData(text: logText)
    }
}

func getNowDateText(_ format: String = "yyyy-MM-dd HH:mm:ss SSS") -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = format
    let text = formatter.string(from: date)
    return text
}

public func SCSDKLog(_ text: String, file: String = #file) {
    SCSDKLog(level: 1, module: "SCSmartHomeKit", file: file, text: text)
}

public func SCSDKLogDebug(_ text: String, file: String = #file) {
    SCSDKLog(level: 0, module: "SCSmartHomeKit", file: file, text: text)
}

public func SCSDKLogInfo(_ text: String, file: String = #file) {
    SCSDKLog(level: 1, module: "SCSmartHomeKit", file: file, text: text)
}

public func SCSDKWarn(_ text: String, file: String = #file) {
    SCSDKLog(level: 2, module: "SCSmartHomeKit", file: file, text: text)
}

public func SCSDKError(_ text: String, file: String = #file) {
    SCSDKLog(level: 3, module: "SCSmartHomeKit", file: file, text: text)
}

/// 埋点日志
public func SCBPLog(_ text: String, file: String = #file) {
    let newText = "---埋点---" + text
    SCSDKLog(level: 9, module: "", file: file, text: newText)
}
