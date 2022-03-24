//
//  SCSmartLogger.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/10/19.
//

import UIKit

fileprivate let kLogDataCountMax: Int = 1024 * 1024 * 100

class SCSmartLogger {
    static let sharedInstance = SCSmartLogger()
    
    private let queue: DispatchQueue = DispatchQueue(label: "scsdk.logger.queue", qos: DispatchQoS.default, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
    private let writeQueue = DispatchQueue(label: "scsdk.logger.write.queue", qos: DispatchQoS.default, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
    
    private var loggerPath: String = ""
    private var loggerFilePath: String = ""
    
    fileprivate init() {
        #if DEBUG
        print(NSHomeDirectory())
        #endif
        
        self.setup()
        
        self.checkFiles()
    }
    
    func setup() {
        var isDirectory: ObjCBool = true
        var fileDirectory: ObjCBool = false
        let time = self.getNowDateText()
        var loggerPath = NSHomeDirectory() + "/Library/Caches/AppCaches/SCSDKLogger"
        #if DEBUG
        loggerPath = NSHomeDirectory() + "/Library/Caches/AppCaches/SCSDKLoggerbug"
        #endif
        let debugPath = loggerPath + "/\(time).txt"
        
        let loggerExisted = FileManager.default.fileExists(atPath: loggerPath, isDirectory: &isDirectory)
        if !loggerExisted {
            try? FileManager.default.createDirectory(atPath: loggerPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        let debugExisted = FileManager.default.fileExists(atPath: debugPath, isDirectory: &fileDirectory)
        if !debugExisted {
            FileManager.default.createFile(atPath: debugPath, contents: nil, attributes: nil)
        }
       
        self.loggerPath = loggerPath
        self.loggerFilePath = debugPath
    }
    
    func writeTextData(text: String) {
        // 写入文件
        let textData = text.data(using: .utf8) ?? Data()
        self.writeQueue.sync {
            let debugHandle = FileHandle(forUpdatingAtPath: self.loggerFilePath)
            debugHandle?.seekToEndOfFile()
            debugHandle?.write(textData)
            debugHandle?.closeFile()
        }
    }
    
    func write(exceptionLog: String, ext: String) {
        let path = (self.loggerFilePath as NSString).substring(to: self.loggerFilePath.count - "txt".count) + "exception.\(ext).txt"
        let textData = exceptionLog.data(using: .utf8) ?? Data()
        try? textData.write(to: URL(fileURLWithPath: path))
    }
    
    private func getNowDateText(_ format: String = "yyyy-MM-dd HH:mm:ss SSS") -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let text = formatter.string(from: date)
        return text
    }
    
    private func checkFiles() {
        self.queue.async {
            while self.folderSize(atPath: self.loggerPath) > kLogDataCountMax {
                if !FileManager.default.fileExists(atPath: self.loggerPath) { return }
                guard var files = FileManager.default.subpaths(atPath: self.loggerPath) else { return }
                files = files.sorted(by: { (obj1, obj2) -> Bool in
                    return obj1.compare(obj2) == .orderedAscending
                })
                guard let file = files.first else { return }
                let filePath = self.loggerPath + "/" + file
                try? FileManager.default.removeItem(atPath: filePath)
            }
        }
    }
    
    private func folderSize(atPath path: String) -> Int {
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
    
    /// 获取当前的日志文件路径
    private func getCurrentLogPath() -> String? {
        if !FileManager.default.fileExists(atPath: self.loggerPath) { return nil }
        guard var files = FileManager.default.subpaths(atPath: self.loggerPath) else { return nil }
        files = files.sorted(by: { (obj1, obj2) -> Bool in
            return obj1.compare(obj2) == .orderedAscending
        })
        return files.last
    }
    
    func syncReadCurrentTextData() -> Data? {
        guard let file = self.getCurrentLogPath() else {
            return nil
        }
        let filePath = self.loggerPath + "/" + file
        let url = URL(fileURLWithPath: filePath)
        let logData = try? Data(contentsOf: url)
        return logData
    }
    
//    /// 获取最新的日志文件数据
//    func readCurrentTextData(callback: @escaping (Data?) -> Void) {
//        self.queue.async { [weak self] in
//            guard let `self` = self else { return }
//
//            guard let file = self.getCurrentLogPath() else {
//                callback(nil)
//                return
//            }
//
//            let filePath = self.loggerPath + "/" + file
//            let logData = try? Data(contentsOf: URL(fileURLWithPath: filePath))
//
////            let newFilePath = NSTemporaryDirectory() + "/" + String(format: "%@.txt", self.getNowDateText())
////
////            try? FileManager.default.copyItem(atPath: filePath, toPath: newFilePath)
////
////            let zipPath = NSTemporaryDirectory() + "log.zip"
////            SSZipArchive.createZipFile(atPath: zipPath, withFilesAtPaths: [newFilePath])
////            let url = URL(fileURLWithPath: zipPath)
////            let logData = try? Data(contentsOf: url)
//            callback(logData)
//        }
//    }
    
    func readAllTextDatas(callback: @escaping ([(Data, String)], String) -> Void) {
        self.queue.async { [weak self] in
            guard let `self` = self else { return }
            
            if !FileManager.default.fileExists(atPath: self.loggerPath) {
                callback([], "")
                return
            }
            guard let files = FileManager.default.subpaths(atPath: self.loggerPath) else {
                callback([], "")
                return
            }
            
            var datas: [(Data, String)] = []
            for file in files {
                let filePath = self.loggerPath + "/" + file
                if let logData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
                    datas.append((logData, filePath))
                }
            }
            callback(datas, self.loggerFilePath)
        }
    }
    
    func readAllTextDatasWithoutCurrent(callback: @escaping ([(Data, String)]) -> Void) {
        self.queue.async { [weak self] in
            guard let `self` = self else { return }
            
            if !FileManager.default.fileExists(atPath: self.loggerPath) {
                callback([])
                return
            }
            guard let files = FileManager.default.subpaths(atPath: self.loggerPath) else {
                callback([])
                return
            }
            
            var datas: [(Data, String)] = []
            for file in files {
                let filePath = self.loggerPath + "/" + file
                if filePath != self.loggerFilePath {
                    if let logData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
                        datas.append((logData, filePath))
                    }
                    
//                    let newFilePath = NSTemporaryDirectory() + "/" + String(format: "%@.txt", self.getNowDateText())
//
//                    try? FileManager.default.copyItem(atPath: filePath, toPath: newFilePath)
//
//                    let zipPath = NSTemporaryDirectory() + "/" + "yflog.zip"
//                    SSZipArchive.createZipFile(atPath: zipPath, withFilesAtPaths: [newFilePath])
//                    let url = URL(fileURLWithPath: zipPath)
//                    if let logData = try? Data(contentsOf: url) {
//                        datas.append((logData, filePath))
//                    }
                }
            }
            callback(datas)
        }
    }
    
    func deleteAllTextDataWithoutCurrent() {
        self.queue.async {
            if !FileManager.default.fileExists(atPath: self.loggerPath) { return }
            guard let files = FileManager.default.subpaths(atPath: self.loggerPath) else { return }
            
            for file in files {
                let filePath = self.loggerPath + "/" + file
                if filePath != self.loggerFilePath {
                    try? FileManager.default.removeItem(atPath: filePath)
                }
            }
            
        }
    }
}
