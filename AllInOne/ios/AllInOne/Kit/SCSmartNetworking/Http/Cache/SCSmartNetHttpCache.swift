//
//  SCSmartNetHttpCache.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/28.
//

import UIKit
import WCDBSwift

fileprivate let SCHttpCacheTableName = "http_cache"
fileprivate let SCHttpCacheDataBasePath = NSHomeDirectory() + "/Documents/database/country/com.http_cache.db"
fileprivate let db: Database = Database(withPath: SCHttpCacheDataBasePath)

class SCSmartNetHttpCache {
    class SCHttpCacheORM: NSObject, TableCodable {
        var uid: String = ""
        var apiPath: String = ""
        var traceId: String = ""
        var paramString: String = ""
        var fileName: String = ""
        
        enum CodingKeys: String, CodingTableKey {
            typealias Root = SCHttpCacheORM
            static let objectRelationalMapping = TableBinding(CodingKeys.self)
            
            case uid
            case apiPath = "api_path"
            case traceId = "trace_id"
            case paramString = "param_string"
            case fileName = "file_name"
        }
        
        class func getObjests(uid: String, apiPath: String) -> [SCHttpCacheORM] {
            let orms: [SCHttpCacheORM] = (try? db.getObjects(fromTable: SCHttpCacheTableName, where: SCHttpCacheORM.Properties.uid == uid && SCHttpCacheORM.Properties.apiPath == apiPath, orderBy: [SCHttpCacheORM.Properties.traceId.asOrder(by: .descending)])) ?? []
            return orms
        }
        
        class func insetObject(apiPath: String, uid: String, traceId: String, paramString: String, fileName: String) {
            let data1 = paramString.data(using: .utf8) ?? Data()
            let json1 = (try? JSONSerialization.jsonObject(with: data1, options: .fragmentsAllowed)) as? [String: Any]
            
            let orms: [SCHttpCacheORM] = (try? db.getObjects(fromTable: SCHttpCacheTableName, where: SCHttpCacheORM.Properties.uid == uid && SCHttpCacheORM.Properties.apiPath == apiPath, orderBy: [SCHttpCacheORM.Properties.traceId.asOrder(by: .descending)])) ?? []
            if let json1 = json1 {
                for orm in orms {
                    let data2 = orm.paramString.data(using: .utf8) ?? Data()
                    if let json2 = (try? JSONSerialization.jsonObject(with: data2, options: .fragmentsAllowed)) as? [String: Any] {
                        if (json1 as NSDictionary).isEqual(to: json2) {
                            orm.traceId = traceId
                            orm.fileName = fileName
                            do {
                                try db.update(table: SCHttpCacheTableName, on: SCHttpCacheORM.Properties.all, with: orm, where: SCHttpCacheORM.Properties.uid == uid && SCHttpCacheORM.Properties.apiPath == apiPath && SCHttpCacheORM.Properties.paramString == orm.paramString)
                                return
                            } catch {
                                break
                            }
                        }
                    }
                }
            }
            else {
                for orm in orms {
                    orm.traceId = traceId
                    orm.fileName = fileName
                    do {
                        try db.update(table: SCHttpCacheTableName, on: SCHttpCacheORM.Properties.all, with: orm, where: SCHttpCacheORM.Properties.uid == uid && SCHttpCacheORM.Properties.apiPath == apiPath && SCHttpCacheORM.Properties.paramString == orm.paramString)
                        return
                    } catch {
                        break
                    }
                }
            }
 
            let object = SCHttpCacheORM()
            object.uid = uid
            object.apiPath = apiPath
            object.paramString = paramString
            object.traceId = traceId
            object.fileName = fileName
            try? db.insert(objects: [object], on: SCHttpCacheORM.Properties.all, intoTable: SCHttpCacheTableName)
        }
    }
    
    var cachePath: String = ""
    
    fileprivate static let shared = SCSmartNetHttpCache()
    
    init() {
        try? db.create(table: SCHttpCacheTableName, of: SCHttpCacheORM.self)
        self.setup()
    }
    
    private func setup() {
        let cachePath = NSHomeDirectory() + "/Library/Caches/AppCaches/Network/Http"
        var isDirectory: ObjCBool = true
        if !FileManager.default.fileExists(atPath: cachePath, isDirectory: &isDirectory) {
            try? FileManager.default.createDirectory(atPath: cachePath, withIntermediateDirectories: true, attributes: nil)
        }
        self.cachePath = cachePath
    }
    
    class func reset() {
        SCSmartNetHttpCache.shared.setup()
    }
    
    class func save(apiPath: String, uid: String, traceId: String, param: [String: Any], content: [String: Any]) {
        let `self` = SCSmartNetHttpCache.shared
        let paramData = (try? JSONSerialization.data(withJSONObject: param, options: JSONSerialization.WritingOptions.fragmentsAllowed)) ?? Data()
        let paramString = String(data: paramData, encoding: .utf8) ?? ""
        let fileName = self.getFileName(uid: uid, apiPath: apiPath)
        let filePath = self.cachePath + "/" + fileName
        let contentData = (try? JSONSerialization.data(withJSONObject: content, options: .fragmentsAllowed)) ?? Data()
        (contentData as NSData).write(toFile: filePath, atomically: true)
        
        SCHttpCacheORM.insetObject(apiPath: apiPath, uid: uid, traceId: traceId, paramString: paramString, fileName: fileName)
    }
    
    class func get(apiPath: String, uid: String, traceId: String, param: [String: Any]?) -> [String: Any]? {
        let `self` = SCSmartNetHttpCache.shared
        let objects = SCHttpCacheORM.getObjests(uid: uid, apiPath: apiPath)
        
        for object in objects {
            if let param = param {
                let paramData = object.paramString.data(using: .utf8) ?? Data()
                if let paramJson = (try? JSONSerialization.jsonObject(with: paramData, options: .fragmentsAllowed)) as? [String: Any] {
                    if (param as NSDictionary).isEqual(to: paramJson) {
                        let fileName = object.fileName
                        let filePath = self.cachePath + "/" + fileName
                        let resultData = (NSData(contentsOfFile: filePath) ?? NSData()) as Data
                        let result = try? JSONSerialization.jsonObject(with: resultData, options: .fragmentsAllowed)
                        return result as? [String: Any]
                    }
                }
            }
            else {
                let fileName = object.fileName
                let filePath = self.cachePath + "/" + fileName
                let resultData = (NSData(contentsOfFile: filePath) ?? NSData()) as Data
                let result = try? JSONSerialization.jsonObject(with: resultData, options: .fragmentsAllowed)
                return result as? [String: Any]
            }
        }
        return nil
    }
    
    private func getFileName(uid: String, apiPath: String) -> String {
        let string = uid + "-" + apiPath
        let md5String = string.MD5Encrypt(.lowercase32)
        return md5String
    }
}
