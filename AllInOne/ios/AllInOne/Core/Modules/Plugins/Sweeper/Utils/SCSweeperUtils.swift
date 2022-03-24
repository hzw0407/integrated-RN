//
//  SCSweeperUtils.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/2/15.
//

import UIKit

class SCSweeperUtils {
    static let shared = SCSweeperUtils()
    
    func setup() {
        SCThemes.add(WithFileName: "PluginSweeperTheme")
    }
    
    func clear() {
        SCThemes.reset()
    }
}
