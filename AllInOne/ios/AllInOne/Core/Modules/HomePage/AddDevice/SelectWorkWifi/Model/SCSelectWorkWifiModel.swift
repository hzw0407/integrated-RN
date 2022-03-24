//
//  SCSelectWorkWifiModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/15.
//

import UIKit
import WCDBSwift

fileprivate let SCSCWorkWifiModelORMTableName = "work_wifi"

class SCWorkWifiModel: NSObject {
    var ssid: String = ""
    var password: String = ""
    
    class func password(forSsid ssid: String) -> String {
        do {
            let orm: SCWorkWifiModelORM? = try SCDataBase.db.getObject(on: SCWorkWifiModelORM.Properties.all, fromTable: SCSCWorkWifiModelORMTableName, where: SCWorkWifiModelORM.Properties.ssid == ssid)
            return orm?.password ?? ""
        }
        catch let error {
            SCSDKLog("SCWorkWifiModelORM get password fail:\(error.localizedDescription) ")
        }
        return ""
    }
    
    class func getWorkWifiModels() -> [SCWorkWifiModel] {
        do {
            let orms: [SCWorkWifiModelORM] = try SCDataBase.db.getObjects(fromTable: SCSCWorkWifiModelORMTableName)
            var models: [SCWorkWifiModel] = []
            for orm in orms {
                let model = SCWorkWifiModel()
                model.ssid = orm.ssid
                model.password = orm.password
                models.append(model)
            }
            return models
        }
        catch let error {
            SCSDKLog("SCWorkWifiModelORM get models fail:\(error.localizedDescription) ")
        }
        return []
    }
    
    class func add(ssid: String, password: String) {
        do {
            let orm = SCWorkWifiModelORM()
            orm.ssid = ssid
            orm.password = password
            orm.updateTime = String(Int64(Date().timeIntervalSince1970))
            
            if self.getObject(ssid: ssid) == nil {
                try SCDataBase.db.insertOrReplace(objects: orm, intoTable: SCSCWorkWifiModelORMTableName)
            }
            else {
                try SCDataBase.db.update(table: SCSCWorkWifiModelORMTableName, on: SCWorkWifiModelORM.Properties.all, with: orm, where: SCWorkWifiModelORM.Properties.ssid == ssid)
            }
        }
        catch let error {
            SCSDKLog("SCWorkWifiModelORM add ssid fail:\(error.localizedDescription) ")
        }
    }
    
    private class func getObject(ssid: String) -> SCWorkWifiModelORM? {
        let orm: SCWorkWifiModelORM? = try? SCDataBase.db.getObject(on: SCWorkWifiModelORM.Properties.all, fromTable: SCSCWorkWifiModelORMTableName, where: SCWorkWifiModelORM.Properties.ssid == ssid)
        return orm
    }
}

class SCWorkWifiModelORM: NSObject, TableCodable {
    var ssid: String = ""
    var password: String = ""
    var updateTime: String = ""
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = SCWorkWifiModelORM
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case ssid
        case password
        case updateTime
    }
    
    class func createTable() {
        do {
            try SCDataBase.db.create(table: SCSCWorkWifiModelORMTableName, of: SCWorkWifiModelORM.self)
        }
        catch let error {
            SCSDKLog("SCWorkWifiModelORM create table fail:\(error.localizedDescription) ")
        }
    }
}
