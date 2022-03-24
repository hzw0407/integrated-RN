//
//  SCSweeperMapNet.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/1/25.
//

import UIKit

typealias SCSweeperDownloadSuccess = (Data) -> Void
typealias SCSweeperDownloadFail = (Error) -> Void

enum SCSweeperGetMapType: Int {
    case none = -1
    /// 实时图
    case realTime = 1
    ///  记忆图
    case memory = 2
}

/// 获取url的类型
enum SCSweeperGetUrlType: Int {
    /// 实时图
    case realTimeMap = 1
    /// 记忆图
    case memoryMemory = 2
    /// 临时文件
    case temp = 3
    
    
}

class SCSweeperMapNet {
    var uid: String {
        return SCPluginNet.sharedInstance.uid
    }
    /// 商户ID
    var tenantId: String {
        return SCPluginNet.sharedInstance.tenantId
    }
    /// 产品型号
    var productModeCode: String = ""
    /// 设备sn
    var deviceSn: String = ""
    
    var downloads: [String: SCSweeperDownloadModel] = [:]
    
    /// 拉取实时地图
    func getRealTimeMap(isWorking: Bool = false, success: ((Data) -> Void)?) {
        let direction = self.getMapDirection(type: .realTimeMap)
        self.download(direction: direction, isRepeat: true, timeInterval: 5, repeatCount: 5, success: { data in
            (data as NSData).write(toFile: self.getMapLocalPath(type: .realTime), atomically: true)
            success?(data)
        }, failure: { error in
            
        })
    }
    
    func getMapDirection(type: SCSweeperGetUrlType) -> String {
        #if DEBUG
        return "1433245345114095616/3irobotix.iplus-r10m/01-01-2022/map/temp/0046690461_TEST220213I0009_1"
        #endif
        switch type {
        case .realTimeMap:
            return "\(self.tenantId)/\(self.productModeCode)/01-01-2022/map/temp/0046690461_\(self.deviceSn)_1"
        case .memoryMemory:
            return "\(self.tenantId)/\(self.productModeCode)/01-01-2022/map/temp/0046690461_\(self.deviceSn)_2"
        default:
            return ""
        }
    }
    
    func download(direction: String, serviceType: SCSmartNetHttpUploadServiceType = .map, isRepeat: Bool, timeInterval: TimeInterval, repeatCount: Int, success: SCSweeperDownloadSuccess?, failure: SCSweeperDownloadFail?) {
        var model = self.downloads[direction]
        if model == nil {
            model = SCSweeperDownloadModel()
            model?.direction = direction
            model?.isRepeat = isRepeat
            model?.repeatCount = repeatCount
            model?.timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: isRepeat, block: { [weak self] _ in
                SCPluginNet.sharedInstance.downloadByOssOrAws(direction: direction, serviceType: serviceType, success: { [weak self] data in
                    guard let `self` = self else { return }
                    if let model = self.downloads[direction] {
                        model.timer?.invalidate()
                        model.timer = nil
                        self.downloads[direction] = nil
                        success?(data)
                    }
                }, failure: { [weak self] error in
                    if let model = self?.downloads[direction] {
                        if model.repeatCount == model.currentIndex + 1 {
                            let error = NSError(domain: "Time out", code: -1, userInfo: nil)
                            failure?(error)
                        }
                    }
                })
                
                if let model = self?.downloads[direction] {
                    model.currentIndex += 1
                    if model.currentIndex == model.repeatCount {
                        model.timer?.invalidate()
                        model.timer = nil
                        self?.downloads[direction] = nil
                    }
                }
            })
            self.downloads[direction] = model
        }
    }
}

extension SCSweeperMapNet {
    private func getMapLocalPath(type: SCSweeperGetMapType) -> String {
        let path = NSHomeDirectory() + "/Library/Caches/AppCaches/map"
        var fileName = uid + "_" + self.deviceSn
        if type == .realTime {
            fileName += "_real.map"
        }
        else if type == .memory {
            fileName += "_memory.map"
        }
        var isDirectory: ObjCBool = true
        if !FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) {
            try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        return path + "/" + fileName
    }
}


class SCSweeperDownloadModel {
    /// 下载目录
    var direction: String = ""
    var isRepeat: Bool = false
    var repeatCount: Int = 0
    var currentIndex: Int = 0
    var outPath: String?
    var timer: Timer?
}
