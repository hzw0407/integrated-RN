//
//  UIView+SCExtension.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/24.
//

import UIKit
import SwiftTheme

enum SCGradientDirectionType {
    case topToBottom
    case leftToRight
    case bottomToTop
    case rightToLeft
}

extension UIView {
    convenience init(lineBackgroundColor color: ThemeColorPicker) {
        self.init()
        self.theme_backgroundColor = color
    }
    
    convenience init(backgroundColor: ThemeColorPicker? = nil, cornerRadius: CGFloat = 0) {
        self.init()
        self.theme_backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
    
    convenience init(gradientDirection: SCGradientDirectionType = .topToBottom, backgroundFromColor: ThemeColorPicker, backgroundToColor: ThemeColorPicker, size: CGSize, cornerRadius: CGFloat = 0) {
        self.init()
//        guard let fromColor = backgroundFromColor.value() as? UIColor, let toColor = backgroundToColor.value() as? UIColor else { return }
        
        var startPoint = CGPoint(x: 0.5, y: 0)
        var endPoint = CGPoint(x: 0.5, y: 1)
        switch gradientDirection {
        case .leftToRight:
            startPoint = CGPoint(x: 0, y: 0.5)
            endPoint = CGPoint(x: 1, y: 0.5)
            break
        case .bottomToTop:
            startPoint = CGPoint(x: 0.5, y: 1)
            endPoint = CGPoint(x: 0.5, y: 0)
            break
        case .rightToLeft:
            startPoint = CGPoint(x: 1, y: 0.5)
            endPoint = CGPoint(x: 0, y: 0.5)
            break
        default:
            break
        }
        
        let gradientLayer = CAGradientLayer()
//        gradientLayer.theme_colors = [backgroundFromColor, backgroundToColor]
        if let fromColor = backgroundFromColor.value() as? UIColor, let toColor = backgroundToColor.value() as? UIColor {
            gradientLayer.colors = [fromColor.cgColor, toColor.cgColor]
        }
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.layer.addSublayer(gradientLayer)
        
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
    
    @discardableResult
    func addGradientLayer(direction: SCGradientDirectionType, backgroundFromColor: ThemeColorPicker, backgroundToColor: ThemeColorPicker, size: CGSize) -> CAGradientLayer {
        var startPoint = CGPoint(x: 0.5, y: 0)
        var endPoint = CGPoint(x: 0.5, y: 1)
        switch direction {
        case .leftToRight:
            startPoint = CGPoint(x: 0, y: 0.5)
            endPoint = CGPoint(x: 1, y: 0.5)
            break
        case .bottomToTop:
            startPoint = CGPoint(x: 0.5, y: 1)
            endPoint = CGPoint(x: 0.5, y: 0)
            break
        case .rightToLeft:
            startPoint = CGPoint(x: 1, y: 0.5)
            endPoint = CGPoint(x: 0, y: 0.5)
            break
        default:
            break
        }
 
        let gradientLayer = CAGradientLayer()
        if let fromColor = backgroundFromColor.value() as? UIColor, let toColor = backgroundToColor.value() as? UIColor {
            gradientLayer.colors = [fromColor.cgColor, toColor.cgColor]
        }
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.layer.addSublayer(gradientLayer)
        
        return gradientLayer
    }
    
    convenience init(corner: UIRectCorner, backgroundColor: ThemeColorPicker?, cornerRadius: CGFloat, size: CGSize) {
        self.init()
        self.theme_backgroundColor = backgroundColor
        let maskLayer = CAShapeLayer()
        maskLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.layer.mask = maskLayer
//        let cornerRadius: CGFloat = 12
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), byRoundingCorners: corner, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        maskLayer.path = path.cgPath
    }
    
    convenience init(gradientDirection: SCGradientDirectionType = .topToBottom, backgroundFromColor: ThemeColorPicker, backgroundToColor: ThemeColorPicker, corner: UIRectCorner, cornerRadius: CGFloat, size: CGSize) {
        self.init()
        let maskLayer = CAShapeLayer()
        maskLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.layer.mask = maskLayer
//        let cornerRadius: CGFloat = 12
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), byRoundingCorners: corner, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        maskLayer.path = path.cgPath
        
        var startPoint = CGPoint(x: 0.5, y: 0)
        var endPoint = CGPoint(x: 0.5, y: 1)
        switch gradientDirection {
        case .leftToRight:
            startPoint = CGPoint(x: 0, y: 0.5)
            endPoint = CGPoint(x: 1, y: 0.5)
            break
        case .bottomToTop:
            startPoint = CGPoint(x: 0.5, y: 1)
            endPoint = CGPoint(x: 0.5, y: 0)
            break
        case .rightToLeft:
            startPoint = CGPoint(x: 1, y: 0.5)
            endPoint = CGPoint(x: 0, y: 0.5)
            break
        default:
            break
        }
        
        let gradientLayer = CAGradientLayer()
//        gradientLayer.theme_colors = [backgroundFromColor, backgroundToColor]
        if let fromColor = backgroundFromColor.value() as? UIColor, let toColor = backgroundToColor.value() as? UIColor {
            gradientLayer.colors = [fromColor.cgColor, toColor.cgColor]
        }
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.layer.addSublayer(gradientLayer)        
//        self.layer.masksToBounds = true
        
    }
}

extension UIView {
    func convertToImage(scale: CGFloat = UIScreen.main.scale) -> UIImage {
        var image: UIImage?
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, scale)
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

extension UIImage {
    func cornerImage(corner: UIRectCorner, cornerRadius: CGFloat) -> UIImage {
        var path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height), byRoundingCorners: corner, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        if cornerRadius == 0 {
            path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        UIGraphicsBeginImageContext(self.size)
        
        let ctx = UIGraphicsGetCurrentContext()
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        ctx?.addPath(path.cgPath)
        ctx?.clip()
        self.draw(in: rect)
        let newimage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newimage!
    }
}
