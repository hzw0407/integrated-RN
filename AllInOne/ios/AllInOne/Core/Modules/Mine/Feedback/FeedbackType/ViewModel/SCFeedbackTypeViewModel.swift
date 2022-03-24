//
//  SCFeedbackTypeViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/30.
//

import UIKit

class SCFeedbackTypeViewModel: SCBasicViewModel {
    private (set) var devicItems: [SCFeedbackTypeModel] = []
    private var devices: [SCNetResponseDeviceModel] = []
    private var products: [SCNetResponseProductModel] = []
    
    private var isCache: Bool = true
    
    func loadData(success: (() -> Void)?) {
        var isLoadedDevice: Bool = false
        var isLoadedProduct: Bool = false
        self.loadDeviceList { [weak self] in
            isLoadedDevice = true
            if isLoadedDevice && isLoadedProduct {
                self?.reloadData()
                success?()
            }
        }
        
        self.loadProductList { [weak self] in
            isLoadedProduct = true
            if isLoadedDevice && isLoadedProduct {
                self?.reloadData()
                success?()
            }
        }
    }
    
    private func reloadData() {
        self.isCache = false
        var items: [SCFeedbackTypeModel] = []
        for device in self.devices {
            if let _ = items.first(where: { $0.productId == device.productId }) { continue }
            let product = self.products.first(where: { $0.id == device.productId })
            let item = SCFeedbackTypeModel()
            item.title = product?.name ?? device.nickname
            item.type = .product
            item.productId = device.productId
            item.deviceId = device.deviceId
            item.imageUrl = device.photoUrl
            items.append(item)
        }
        self.devicItems = items
    }
    
    func loadDeviceList(success: (() -> Void)?) {
        SCSmartNetworking.sharedInstance.getDeviceListRequest(isCache: self.isCache) { [weak self] list in
            guard let `self` = self else { return }
            self.devices = list
//            var items: [SCFeedbackTypeModel] = []
//            for device in list {
//                let item = SCFeedbackTypeModel()
//                item.title = device.nickname
//                item.type = "device"
////                item.deviceId = device.deviceId
//                item.imageUrl = device.photoUrl
//                items.append(item)
//            }
//            self.devicItems = items
//            #if DEBUG
//            self.devicItems.append(contentsOf: items)
//            self.devicItems.append(contentsOf: items)
//            self.devicItems.append(contentsOf: items)
//            self.devicItems.append(contentsOf: items)
//            self.devicItems.append(contentsOf: items)
//            self.devicItems.append(contentsOf: items)
//            self.devicItems.append(contentsOf: items)
//            self.devicItems.append(contentsOf: items)
//            self.devicItems.append(contentsOf: items)
//            #endif
            success?()
        } failure: { error in
            
        }

    }
    
    func loadProductList(success: (() -> Void)?) {
        SCSmartNetworking.sharedInstance.getProductListRequest(isCache: self.isCache) { [weak self] list in
            #if DEBUG
            list.forEach { item in
                item.id = "1471011747589521408"
            }
            #endif
            self?.products = list
            success?()
        } failure: { error in
            
        }

//        SCSmartNetworking.sharedInstance.getProductTypeListRequest(classifyParentId: nil) { [weak self] parents in
//            guard let `self` = self else { return }
//            var items: [SCNetResponseProductModel] = []
//            for parent in parents {
//                for middle in parent.items {
//                    items.append(contentsOf: middle.items)
//                }
//            }
//            self.products = items
//            success?()
//        } failure: { error in
//
//        }

    }
}
