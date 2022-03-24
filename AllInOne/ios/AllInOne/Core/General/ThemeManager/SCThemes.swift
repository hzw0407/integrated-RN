//
//  SCThemeType.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/24.
//

import Foundation
import SwiftTheme
import UIKit

private let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
private let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]

enum SCThemeType: Int {
    case basic = 0
    case night
    
    var fileName: String {
        switch self {
        case .basic:
            return "ThemeBasic"
        case .night:
            return "ThemeBasic"
        }
    }
}

class SCThemes {
    static var currentType: SCThemeType = .basic
    
    static func set(_ type: SCThemeType) {
        let filePath = Bundle.main.path(forResource: type.fileName, ofType: "json") ?? ""
        let data = try? Data.init(contentsOf: URL(fileURLWithPath: filePath))
        let dict = try? JSONSerialization.jsonObject(with: data ?? Data(), options: .fragmentsAllowed)
        
        self.currentType = type
        ThemeManager.setTheme(dict: (dict ?? [:]) as! NSDictionary, path: .mainBundle)
    }
    
    static func image(_ keyPath: String) -> UIImage? {
        let image = ThemeImagePicker(keyPath: keyPath).value() as? UIImage
        return image
    }
    
    static func add(WithFileName fileName: String) {
        let filePath = Bundle.main.path(forResource: fileName, ofType: "json") ?? ""
        let data = try? Data.init(contentsOf: URL(fileURLWithPath: filePath))
        let dict = (try? JSONSerialization.jsonObject(with: data ?? Data(), options: .fragmentsAllowed)) as? [String: Any]
        self.add(json: dict ?? [:])
    }
    
    static func add(json: [String: Any]) {
        let current = (ThemeManager.currentTheme as? Dictionary<String, Any>) ?? Dictionary()
        let dict = json.reduce(into: current) { (result, pair) in
            let (key, value) = pair
            result[key] = value
        }
        
        ThemeManager.setTheme(dict: dict as NSDictionary, path: .mainBundle)
    }
    
    static func reset() {
        self.set(self.currentType)
    }
}


//enum SCThemeType: Int {
//    case basic = 0
//    case night
//
//    // MARK: -
//
//    static var current = SCThemeType.basic
//    static var before  = SCThemeType.basic
//
//    // MARK: - Switch Theme
//
//    static func switchTo(_ theme: SCThemeType) {
//        before  = current
//        current = theme
//
//        switch theme {
//        case .basic   : ThemeManager.setTheme(jsonName: "ThemeBasic", path: .mainBundle)
//        case .night : ThemeManager.setTheme(jsonName: "ThemeNight", path: .mainBundle)
//        }
//    }
//
//    // MARK: - Switch Night
//
//    static func switchNight(_ isToNight: Bool) {
//        switchTo(isToNight ? .night : before)
//    }
//
//    static func isNight() -> Bool {
//        return current == .night
//    }
//
//    // MARK: - Download
//
//    static func downloadBlueTask(_ handler: @escaping (_ isSuccess: Bool) -> Void) {
//
//        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
//            guard let bundlePath = Bundle.main.url(forResource: "Blue", withExtension: "zip") else {
//                DispatchQueue.main.async {
//                    handler(false)
//                }
//                return
//            }
//            let manager = FileManager.default
//            let zipPath = cachesURL.appendingPathComponent("Blue.zip")
//
//            _ = try? manager.removeItem(at: zipPath)
//            _ = try? manager.copyItem(at: bundlePath, to: zipPath)
//
////            let isSuccess = SSZipArchive.unzipFile(atPath: zipPath.path,
////                                        toDestination: unzipPath.path)
////
////            DispatchQueue.main.async {
////                handler(isSuccess)
////            }
//        }
//    }
//
//    static func isBlueThemeExist() -> Bool {
//        return FileManager.default.fileExists(atPath: blueDiretory.path)
//    }
//
//    static let blueDiretory : URL = unzipPath.appendingPathComponent("Blue/")
//    static let unzipPath    : URL = libraryURL.appendingPathComponent("Themes")
//
//    static func image(_ keyPath: String) -> UIImage? {
//        let image = ThemeImagePicker(keyPath: keyPath).value() as? UIImage
//        return image
//    }
//}
