//
//  SCSmartUtils.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/10/19.
//

import UIKit

public typealias SCSuccessHandler = () -> Void
public typealias SCSuccessDict = ([String: Any]?) -> Void
public typealias SCSuccessString = (String) -> Void
public typealias SCSuccessList = ([Any]) -> Void
public typealias SCSuccessBool = (Bool) -> Void
public typealias SCSuccessAny = (Any) -> Void
public typealias SCSuccessInt = (Int) -> Void
public typealias SCSuccessLongLong = (CLongLong) -> Void
public typealias SCSuccessData = (Data) -> Void
public typealias SCProgressHandler = (Float) -> Void
public typealias SCSuccessModelHandler<T> = (T?) -> Void
public typealias SCSuccessModelArrayHandler<T> = ([T]) -> Void

public typealias SCFailureHandler = () -> Void
public typealias SCFailureError = (Error) -> Void

public func SCMainAsyncQueue(_ closure: @escaping () -> Void) {
    if Thread.isMainThread {
        closure()
    }
    else {
        DispatchQueue.main.async {
            closure()
        }
    }
}

public func SCGlobalAsyncQueue(_ closure: @escaping () -> Void) {
    DispatchQueue.global().async {
        closure()
    }
}

public class SCAppInformation {
    public static var appVersion: String {
        guard let info = Bundle.main.infoDictionary else { return "Unknown" }
        let version = (info["CFBundleShortVersionString"] as? String) ?? "Unknown"
        return version
    }

    public static var phoneSystemVersion: String {
        let version = UIDevice.current.systemVersion
        return version
    }
    
