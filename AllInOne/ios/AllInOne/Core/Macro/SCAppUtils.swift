//
//  SCAppUtils.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/24.
//

import UIKit

//绘制渐变色颜色的方法
public func kGradientLayer(threeColors: [CGColor], startPoint: CGPoint, endPoint: CGPoint, size: CGSize = .zero, localtions: [NSNumber]) -> CAGradientLayer {
    let layer = CAGradientLayer()
    layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    layer.colors = threeColors
    layer.startPoint = startPoint
    layer.endPoint = endPoint
    layer.locations = localtions
    
    return layer
}

//绘制渐变色颜色的方法
public func kGradientLayer(colors: [CGColor], startPoint: CGPoint, endPoint: CGPoint, size: CGSize = .zero) -> CAGradientLayer {
    let layer = CAGradientLayer()
    layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    layer.colors = colors
    layer.startPoint = startPoint
    layer.endPoint = endPoint
    layer.locations = [0, 1]
    
    return layer
}

public func kAddObserver(_ observer: Any, _ selector: Selector, _ name: String?, _ object: Any? = nil) {
    NotificationCenter.default.addObserver(observer, selector: selector, name: Notification.Name(rawValue: name ?? ""), object: object)
}

public func kPostNotification(_ name: String, userInfo: [AnyHashable : Any]? = nil) {
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: name), object: nil, userInfo: userInfo)
}

func kRemoveObserver(_ observer: Any, _ key: String? = nil ){
    if key == nil {
        NotificationCenter.default.removeObserver(observer)
    } else {
        NotificationCenter.default.removeObserver(observer, name: Notification.Name(key!), object: nil)
    }
}

func kGetNormalWindow() -> UIWindow? {
    var window = UIApplication.shared.keyWindow
    if window?.windowLevel != UIWindow.Level.normal {
        let windows = UIApplication.shared.windows
        for temp in windows {
            if temp.windowLevel == .normal {
                window = temp
                break
            }
        }
    }
    return window
}

func kGetTopController() -> UIViewController? {
    var topController: UIViewController? = nil
    let window = kGetNormalWindow()
    let frontView = window?.subviews.first
    let nextResponder = frontView?.next
    if nextResponder != nil && nextResponder!.isKind(of: UIViewController.self) {
        topController = nextResponder as? UIViewController
    } else {
        topController = window?.rootViewController
    }
    
    if topController != nil {
        while topController!.isKind(of: UITabBarController.self) || topController!.isKind(of: UINavigationController.self) {
            if topController!.isKind(of: UITabBarController.self) {
                topController = (topController as? UITabBarController)?.selectedViewController
            } else if topController!.isKind(of: UINavigationController.self) {
                topController = (topController as? UINavigationController)?.topViewController
            }
        }
        
        while topController!.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
    }
    
    return topController
}

func kGetNowDateText(_ format: String = "yyyy-MM-dd HH:mm:ss") -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = format
    let text = formatter.string(from: date)
    return text
}

let kAppVersionString = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""

var kAppName: String {
    if let name = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
        return name
    }
    if let name = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
        return name
    }
    if let name = Bundle.main.infoDictionary?["CFBundleName"] as? String {
        return name
    }
    return "App"
}


func kTransToPinYin(str:String)->String{
    
    //转化为可变字符串
    let mString = NSMutableString(string: str)
    
    //转化为带声调的拼音
    CFStringTransform(mString, nil, kCFStringTransformToLatin, false)
    
    //转化为不带声调
    CFStringTransform(mString, nil, kCFStringTransformStripDiacritics, false)
    
    //转化为不可变字符串
    let string = NSString(string: mString)
    
    //去除字符串之间的空格
    return string.replacingOccurrences(of: " ", with: "")
    
}
//rgb颜色值
 func RGBColor(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
    return UIColor.init(red: (r/255.0), green: (g/255.0), blue: (b/255.0), alpha: a)
}
