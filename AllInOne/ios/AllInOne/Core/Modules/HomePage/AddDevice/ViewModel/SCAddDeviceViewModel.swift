//
//  SCAddDeviceViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/14.
//

import UIKit
import CoreBluetooth

class SCAddDeviceViewModel: SCBasicViewModel {
    var parents: [SCNetResponseProductTypeParentModel] = []
//    var products: [SCNetResponseProductTypeChildModel] = []
    
//    var types: [SCNetResponseProductTypeMiddleModel] = []
    var products: [SCNetResponseProductModel] = []
    
    private var originalParents: [SCNetResponseProductTypeParentModel] = []
    
    private var isCache: Bool = true
    
    func loadData(success: (() -> Void)?) {
        var loadedProductData: Bool = false
        var loadedTypeData: Bool = false
        self.loadProductData {
            loadedProductData = true
            if loadedProductData && loadedTypeData {
                self.reloadData()
                success?()
            }
        }
        
        self.loadProductTypeData {
            loadedTypeData = true
            if loadedProductData && loadedTypeData {
                self.reloadData()
                success?()
            }
        }
    }
    
    private func reloadData() {
        self.isCache = false
        var newParents: [SCNetResponseProductTypeParentModel] = []
        for parent in self.originalParents {
            var newTypes: [SCNetResponseProductTypeMiddleModel] = []
            for type in parent.items {
                var items = self.products.filter({ $0.productClassifyId == type.id })
                if items.count == 0 {
                    continue
                }
                if items.count % 3 != 0 {
                    let addCount = (3 - items.count % 3)
                    for _ in 0..<addCount {
                        let item = SCNetResponseProductModel()
                        items.append(item)
                    }
                }
                for (i, item) in items.enumerated() {
                    var cornerRawValue: UInt = 0
                    if i == 0 {
                        cornerRawValue = cornerRawValue | UIRectCorner.topLeft.rawValue
                    }
                    if i == 2 {
                        cornerRawValue = cornerRawValue | UIRectCorner.topRight.rawValue
                    }
                    if i == items.count - 3 {
                        cornerRawValue = cornerRawValue | UIRectCorner.bottomLeft.rawValue
                    }
                    if i == items.count - 1 {
                        cornerRawValue = cornerRawValue | UIRectCorner.bottomRight.rawValue
                    }
                    item.corner = UIRectCorner(rawValue: cornerRawValue)
                }
                type.items = items
                
                newTypes.append(type)
            }
            if newTypes.count > 0 {
                parent.items = newTypes
                newParents.append(parent)
            }
        }
        self.parents = newParents
    }
    
    private func loadProductData(success: (() -> Void)?) {
        SCSmartNetworking.sharedInstance.getProductListRequest(isCache: self.isCache) { [weak self] list in
            self?.products = list
            for item in list {
                item.communicationType = SCProductCommunicationType(rawValue: item.communicationProtocol) ?? .wifiAndBluetooth
#if DEBUG
//item.dmsPrefix = "i"
//item.id = "1471011747589521408"
#endif
            }
            success?()
        } failure: { error in
            
        }

    }
    
