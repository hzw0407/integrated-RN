//
//  SCDataBase.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/25.
//

import UIKit
import WCDBSwift

fileprivate let kDataBasePath = NSHomeDirectory() + "/Documents/database/com.main.db"

class SCDataBase {
    static let db = Database(withPath: kDataBasePath)
    
    class func setup() {
        SCWorkWifiModelORM.createTable()
    }
}
