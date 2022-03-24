//
//  SCAlertSheetView.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/2/21.
//

import UIKit

typealias SCAlertSheetViewBlock = (_ index: Int) -> Void
private let kHorizontalMargin: CGFloat = 20

class SCAlertSheetView {
    private static let sharedInstance = SCAlertSheetView()
    
    private lazy var alertView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.theme_backgroundColor = "Global.AlertSheetView.backgroundColor"
        return view
    }()
    
    private lazy var container: UIView = {
        let view = UIView()
        view.theme_backgroundColor = "Global.AlertView.containerColor"
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var titleLabel: UILabel = UILabel(textColor: "Global.AlertSheetView.titleLabel.textColor", font: "Global.AlertSheetView.titleLabel.font", numberLines: 0, alignment: .center)
    
    private lazy var messageLabel: UILabel = UILabel(textColor: "Global.AlertView.messageLabel.textColor", font: "Global.AlertView.messageLabel.font", numberLines: 0, alignment: .center)
    
    private lazy var supplementLabel: UILabel = UILabel(textColor: "Global.AlertView.messageLabel.textColor", font: "Global.AlertView.messageLabel.font", numberLines: 0, alignment: .center)
    
    private lazy var btnContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    fileprivate var actionBlock: SCAlertSheetViewBlock?
    private var buttons: [UIButton] = []
    
    private let containerWidth: CGFloat = kSCScreenWidth - 2 * kHorizontalMargin
    
    init() {
        self.alertView.addSubview(self.container)
        self.container.addSubview(self.titleLabel)
        self.container.addSubview(self.messageLabel)
    }
    
    static func alert(title: String? = tempLocalize("提示"), message: String, supplement: String? = nil, actionsTitles: [String], callback: SCAlertSheetViewBlock?) {
        let `self` = SCAlertSheetView.sharedInstance
        self.actionBlock = callback
        self.messageLabel.text = message
        self.titleLabel.text = title
        let btnHeight: CGFloat = 50
        let btnSpacing: CGFloat = 8
        let horizontalMargin: CGFloat = 30
        let textWidth = self.containerWidth - 2 * horizontalMargin
        var totalHeight: CGFloat = 40 // 顶部高度
        if title != nil {
            self.titleLabel.isHidden = false
            let titleHeight: CGFloat = title!.textHeight(width: textWidth, font: self.titleLabel.font)
            self.titleLabel.frame = CGRect(x: horizontalMargin, y: totalHeight, width: self.containerWidth - 2 * horizontalMargin, height: titleHeight)
            totalHeight += titleHeight + 16
        }
        else {
            self.titleLabel.isHidden = true
        }
        let messageHeight: CGFloat = message.textHeight(width: textWidth, font: self.messageLabel.font)
        self.messageLabel.frame = CGRect(x: horizontalMargin, y: totalHeight, width: self.containerWidth - 2 * horizontalMargin, height: messageHeight)
        totalHeight += messageHeight
        totalHeight += 40
        
        if supplement != nil {
            self.supplementLabel.isHidden = false
            let supplementHeight: CGFloat = title!.textHeight(width: textWidth, font: self.supplementLabel.font)
            self.supplementLabel.frame = CGRect(x: horizontalMargin, y: totalHeight, width: self.containerWidth - 2 * horizontalMargin, height: supplementHeight)
            totalHeight += supplementHeight + 16
        }
        else {
            self.supplementLabel.isHidden = true
        }
        
        self.buttons.forEach { btn in
            btn.removeFromSuperview()
        }
        
        for subview in self.btnContainer.subviews {
            subview.removeFromSuperview()
        }
        for (i, title) in actionsTitles.enumerated() {
            let btn = UIButton(title, titleColor: "Global.AlertSheetView.actionButton.textColor", font: "Global.AlertView.actionButton.font", target: self, action: #selector(alertSheetAction(sender:)), backgroundColor: "Global.AlertView.actionButton.backgroundColor", cornerRadius: 12)
            btn.tag = i
//            if i == 0 {
//                btn.setTitleColor(.white, for: .normal)
//                btn.backgroundColor = kThemeColor
//            }
//            else {
//                btn.setTitleColor(kThemeColor, for: .normal)
//                btn.backgroundColor = UIColor(hex: 0x2658C3, alpha: 0.1)
//            }
            
            self.container.addSubview(btn)
            
            self.buttons.append(btn)
            
            btn.frame = CGRect(x: horizontalMargin, y: totalHeight, width: self.containerWidth - 2 * horizontalMargin, height: btnHeight)
            totalHeight += btnHeight + btnSpacing
        }
        totalHeight += 30
        
        let bottom: CGFloat = 60
        
        self.container.frame = CGRect(x: kHorizontalMargin, y: self.alertView.bounds.height - totalHeight - bottom, width: self.alertView.bounds.width - kHorizontalMargin * 2, height: totalHeight)
        self.show()
    }
    
    func show() {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        keyWindow.addSubview(self.alertView)
        self.alertView.isHidden = false
        
    }
    
    func hide() {
        for subview in self.btnContainer.subviews {
            subview.removeFromSuperview()
        }
        self.alertView.isHidden = true
        self.alertView.removeFromSuperview()
    }
    
    @objc func alertSheetAction(sender: UIButton) {
        self.hide()
        self.actionBlock?(sender.tag)
    }
}