    private func loadProductTypeData(success: (() -> Void)?) {
        #if DEBUG
        let p_titles = ["一年级", "二年级", "三年级", "四年级", "五年级"]
        let m_titles = ["扫地机", "智能门锁", "空调", "冰箱", "台灯"]
        let c_titles = ["DM2 wifi", "M1 BLE", "扫拖机器人260 BLE", "扫拖机器人M1S wifi", "扫拖机器人280 BLE", "DFK", "时刻记得了房间"]
        var parents = [SCNetResponseProductTypeParentModel]()
        for p_title in p_titles {
            let parent = SCNetResponseProductTypeParentModel()
            parent.name = p_title
            var middles: [SCNetResponseProductTypeMiddleModel] = []
            for m_title in m_titles {
                let middle = SCNetResponseProductTypeMiddleModel()
                let i = Int(arc4random() % UInt32(m_titles.count))
                middle.name = m_titles[i]
                var items: [SCNetResponseProductModel] = []
                for c_title in c_titles {
                    let child = SCNetResponseProductModel()
                    child.name = c_title
                    child.dmsPrefix = "i"
                    child.photoUrl = "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fsy0.img.it168.com%2Fcopy%2Ffawen8%2F3%2F3307%2F3307696%2F3%2F3307%2F3307696.jpg&refer=http%3A%2F%2Fsy0.img.it168.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1642055305&t=12e95945d42da111339693b7c47c5d7f"
                    items.append(child)
                }
                middle.items = items
                middles.append(middle)
            }
            parent.items = middles
            parents.append(parent)
        }
    for parent in parents {
//        for middle in parent.items {
//            self.products.append(contentsOf: middle.items)
//            if middle.items.count % 3 != 0 {
//                let addCount = (3 - middle.items.count % 3)
//                for _ in 0..<addCount {
//                    let item = SCNetResponseProductTypeChildModel()
//                    middle.items.append(item)
//                }
//            }
//            for (i, child) in middle.items.enumerated() {
//                if i == 0 {
//                    child.supportBluetooth = true
//                    child.deviceUuid = "63A56076-A3E5-205F-9AF4-F75344D255B8"
//                }
//                var cornerRawValue: UInt = 0
//                if i == 0 {
//                    cornerRawValue = cornerRawValue | UIRectCorner.topLeft.rawValue
//                }
//                if i == 2 {
//                    cornerRawValue = cornerRawValue | UIRectCorner.topRight.rawValue
//                }
//                if i == middle.items.count - 3 {
//                    cornerRawValue = cornerRawValue | UIRectCorner.bottomLeft.rawValue
//                }
//                if i == middle.items.count - 1 {
//                    cornerRawValue = cornerRawValue | UIRectCorner.bottomRight.rawValue
//                }
//                child.corner = UIRectCorner(rawValue: cornerRawValue)
//            }
//        }
    }
        self.originalParents = parents
        success?()
        #endif
        
        SCSmartNetworking.sharedInstance.getProductTypeListRequest(classifyParentId: nil, isCache: self.isCache) { [weak self] list in
            self?.originalParents = list
            var items: [SCNetResponseProductTypeMiddleModel] = []
            for parent in list {
                items.append(contentsOf: parent.items)
//                for middle in parent.items {
//                    if middle.items.count % 3 != 0 {
//                        let addCount = (3 - middle.items.count % 3)
//                        for _ in 0..<addCount {
//                            let item = SCNetResponseProductTypeChildModel()
//                            middle.items.append(item)
//                        }
//                    }
//                    for (i, child) in middle.items.enumerated() {
//                        var cornerRawValue: UInt = 0
//                        if i == 0 {
//                            cornerRawValue = cornerRawValue | UIRectCorner.topLeft.rawValue
//                        }
//                        if i == 2 {
//                            cornerRawValue = cornerRawValue | UIRectCorner.topRight.rawValue
//                        }
//                        if i == middle.items.count - 3 {
//                            cornerRawValue = cornerRawValue | UIRectCorner.bottomLeft.rawValue
//                        }
//                        if i == middle.items.count - 1 {
//                            cornerRawValue = cornerRawValue | UIRectCorner.bottomRight.rawValue
//                        }
//                        child.corner = UIRectCorner(rawValue: cornerRawValue)
//
//                        #if DEBUG
//                        child.ssidPrefix = "i"
//                        child.id = "1471011747589521408"
//                        #endif
//                    }
//                    items.append(contentsOf: middle.items)
//                }
            }
//            self?.types = items
            success?()
        } failure: { error in
            
        }

    }
    
    func startScanDevices(stateHandle: ((CBManagerState) -> Void)?, discoverDeviceHandle: (([SCNetResponseProductModel]) -> Void)?) {
//        var filterPeripheraNames: [String] = []
//        var filterPeripheralUuids: [String] = []
//        for product in self.products {
//            if !filterPeripheraNames.contains(product.ssidPrefix) {
//                filterPeripheraNames.append(product.ssidPrefix)
//            }
//            if product.deviceUuid.count > 0, !filterPeripheralUuids.contains(product.deviceUuid) {
//                filterPeripheralUuids.append(product.deviceUuid)
//            }
//        }
        
        SCBindDeviceBluetoothService.shared.startScan() { state in
            stateHandle?(state)
        } discoverPeripheralsHandle: { [weak self] periphrals in
            guard let `self` = self else { return }
            var items: [SCNetResponseProductModel] = []
            for periphral in periphrals {
                if let productId = periphral.productId {
                    if let item = self.products.first(where: { $0.id == productId }) {
//                        #if DEBUG
//                        item.supportBluetooth = true
//                        #endif
                        items.append(item)
                    }
                }
                
//                let name = periphral.name ?? ""
//                let uuid = periphral.identifier.uuidString
//                if let item = self.products.filter({ uuid == $0.deviceUuid }).first {
//                    items.append(item)
//                }
//                else if let item = self.products.filter({ name.hasPrefix($0.ssidPrefix) }).first {
//#if DEBUG
//item.supportBluetooth = true
//#endif
//                    items.append(item)
//                }
            }
            discoverDeviceHandle?(items)
        }
    }
    
    func stopScan() {
        SCBindDeviceBluetoothService.shared.stopScan()
    }
    
    func loadProductInfo(productIds: [String], success: (([SCNetResponseProductInfoModel]) -> Void)?) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.getProductInfoListRequest(productIds: productIds) { list in
            SCProgressHUD.hideHUD()
            success?(list)
        } failure: { error in
            SCProgressHUD.hideHUD()
        }

    }
    
    func loadProductInfo(id: String, success: ((SCNetResponseProductInfoModel?) -> Void)?) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.getProductInfoRequest(id: id, isCache: true) { model in
            SCProgressHUD.hideHUD()
            success?(model)
        } failure: { error in
            SCProgressHUD.hideHUD()
        }

    }
}
