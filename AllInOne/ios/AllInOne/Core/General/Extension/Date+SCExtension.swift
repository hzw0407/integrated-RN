//
//  Date+SCExtension.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/1/7.
//

import UIKit

extension Date {
    func toString(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let text = formatter.string(from: self)
        return text
    }
    
    static func dateString(timeInterval: TimeInterval, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return date.toString(format: format)
    }
}
