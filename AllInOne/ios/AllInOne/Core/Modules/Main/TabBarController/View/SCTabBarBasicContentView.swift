//
//  SCTabBarBasicContentView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/24.
//

import UIKit
import ESTabBarController_swift
import SwiftTheme

class SCTabBarBasicContentView: ESTabBarItemContentView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = ThemeColorPicker(keyPath: "Global.TabBar.textColor").value() as! UIColor
        highlightTextColor = ThemeColorPicker(keyPath: "Global.TabBar.highlightedTextColor").value() as! UIColor
        iconColor = ThemeColorPicker(keyPath: "Global.TabBar.iconColor").value() as! UIColor
        highlightIconColor = ThemeColorPicker(keyPath: "Global.TabBar.highlightIconColor").value() as! UIColor
        backdropColor = ThemeColorPicker(keyPath: "Global.TabBar.barTintColor").value() as! UIColor
        highlightBackdropColor = ThemeColorPicker(keyPath: "Global.TabBar.barTintColor").value() as! UIColor
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
