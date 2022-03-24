//
//  SCLocalize.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/24.
//

import UIKit

let kLanguageChangedNotificationKey = "kLanguageChangedNotificationKey"
fileprivate let kAppLanguageKey = "kAppLanguageKey"

enum SCLanguageType: Int {
    case Chinese = 1
    case English = 2
    case Spanish = 3
    case German = 4
    case French = 5
    case Polski = 6
    case Italian = 7
    case Russian = 8
    case Chinese_TW = 9
    case Thai = 10
    case Korean = 11
    case Turkish = 12
    case Portuguese = 13
    case Chinese_HK = 14
    case Czech = 15
    case Slovak = 16
    case Hungarian = 17
    case Japanese = 18
    
    var languageText: String {
        switch self {
        case .Chinese:
            return "zh-Hans"
        case .English:
            return "en"
        case .Spanish:
            return "es"
        case .German:
            return "de"
        case .French:
            return "fr"
        case .Polski:
            return "pl"
        case .Italian:
            return "it"
        case .Russian:
            return "ru"
        case .Chinese_TW:
            return "zh-Hant"
        case .Thai:
            return "th"
        case .Korean:
            return "ko"
        case .Turkish:
            return "tr"
        case .Portuguese:
            return "pt"
        case .Chinese_HK:
            return "zh-hk"
        case .Czech:
            return "cs"
        case .Slovak:
            return "sk"
        case .Hungarian:
            return "hu"
        case .Japanese:
            return "ja"
        
        }
    }
    
    var name: String {
        switch self {
        case .Chinese, .Chinese_TW, .Chinese_HK:
            return kLocalize("中文")
        case .English:
            return kLocalize("英文")
        case .Spanish:
            return kLocalize("settings_speech_language_es")
        case .German:
            return kLocalize("settings_speech_language_de")
        case .French:
            return kLocalize("settings_speech_language_fr")
        case .Polski:
            return noneLocalize("波兰语")
        case .Italian:
            return kLocalize("settings_speech_language_it")
        case .Russian:
            return noneLocalize("俄语")
        case .Thai:
            return noneLocalize("泰语")
        case .Korean:
            return noneLocalize("韩语")
        case .Turkish:
            return noneLocalize("土耳其语")
        case .Portuguese:
            return noneLocalize("葡萄牙语")
        case .Czech:
            return noneLocalize("捷克语")
        case .Slovak:
            return noneLocalize("斯诺伐克语")
        case .Hungarian:
            return noneLocalize("匈牙利语")
        case .Japanese:
            return noneLocalize("日语")
        }
    }
    
    var netLanguageText: String {
        switch self {
        case .Chinese:
            return "zh"
        case .English:
            return "en"
        case .Spanish:
            return "es"
        case .German:
            return "de"
        case .French:
            return "fr"
        case .Polski:
            return "pl"
        case .Italian:
            return "it"
        case .Russian:
            return "ru"
        case .Chinese_TW:
            return "zh-Hant"
        case .Thai:
            return "th"
        case .Korean:
            return "ko"
        case .Turkish:
            return "tr"
        case .Portuguese:
            return "pt"
        case .Chinese_HK:
            return "zh-hk"
        case .Czech:
            return "cs"
        case .Slovak:
            return "sk"
        case .Hungarian:
            return "hu"
        case .Japanese:
            return "ja"
        
        }
    }
}

let kSupportLanguageTypes: [SCLanguageType] = [.English, .Chinese]

var kSupportLanguageStrings: [String] {
    var strings: [String] = []
    for type in kSupportLanguageTypes {
        strings.append(type.languageText)
    }
    return strings
}

func tempLocalize(_ text: String) -> String {
    return text.localized()
}

func kLocalize(_ text: String) -> String {
    return text.localized()
}

func noneLocalize(_ text: String) -> String {
    return text.localized()
}

class SCLocalize {
    static let defaultLanguageType: SCLanguageType = .English
    
    fileprivate static let sharedInstance = SCLocalize()
    
    private var allLanguageJson: [String: [String: String]] = [:]
    private var languageJosn: [String: String] = [:]
    private var currentType: SCLanguageType = SCLocalize.defaultLanguageType
    
    init() {
        let type = SCLocalize.appLanguage()
        self.currentType = type
        
        let path = Bundle.main.path(forResource: "LocalizeString", ofType: "json")!
        let languagesJsonData = try! Data(contentsOf: URL(fileURLWithPath: path))
       
        let languagesJson = (try! JSONSerialization.jsonObject(with: languagesJsonData, options: .mutableContainers)) as! [String: [String: String]]
        
        self.allLanguageJson = languagesJson
        self.languageJosn = languagesJson[type.languageText] ?? [:]
    }
    
    public class func set(appLanguageType type: SCLanguageType) {
        SCProgressHUD.showWaitHUD()
        
        UserDefaults.standard.setValue(type.languageText, forKey: kAppLanguageKey)
        UserDefaults.standard.synchronize()

        SCLocalize.sharedInstance.currentType = type
        SCLocalize.sharedInstance.languageJosn = SCLocalize.sharedInstance.allLanguageJson[type.languageText] ?? [:]
        
        kPostNotification(kLanguageChangedNotificationKey)
        
        let tabBarController = SCTabBarController()
        tabBarController.selectedIndex = 2
        if let app = UIApplication.shared.delegate as? AppDelegate {
            app.window?.rootViewController = tabBarController
        }
        
        SCProgressHUD.hideHUD()
    }
    
    public class func appLanguage() -> SCLanguageType {
        let defaultType = SCLocalize.defaultLanguageType
        let currentLocalLanguageString = UserDefaults.standard.object(forKey: kAppLanguageKey) as? String
        if currentLocalLanguageString == nil {
            let type = self.systemLanguage()
            return type
        }
        let languageString = currentLocalLanguageString!
        for type in kSupportLanguageTypes {
            let text = type.languageText
            if languageString.hasPrefix(text) {
                return type
            }
        }
        return defaultType
    }
    
    public class func systemLanguage() -> SCLanguageType {
        let defaultType = SCLanguageType.English
        if let language = NSLocale.preferredLanguages.first {
            for type in kSupportLanguageTypes {
                let text = type.languageText
                if language.hasPrefix(text) {
                    return type
                }
            }
        }
        return defaultType
    }
    
    public class func localized(string: String) -> String {
        let text = SCLocalize.sharedInstance.languageJosn[string] ?? string
        return text
    }
}

extension String {
    func localized() -> String {
        SCLocalize.localized(string: self)
    }
}
