//
//  SCPhotoBrowser.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/26.
//

import UIKit
import ZLPhotoBrowser
import Photos
import sqlcipher

/*
 相册服务
 */
class SCPhotoBrowser {
    /// 跳转到相册并获取选择的图片
    /// - Parameters:
    ///   - maxSelectCount: 最大选择图片的数量
    ///   - callback: 回调图片数组
    public class func pushPhotoLibrary(maxSelectCount: Int = 9, callback: (([UIImage]?) -> Void)?) {
        ZLPhotoConfiguration.default()
            .maxSelectCount(maxSelectCount)
            .allowSelectVideo(false)
            .editImageClipRatios([.wh1x1, .wh3x4, .wh16x9])
//            .imageStickerContainerView(ImageStickerContainerView())
            .navCancelButtonStyle(.image)
            .canSelectAsset { asset in
                return true
            }
            .noAuthorityCallback { type in
                switch type {
                case .library:
                    debugPrint("No library authority")
                case .camera:
                    debugPrint("No camera authority")
                case .microphone:
                    debugPrint("No microphone authority")
                }
            }
        
        let ac = ZLPhotoPreviewSheet(selectedAssets: [])
        ac.selectImageBlock = {(images, assets, isOriginal) in
            callback?(images)
        }
        ac.cancelBlock = {
            debugPrint("cancel select")
        }
        ac.selectImageRequestErrorBlock = { (errorAssets, errorIndexs) in
            debugPrint("fetch error assets: \(errorAssets), error indexs: \(errorIndexs)")
        }
        guard let vc = getTopController() else { return }
        ac.showPhotoLibrary(sender: vc)
    }
    
    /// 跳转到相册并获取选择的图片或视频
    /// - Parameters:
    ///   - allowSelectVideo: 是否允许选择视频
    ///   - maxSelectCount: 最大选择图片的数量
    ///   - callback: 回调图片数组
    public class func pushPhotoLibrary(allowSelectVideo: Bool = false, maxSelectCount: Int = 9, selectedAssets: [PHAsset], callback: (([UIImage], [PHAsset], Bool) -> Void)?) {
        ZLPhotoConfiguration.default()
            .maxSelectCount(maxSelectCount)
            .allowSelectVideo(allowSelectVideo)
            .editImageClipRatios([.wh1x1, .wh3x4, .wh16x9])
//            .imageStickerContainerView(ImageStickerContainerView())
            .navCancelButtonStyle(.image)
            .canSelectAsset { asset in
                return true
            }
            .noAuthorityCallback { type in
                switch type {
                case .library:
                    debugPrint("No library authority")
                case .camera:
                    debugPrint("No camera authority")
                case .microphone:
                    debugPrint("No microphone authority")
                }
            }
        
        let ac = ZLPhotoPreviewSheet(selectedAssets: selectedAssets)
        ac.selectImageBlock = {(images, assets, isOriginal) in
            callback?(images, assets, isOriginal)
        }
        ac.cancelBlock = {
            debugPrint("cancel select")
        }
        ac.selectImageRequestErrorBlock = { (errorAssets, errorIndexs) in
            debugPrint("fetch error assets: \(errorAssets), error indexs: \(errorIndexs)")
        }
        guard let vc = getTopController() else { return }
        ac.showPhotoLibrary(sender: vc)
    }
    
    public class func previewAssets(sender: UIViewController, assets: [PHAsset], index: Int, callback: (([UIImage], [PHAsset], Bool) -> Void)?) {
        let ac = ZLPhotoPreviewSheet()
        ac.selectImageBlock = { (images, assets, isOriginal) in
            callback?(images, assets, isOriginal)
        }
        
        ac.previewAssets(sender: sender, assets: assets, index: index, isOriginal: false, showBottomViewAndSelectBtn: true)
    }
    
    private class func getNormalWindow() -> UIWindow? {
        var window = UIApplication.shared.keyWindow
        if window?.windowLevel != UIWindow.Level.normal {
            let windows = UIApplication.shared.windows
            for temp in windows {
                if temp.windowLevel == .normal {
                    window = temp
                    break
                }
            }
        }
        return window
    }

    private class func getTopController() -> UIViewController? {
        var topController: UIViewController? = nil
        let window = kGetNormalWindow()
        let frontView = window?.subviews.first
        let nextResponder = frontView?.next
        if nextResponder != nil && nextResponder!.isKind(of: UIViewController.self) {
            topController = nextResponder as? UIViewController
        } else {
            topController = window?.rootViewController
        }
        
        if topController != nil {
            while topController!.isKind(of: UITabBarController.self) || topController!.isKind(of: UINavigationController.self) {
                if topController!.isKind(of: UITabBarController.self) {
                    topController = (topController as? UITabBarController)?.selectedViewController
                } else if topController!.isKind(of: UINavigationController.self) {
                    topController = (topController as? UINavigationController)?.topViewController
                }
            }
            
            while topController!.presentedViewController != nil {
                topController = topController?.presentedViewController
            }
        }
        
        return topController
    }

}
