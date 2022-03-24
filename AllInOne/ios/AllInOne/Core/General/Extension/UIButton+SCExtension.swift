//
//  UIButton+SCExtension.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/24.
//

import UIKit
import SwiftTheme

extension UIButton {
    convenience init(_ title: String?, titleColor: ThemeColorPicker?, font: ThemeFontPicker?, target: Any? = nil, action: Selector? = nil, highlightedTitleColor: ThemeColorPicker? = nil, disabledTitleColor: ThemeColorPicker? = nil, selectedTitleColor: ThemeColorPicker? = nil, backgroundColor: ThemeColorPicker? = nil, cornerRadius: CGFloat? = nil) {
        self.init()
        self.setTitle(title, for: .normal)
        self.theme_setTitleColor(titleColor, forState: .normal)
        self.theme_setTitleColor(highlightedTitleColor, forState: .highlighted)
        self.theme_setTitleColor(disabledTitleColor, forState: .disabled)
        self.theme_setTitleColor(selectedTitleColor, forState: .selected)
        if backgroundColor != nil {
            self.theme_backgroundColor = backgroundColor
        }
        if cornerRadius != nil {
            self.layer.cornerRadius = cornerRadius!
            self.layer.masksToBounds = true
        }
        self.titleLabel?.theme_font = font
        self.titleLabel?.lineBreakMode = .byTruncatingTail
        if target != nil && action != nil {
            self.addTarget(target, action: action!, for: .touchUpInside)
        }
    }
    
    convenience init(image: ThemeImagePicker? = nil, target: Any?, action: Selector, highlightedImage: ThemeImagePicker? = nil, selectedImage: ThemeImagePicker? = nil, backgroundColor: ThemeColorPicker? = nil, imageEdgeInsets: UIEdgeInsets = UIEdgeInsets()) {
        self.init()
        self.theme_setImage(image, forState: .normal)
        self.theme_setImage(highlightedImage, forState: .highlighted)
        self.theme_setImage(selectedImage, forState: .selected)
        self.theme_backgroundColor = backgroundColor
        self.imageEdgeInsets = imageEdgeInsets
        self.addTarget(target, action: action, for: .touchUpInside)
    }
}
