//
//  UILabel+SCExtension.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/24.
//

import UIKit

extension UILabel {
    convenience init(text: String? = nil, textColor: ThemeColorPicker?, font: ThemeFontPicker?, backgroundColor: ThemeColorPicker? = nil, numberLines: Int = 1, alignment: NSTextAlignment = .left) {
        self.init()
        self.text = text
        self.theme_textColor = textColor
        self.theme_font = font
        self.theme_backgroundColor = backgroundColor
        self.numberOfLines = numberLines
        self.textAlignment = alignment
        self.lineBreakMode = .byTruncatingTail
    }
}
