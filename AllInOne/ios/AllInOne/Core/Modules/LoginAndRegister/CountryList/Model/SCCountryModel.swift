//
//  SCCountryModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/24.
//

import UIKit
import WCDBSwift

fileprivate let SCCountryModelORMTableName = "country"
fileprivate let SCCountryDataBasePath = NSHomeDirectory() + "/Documents/database/country/com.country_new.db"
fileprivate let db = Database(withPath: SCCountryDataBasePath)

class SCCountrySectionModel {
    var title: String = ""
    var items: [SCCountryModel] = []
}

class SCCountryModel {
    var name: String = ""
    var name2: String = ""
    var firstLetter: String = ""
    var code: Int = 0
    var ab: String = ""
    
    var isSelected: Bool = false
    var hasTopLine: Bool = false
    
    var json: [String: Any] {
        var param: [String: Any] = [:]
        param["name"] = self.name
        param["ab"] = self.ab
        param["code"] = self.code
        return param
    }
    
    convenience init(json: [String: Any]) {
        self.init()
        
        self.name = (json["name"] as? String) ?? ""
        self.ab = (json["ab"] as? String) ?? ""
        self.code = (json["code"] as? Int) ?? 0
    }
}

class SCCountryModelORM: NSObject, TableCodable {
//    var country_id: Int = 0
//    var country_code: Int = 0
    var country_name_en: String = ""
    var country_name_cn: String = ""
    var ab: String = ""
    var country_name_py: String = ""
    var area_cn: String = ""
    var area_en: String = ""
    var country_allname_en = ""
    
    static var isCreatedTable: Bool = false
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = SCCountryModelORM
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
//        case country_id = "id"
//        case country_code
        case country_name_en
        case country_name_cn
        case ab
        case country_name_py = "pinyin"
        case area_cn
        case area_en
        case country_allname_en
    }
    
    class func setup() {
        if SCUserCenter.sharedInstance.isNewAppVersion || !FileManager.default.fileExists(atPath: SCCountryDataBasePath) {
            let path = Bundle.main.path(forResource: "country_new", ofType: "db")!
            let data = NSData(contentsOfFile: path)
            
            let directoryPath = NSHomeDirectory() + "/Documents/database/country"
            try? FileManager.default.removeItem(atPath: directoryPath)
            try? FileManager.default.createDirectory(atPath: NSHomeDirectory() + "/Documents/database/country", withIntermediateDirectories: false, attributes: nil)
            
            data?.write(toFile: SCCountryDataBasePath, atomically: true)
        }
    }
    
    class func getCountryList(languageType: SCLanguageType, currentAb: String = "") -> [SCCountrySectionModel] {
        if !self.isCreatedTable {
            self.setup()
            do {
                try db.create(table: SCCountryModelORMTableName, of: SCCountryModelORM.self)
                self.isCreatedTable = true
            } catch {
                SCSDKLog("db create table:\(SCCountryModelORMTableName) error")
                return []
            }
        }
        var sortKey: PropertyConvertible = SCCountryModelORM.Properties.country_name_en
        switch languageType {
        case .Chinese:
            sortKey = SCCountryModelORM.Properties.country_name_py
        case .English:
            sortKey = SCCountryModelORM.Properties.country_name_en
        default:
//            sortKey = SCCountryModelORM.Properties.country_id
            break
        }
        
        do {
            let orms: [SCCountryModelORM] = try db.getObjects(fromTable: SCCountryModelORMTableName, orderBy: [sortKey.asOrder(by: .ascending)])
            var result: [SCCountrySectionModel] = []
            var tmpItems: [SCCountryModel] = []
            var firstLetter: String = ""
            var sortName: String = ""
            
            for orm in orms {
                var name = ""
                var name2 = ""
                switch languageType {
                case .Chinese:
                    sortName = orm.country_name_py
                    name = orm.country_name_cn
                    name2 = orm.country_name_py
                case .English:
                    sortName = orm.country_name_en
                    name = orm.country_name_en
                default:
                    sortName = orm.country_name_en
                    name = orm.country_name_en
                }
                let letter = (sortName.lowercased() as NSString).substring(to: 1)
                if letter != firstLetter {
                    if tmpItems.count > 0 {
//                        tmpItems.first?.hasTopLine = true
                        let sectionModel = SCCountrySectionModel()
                        sectionModel.title = firstLetter.uppercased()
                        sectionModel.items = tmpItems
                        result.append(sectionModel)
                        tmpItems.removeAll()
                    }
                    firstLetter = letter
                }
                let item = SCCountryModel()
//                item.code = orm.country_code
                item.firstLetter = firstLetter
                item.name = name
                item.name2 = name2
                item.ab = orm.ab
                if item.ab == currentAb {
                    item.isSelected = true
                }
                tmpItems.append(item)
            }
            if tmpItems.count > 0 {
//                tmpItems.first?.hasTopLine = true
                let sectionModel = SCCountrySectionModel()
                sectionModel.title = firstLetter
                sectionModel.items = tmpItems
                result.append(sectionModel)
                tmpItems.removeAll()
            }
            return result
        } catch {
            
        }
        return []
    }
    
    class func modify() {
        do {
            let orms: [SCCountryModelORM] = try db.getObjects(fromTable: SCCountryModelORMTableName)
            for orm in orms {
                orm.country_name_py = kTransToPinYin(str: orm.country_name_cn)
                try db.update(table: SCCountryModelORMTableName, on: SCCountryModelORM.Properties.all, with: orm, where: SCCountryModelORM.Properties.country_name_cn == orm.country_name_cn)
            }
//            try db.commit()
//            db.close()
        } catch {
            print(error)
        }
    }
}
