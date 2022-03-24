//
//  SCProgressHUD.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/26.
//

import UIKit
import MBProgressHUD

class SCProgressHUD {
    static var textShowDuration: TimeInterval = 2
    
    static var HUD: MBProgressHUD?
    
    class func showWaitHUD(text: String? = nil, duration showTime: TimeInterval = 15) {
        self.showAdded(view: UIApplication.shared.keyWindow!, text: text, duration: showTime, animated: true)
    }
    
    class func showHUD(_ text: String?) {
        self.showAdded(view: UIApplication.shared.keyWindow!, text: text, mode: .text, duration: self.textShowDuration, animated: true)
    }
    
    fileprivate class func showAdded(view: UIView, text: String? = nil, mode: MBProgressHUDMode = .indeterminate, duration showTime: TimeInterval = 0, animated: Bool) {
        var animated = animated
        if HUD != nil {
            self.hideHUD(animated: false)
            animated = false
        }
        HUD = MBProgressHUD.showAdded(to: view, animated: animated)
        HUD?.mode = mode
        if text != nil {
            HUD?.label.text = text
        }
        
        let tag = Int(Date().timeIntervalSince1970)
        HUD?.tag = tag
        if showTime > 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + showTime) {
                if HUD != nil && HUD?.alpha != 0 && HUD?.tag == tag {
                    self.hideHUD(animated: false)
                }
            }
        }
    }
    
    class func hideHUD(animated: Bool = true) {
        if HUD != nil {
            HUD?.hide(animated: animated)
            HUD = nil
        }
    }
}

extension UIViewController {
    func showWaitHUD(duration showTime: TimeInterval = 0) {
        SCProgressHUD.showAdded(view: self.view, duration: showTime, animated: true)
    }
    
    func showHUD(_ text: String?) {
        SCProgressHUD.showAdded(view: self.view, text: text, mode: .text, duration: SCProgressHUD.textShowDuration, animated: true)
    }
    
    func hideHUD() {
        SCProgressHUD.hideHUD()
    }
}

extension UIView {
    func showWaitHUD(duration showTime: TimeInterval = 0) {
        SCProgressHUD.showAdded(view: self, duration: showTime, animated: true)
    }
    
    func showHUD(_ text: String?) {
        SCProgressHUD.showAdded(view: self, text: text, mode: .text, duration: SCProgressHUD.textShowDuration, animated: true)
    }
    
    func hideHUD() {
        SCProgressHUD.hideHUD()
    }
}