    public static var phoneModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let platform = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
            return String(cString: ptr)
        }
        if platform == "iPhone1,1" { return "iPhone 2G"}
        if platform == "iPhone1,2" { return "iPhone 3G"}
        if platform == "iPhone2,1" { return "iPhone 3GS"}
        if platform == "iPhone3,1" { return "iPhone 4"}
        if platform == "iPhone3,2" { return "iPhone 4"}
        if platform == "iPhone3,3" { return "iPhone 4"}
        if platform == "iPhone4,1" { return "iPhone 4S"}
        if platform == "iPhone5,1" { return "iPhone 5"}
        if platform == "iPhone5,2" { return "iPhone 5"}
        if platform == "iPhone5,3" { return "iPhone 5C"}
        if platform == "iPhone5,4" { return "iPhone 5C"}
        if platform == "iPhone6,1" { return "iPhone 5S"}
        if platform == "iPhone6,2" { return "iPhone 5S"}
        if platform == "iPhone7,1" { return "iPhone 6 Plus"}
        if platform == "iPhone7,2" { return "iPhone 6"}
        if platform == "iPhone8,1" { return "iPhone 6S"}
        if platform == "iPhone8,2" { return "iPhone 6S Plus"}
        if platform == "iPhone8,4" { return "iPhone SE"}
        if platform == "iPhone9,1" { return "iPhone 7"}
        if platform == "iPhone9,2" { return "iPhone 7 Plus"}
        if platform == "iPhone10,1" { return "iPhone 8"}
        if platform == "iPhone10,4" { return "iPhone 8"}
        if platform == "iPhone10,2" { return "iPhone 8 Plus"}
        if platform == "iPhone10,5" { return "iPhone 8 Plus"}
        if platform == "iPhone10,3" { return "iPhone X"}
        if platform == "iPhone10,6" { return "iPhone X"}
        if platform == "iPhone11,8" { return "iPhone XR"}
        if platform == "iPhone11,2" { return "iPhone XS"}
        if platform == "iPhone11,6" { return "iPhone XS Max"}
        if platform == "iPhone11,4" { return "iPhone XS Max"}
        if platform == "iPhone12,1" { return "iPhone 11"}
        if platform == "iPhone12,3" { return "iPhone 11 Pro"}
        if platform == "iPhone12,5" { return "iPhone 11 Pro Max"}
        if platform == "iPhone12,8" { return "iPhone SE(2nd generation)"}
        if platform == "iPhone13,1" { return "iPhone 12 mini"}
        if platform == "iPhone13,2" { return "iPhone 12"}
        if platform == "iPhone13,3" { return "iPhone 12 Pro"}
        if platform == "iPhone13,4" { return "iPhone 12 Pro Max"}
        if platform == "iPhone14,4" { return "iPhone 13 mini"}
        if platform == "iPhone14,5" { return "iPhone 13"}
        if platform == "iPhone14,2" { return "iPhone 13 Pro"}
        if platform == "iPhone14,3" { return "iPhone 13 Pro Max"}
        
        if platform == "iPod1,1" { return "iPod Touch 1G"}
        if platform == "iPod2,1" { return "iPod Touch 2G"}
        if platform == "iPod3,1" { return "iPod Touch 3G"}
        if platform == "iPod4,1" { return "iPod Touch 4G"}
        if platform == "iPod5,1" { return "iPod Touch 5G"}
        
        if platform == "iPad1,1" { return "iPad 1"}
        if platform == "iPad2,1" { return "iPad 2"}
        if platform == "iPad2,2" { return "iPad 2"}
        if platform == "iPad2,3" { return "iPad 2"}
        if platform == "iPad2,4" { return "iPad 2"}
        if platform == "iPad2,5" { return "iPad Mini 1"}
        if platform == "iPad2,6" { return "iPad Mini 1"}
        if platform == "iPad2,7" { return "iPad Mini 1"}
        if platform == "iPad3,1" { return "iPad 3"}
        if platform == "iPad3,2" { return "iPad 3"}
        if platform == "iPad3,3" { return "iPad 3"}
        if platform == "iPad3,4" { return "iPad 4"}
        if platform == "iPad3,5" { return "iPad 4"}
        if platform == "iPad3,6" { return "iPad 4"}
        if platform == "iPad4,1" { return "iPad Air"}
        if platform == "iPad4,2" { return "iPad Air"}
        if platform == "iPad4,3" { return "iPad Air"}
        if platform == "iPad4,4" { return "iPad Mini 2"}
        if platform == "iPad4,5" { return "iPad Mini 2"}
        if platform == "iPad4,6" { return "iPad Mini 2"}
        if platform == "iPad4,7" { return "iPad Mini 3"}
        if platform == "iPad4,8" { return "iPad Mini 3"}
        if platform == "iPad4,9" { return "iPad Mini 3"}
        if platform == "iPad5,1" { return "iPad Mini 4"}
        if platform == "iPad5,2" { return "iPad Mini 4"}
        if platform == "iPad5,3" { return "iPad Air 2"}
        if platform == "iPad5,4" { return "iPad Air 2"}
        if platform == "iPad6,11" { return "iPad 5"}
        if platform == "iPad6,12" { return "iPad 5"}
        if platform == "iPad6,3" { return "iPad Pro (9.7-inch)"}
        if platform == "iPad6,4" { return "iPad Pro (9.7-inch)"}
        if platform == "iPad6,7" { return "iPad Pro (12.9-inch)"}
        if platform == "iPad6,8" { return "iPad Pro (12.9-inch)"}
        if platform == "iPad7,5" { return "iPad 6"}
        if platform == "iPad7,6" { return "iPad 6"}
        if platform == "iPad7,11" { return "iPad 7"}
        if platform == "iPad7,12" { return "iPad 7"}
        if platform == "iPad7,1" { return "iPad Pro 2 (12.9-inch)"}
        if platform == "iPad7,2" { return "iPad Pro 2 (12.9-inch)"}
        if platform == "iPad7,3" { return "iPad Pro (10.5-inch)"}
        if platform == "iPad7,4" { return "iPad Pro (10.5-inch)"}
        if platform == "iPad8,1" { return "iPad Pro (11-inch)"}
        if platform == "iPad8,2" { return "iPad Pro (11-inch)"}
        if platform == "iPad8,3" { return "iPad Pro (11-inch)"}
        if platform == "iPad8,4" { return "iPad Pro (11-inch)"}
        if platform == "iPad8,5" { return "iPad Pro 3 (12.9-inch)"}
        if platform == "iPad8,6" { return "iPad Pro 3 (12.9-inch)"}
        if platform == "iPad8,7" { return "iPad Pro 3 (12.9-inch)"}
        if platform == "iPad8,8" { return "iPad Pro 3 (12.9-inch)"}
        if platform == "iPad8,9" { return "iPad Pro 2 (11-inch)"}
        if platform == "iPad8,10" { return "iPad Pro 2 (11-inch)"}
        if platform == "iPad8,11" { return "iPad Pro 4 (12.9-inch)"}
        if platform == "iPad8,12" { return "iPad Pro 4 (12.9-inch)"}
        
        if platform == "i386"   { return "iPhone Simulator"}
        if platform == "x86_64" { return "iPhone Simulator"}
        
        return platform
    }
}
