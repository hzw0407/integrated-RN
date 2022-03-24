//
//  Data+SCExtension.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/16.
//

import UIKit

extension Data {
    func hexString(_ separator: String = ":") -> String {
        return map { String(format: "%02x", $0) }.joined(separator: separator)
    }
    
    func transfromBigOrSmall() -> Data {
        let tempString = self.hexString("")
        var tempArray: [String] = []
        var i: Int = 0
        while i < self.count * 2 {
            let str = (tempString as NSString).substring(with: NSRange(location: i, length: 2))
            tempArray.append(str)
            i += 2
        }
        let reversedArray = tempArray.reversed()
        var reversedStr = ""
        for item in reversedArray {
            reversedStr.append(item)
        }
        let data = reversedStr.hexData() ?? self
        return data
    }
    

}

extension String {
    func hexData() -> Data? {
        var data = Data(capacity: self.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
}
