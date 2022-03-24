//
//  String+SCExtension.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/24.
//

import UIKit

extension String {
    public func textHeight(width: CGFloat, font: UIFont) -> CGFloat {
        return self.size(boundingSize: CGSize(width: width, height: 999), font: font).height
    }
    
    public func textWidth(height: CGFloat, font: UIFont) -> CGFloat {
        return self.size(boundingSize: CGSize(width: 999, height: height), font: font).width
    }
    
    public func size(boundingSize: CGSize, font: UIFont) -> CGSize {
        let text = self as NSString
        return text.boundingRect(with: boundingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
    }
    
    public func reverse() -> String {
        var result = ""
        var index = self.count - 1
        while index >= 0 {
            let indexText = (self as NSString).substring(with: NSRange(location: index, length: 1))
            result += indexText
            index -= 1
        }
        return result
    }
}
