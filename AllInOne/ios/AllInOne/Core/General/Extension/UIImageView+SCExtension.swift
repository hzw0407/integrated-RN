//
//  UIImageView+SCExtension.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/24.
//

import UIKit

extension UIImageView {
    convenience init(image: ThemeImagePicker? = nil, contentMode: UIView.ContentMode = .scaleAspectFit, cornerRadius: CGFloat? = nil) {
        self.init(frame: .zero)
        self.contentMode = contentMode
        self.layer.masksToBounds = true
        self.theme_image = image
        if cornerRadius != nil {
            self.layer.cornerRadius = cornerRadius!
            self.layer.masksToBounds = true
        }
    }
}
