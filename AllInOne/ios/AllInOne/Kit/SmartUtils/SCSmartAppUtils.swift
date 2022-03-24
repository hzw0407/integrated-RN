//
//  SCSmartAppUtils.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/13.
//

import UIKit

var kSCScreenWidth: CGFloat {
    return UIScreen.main.bounds.width
}
var kSCScreenHeight: CGFloat {
    return UIScreen.main.bounds.height
}

/// 状态栏高度
let kSCStatusBarHeight: CGFloat = {
    return UIApplication.shared.statusBarFrame.height
}()
/// 导航栏高度
let kSCNavBarHeight: CGFloat = 44.0
/// 导航栏和状态栏的高度
let kSCNavAndStatusBarHeight: CGFloat = {
    return kSCNavBarHeight + kSCStatusBarHeight
}()
/// 屏幕下方安全高度
let kSCBottomSafeHeight: CGFloat = {
    if #available(iOS 11.0, *) {
        return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    } else {
        return 0
    }
}()

/// 屏幕上方安全高度
let kSCTopSafeHeight: CGFloat = {
    if #available(iOS 11.0, *) {
        return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
    } else {
        return 0
    }
}()


