//
//  SCAppCacheManager.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/31.
//

import UIKit

class SCAppCacheManager: NSObject {
    class func loadCacheSizeString(finish: ((String) -> Void)?) {
        DispatchQueue.global().async {
            let size = self.getAllFoldersSize()
            var text = ""
            if size >= 1024 * 1024 * 1024 {
                text = String(format: "%.1f GB", Double(size) / (1024 * 1024 * 1024))
            }
            else if size >= 1024 * 1024 {
                text = String(format: "%.1f MB", Double(size) / (1024 * 1024))
            }
            else {
                text = String(format: "%.1f KB", Double(size) / 1024)
            }
            DispatchQueue.main.async {
                finish?(text)
            }
        }
    }
    
    class func clearAllCache(finish: (() -> Void)?) {
        DispatchQueue.global().async {
            let path = NSHomeDirectory() + "/Library/Caches/AppCaches"
            self.clearFolder(atPath: path)
            DispatchQueue.main.async {
                finish?()
                SCSmartLogger.sharedInstance.setup()
                SCSmartNetHttpCache.reset()
            }
        }
    }
    
    private class func getAllFoldersSize() -> Int {
        let path = NSHomeDirectory() + "/Library/Caches/AppCaches"
        let size = self.folderSize(atPath: path)
        return size
        
//        let loggerPath = NSHomeDirectory() + "/Library/Caches/WYNetLogger"
//        let debugLoggerPath = NSHomeDirectory() + "/Library/Caches/WYNetLoggerdebug"
//        let recordsPath = NSHomeDirectory() + "/Library/Caches/Records"
//        let imagesPath = NSHomeDirectory() + "/Library/Caches/Images"
//
//        var size: Int = 0
//        size += self.folderSize(atPath: loggerPath)
//        size += self.folderSize(atPath: debugLoggerPath)
//        size += self.folderSize(atPath: recordsPath)
//        size += self.folderSize(atPath: imagesPath)
//        return size
    }
    
    private class func getAllSubpaths(atPath path: String) -> [String] {
        if !FileManager.default.fileExists(atPath: path) { return [] }
        guard let files = FileManager.default.subpaths(atPath: path) else { return [] }
        return files
    }
    
    private class func folderSize(atPath path: String) -> Int {
        if !FileManager.default.fileExists(atPath: path) { return 0 }
        guard let files = FileManager.default.subpaths(atPath: path) else { return 0 }
        var totalSize = 0
        for file in files {
            let filePath = path + "/" + file
            if let attributes = try? FileManager.default.attributesOfItem(atPath: filePath) {
                if let size = attributes[FileAttributeKey.size] as? Int {
                    totalSize += size
                }
            }
        }
        return totalSize
    }
    
    private class func clearFolder(atPath path: String) {
        if !FileManager.default.fileExists(atPath: path) { return }
        guard let files = FileManager.default.subpaths(atPath: path) else { return }
        for file in files {
            let filePath = path + "/" + file
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: filePath))
        }
    }
}
