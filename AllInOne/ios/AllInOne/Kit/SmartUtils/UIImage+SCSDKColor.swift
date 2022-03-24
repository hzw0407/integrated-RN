//
//  UIImage+SCSDKColor.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/10/21.
//

import UIKit

extension UIImage {
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
    }
}

extension UIImage {
    func compressImageQuality(toByte maxLength: Int) -> Data {
        var compression: CGFloat = 1
        var data = self.jpegData(compressionQuality: compression) ?? Data()
        if data.count < maxLength {
            return data
        }
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0..<8 {
            compression = (max + min) / 2
            data = self.jpegData(compressionQuality: compression) ?? data
            if CGFloat(data.count) < CGFloat(maxLength) * 0.9 {
                min = compression
            } else if data.count > maxLength {
                max = compression
            } else {
                break
            }
        }
        return data
    }
}
