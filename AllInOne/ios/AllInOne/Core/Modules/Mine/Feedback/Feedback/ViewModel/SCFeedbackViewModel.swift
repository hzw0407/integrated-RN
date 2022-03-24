//
//  SCFeedbackViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/1/6.
//

import UIKit
import SSZipArchive
import Photos

class SCFeedbackViewModel: SCBasicViewModel {
    func compress(images: [UIImage], assets: [PHAsset], success: ((Data) -> Void)?, failure: (() -> Void)?) {
        if images.count == 0 {
            success?(Data())
            return
        }
        SCProgressHUD.showWaitHUD(text: tempLocalize("压缩中..."), duration: 30)
        DispatchQueue.global().async {
            let tempPath = NSHomeDirectory() + "/Library/Caches/AppCaches/tmp"
            var isDirectory: ObjCBool = true
            if !FileManager.default.fileExists(atPath: tempPath, isDirectory: &isDirectory) {
                try? FileManager.default.createDirectory(atPath: tempPath, withIntermediateDirectories: true, attributes: nil)
            }
            
            let completionHandler: (([String]) -> Void) = { (filePaths) in
                let zipPath = tempPath + "/zipfile.zip"
                SSZipArchive.createZipFile(atPath: zipPath, withFilesAtPaths: filePaths)
                let data = (NSData(contentsOfFile: zipPath) as Data?) ?? Data()
                
                for file in filePaths {
                    try? FileManager.default.removeItem(atPath: file)
                }
                try? FileManager.default.removeItem(atPath: zipPath)
                SCMainAsyncQueue {
                    SCProgressHUD.hideHUD()
                    success?(data)
                }
            }
            
            var imagePaths: [String] = []
            var videoPaths: [String] = []
            var compressCount: Int = 0
            for (i, asset) in assets.enumerated() {
                if asset.mediaType == .video {
                    PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { avAsset, mix, info in
                        let filePath = tempPath + "/video\(i).mp4"
                        let fileUrl = URL(fileURLWithPath: filePath)
                        if avAsset != nil {
                            self.compressVideo(asset: avAsset!, outputUrl: fileUrl) {
                                videoPaths.append(filePath)
                                compressCount += 1
                                if compressCount == images.count {
                                    completionHandler(imagePaths + videoPaths)
                                }
                            } failure: {
                                SCMainAsyncQueue {
                                    SCProgressHUD.hideHUD()
                                    failure?()
                                }
                                return
                            }
                        }
                        else {
                            SCMainAsyncQueue {
                                SCProgressHUD.hideHUD()
                                failure?()
                            }
                            return
                        }
                    }
                }
                else {
                    let filePath = tempPath + "/image\(i).jpeg"
                    let data = images[i].compressImageQuality(toByte: 200 * 1024)
                    (data as NSData).write(toFile: filePath, atomically: true)
                    imagePaths.append(filePath)
                    compressCount += 1
                    if compressCount == images.count {
                        completionHandler(imagePaths + videoPaths)
                    }
                }
            }
        }
    }
    
    private func compressVideo(asset: AVAsset, outputUrl: URL, success: (() -> Void)?, failure: (() -> Void)?) {
        guard let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset960x540) else {
            failure?()
            return
        }
        session.outputURL = outputUrl
        session.outputFileType = .mp4
        session.shouldOptimizeForNetworkUse = true
        session.exportAsynchronously(completionHandler: {
            if session.status == .completed {
                SCSDKLog("压缩视频文件成功")
                success?()
            }
            else {
                failure?()
            }
        })
    }
    
    func upload(dataFileURL: URL, success: ((String?) -> Void)?, failure: (() -> Void)?) {
        let fileSize = ((try? FileManager.default.attributesOfItem(atPath: dataFileURL.path))?[FileAttributeKey.size] as? Int) ?? 0
        if fileSize == 0 {
            success?(nil)
            return
        }
//        let fileName = "feedback-\(SCSmartNetworking.sharedInstance.user?.id ?? "")-\(Int(Date().timeIntervalSince1970)).zip"
        let fileName = (SCUserCenter.sharedInstance.user?.id ?? "") + String(UInt64(Date().timeIntervalSince1970))
        let directory = SCUserCenter.sharedInstance.netConfig.tenantId + "/" + "1471011747589521408" + "/" + "feedback" + "/" + fileName
        SCSmartNetworking.sharedInstance.uploadFile(directory: directory, serviceType: .all, dataFileURL: dataFileURL) { progress in
        } success: { url in
            success?(url)
        } failure: { error in
            failure?()
        }
    }
    
    func upload(data: Data, success: ((String?) -> Void)?, failure: (() -> Void)?) {
        let fileSize = data.count
        if fileSize == 0 {
            success?(nil)
            return
        }
        let day = Date().toString(format: "dd-MM-yyyy")
        let timestampString = String(UInt64(Date().timeIntervalSince1970)).reverse()
        let fileName = timestampString + "_" + (SCUserCenter.sharedInstance.user?.id ?? "") + ".zip"
        let directory = SCUserCenter.sharedInstance.netConfig.tenantId + "/" + SCUserCenter.sharedInstance.netConfig.projectType + "/" + "feedback" + "/" + day + "/" + fileName
        
        SCSmartNetworking.sharedInstance.uploadData(directory: directory, serviceType: .all, data: data) { progress in
            
        } success: { url in
            success?(url)
        } failure: { error in
            failure?()
        }

    }
    
    func uploadFeedback(productId: String, title: String?, phone: String, question: String, type: String, questionType: String, routerModel: String?, images: [UIImage], assets: [PHAsset], success: (() -> Void)?) {
        if question.count == 0 {
            SCProgressHUD.showHUD(tempLocalize("内容不能为空"))
            return
        }
        else if phone.count == 0 {
            SCProgressHUD.showHUD(tempLocalize("联系方式不能为空"))
            return
        }
        SCSDKLog("开始压缩文件")
        self.compress(images: images, assets: assets) { [weak self] data in
            SCProgressHUD.showWaitHUD(text: tempLocalize("上传中..."), duration: 120)
            if data.count > 0 {
                self?.upload(data: data, success: { url in
                    SCSmartNetworking.sharedInstance.uploadFeedbackRequest(productId: productId, title: title, phone: phone, question: question, type: type, questionType: questionType, routerModel: routerModel, url: url, success: {
                        SCProgressHUD.showHUD(tempLocalize("发送成功"))
                        success?()
                    }, failure: { error in
                        SCProgressHUD.showHUD(tempLocalize("发送失败"))
                    })
                }, failure: {
                    SCProgressHUD.showHUD(tempLocalize("上传文件失败"))
                })
            }
            else {
                SCSmartNetworking.sharedInstance.uploadFeedbackRequest(productId: productId, title: title, phone: phone, question: question, type: type, questionType: questionType, routerModel: routerModel, url: nil, success: {
                    SCProgressHUD.showHUD(tempLocalize("发送成功"))
                    success?()
                }, failure: { error in
                    SCProgressHUD.showHUD(tempLocalize("发送失败"))
                })
            }
            
//            if let dataFileURL = dataFileURL {
//                self?.upload(dataFileURL: dataFileURL, success: { url in
//                    SCSmartNetworking.sharedInstance.uploadFeedbackRequest(productId: productId, title: title, phone: phone, question: question, type: type, questionType: questionType, routerModel: routerModel, url: url, success: {
//                        SCProgressHUD.showHUD(tempLocalize("发送成功"))
//                        success?()
//                    }, failure: { error in
//                        SCProgressHUD.showHUD(tempLocalize("发送失败"))
//                    })
//                }, failure: {
//                    SCProgressHUD.showHUD(tempLocalize("上传文件失败"))
//                })
//            }
//            else {
//                SCSmartNetworking.sharedInstance.uploadFeedbackRequest(productId: productId, title: title, phone: phone, question: question, type: type, questionType: questionType, routerModel: routerModel, url: nil, success: {
//                    SCProgressHUD.showHUD(tempLocalize("发送成功"))
//                    success?()
//                }, failure: { error in
//                    SCProgressHUD.showHUD(tempLocalize("发送失败"))
//                })
//            }
        } failure: {
            SCProgressHUD.showHUD(tempLocalize("压缩文件失败"))
        }
//
//
//        SCProgressHUD.showWaitHUD()
//        self.upladFiles(images: images) { url in
//            SCSmartNetworking.sharedInstance.uploadFeedbackRequest(deviceId: deviceId, title: title, phone: phone, question: question, type: type, questionType: questionType, routerModel: routerModel, url: url, success: {
//                SCProgressHUD.showHUD(tempLocalize("发送成功"))
//                success?()
//            }, failure: { error in
//                SCProgressHUD.showHUD(tempLocalize("发送失败"))
//            })
//        } failure: {
//            SCProgressHUD.showHUD(tempLocalize("发送失败"))
//        }
    }
}


extension UIImage {
    private static let isOriginalAssociation = SCObjectAssociation<Bool>.init(policy: .OBJC_ASSOCIATION_ASSIGN)
    
    /// 是否为原图
    var isOriginal: Bool {
        get {
            return UIImage.isOriginalAssociation[self] ?? false
        }
        set {
            UIImage.isOriginalAssociation[self] = newValue
        }
    }
}
