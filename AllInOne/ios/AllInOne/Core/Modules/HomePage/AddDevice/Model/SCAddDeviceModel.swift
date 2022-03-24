//
//  SCAddDeviceModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/14.
//

import UIKit
import CoreBluetooth

enum SCProductCommunicationType: Int {
    case wifiAndBluetooth = 1
    case wifi = 2
    case bluetooth = 3
}

/*
 为产品类型父类增加属性“isSelected”
 */
extension SCNetResponseProductTypeParentModel {
    private static let isSelectedAssociation = SCObjectAssociation<Bool>.init(policy: .OBJC_ASSOCIATION_ASSIGN)
    
    /// 是否选中
    var isSelected: Bool {
        get {
            return SCNetResponseProductTypeParentModel.isSelectedAssociation[self] ?? false
        }
        set {
            SCNetResponseProductTypeParentModel.isSelectedAssociation[self] = newValue
        }
    }
}

extension SCNetResponseProductTypeMiddleModel {
    private static let itemsAssociation = SCObjectAssociation<[SCNetResponseProductModel]>.init(policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    
    /// 产品列表
    var items: [SCNetResponseProductModel] {
        get {
            return SCNetResponseProductTypeMiddleModel.itemsAssociation[self] ?? []
        }
        set {
            SCNetResponseProductTypeMiddleModel.itemsAssociation[self] = newValue
        }
    }
}


extension SCNetResponseProductModel {
    private static let cornerAssociation = SCObjectAssociation<UIRectCorner>.init(policy: .OBJC_ASSOCIATION_COPY)
    private static let searchNameAssociation = SCObjectAssociation<String>.init(policy: .OBJC_ASSOCIATION_COPY)
    private static let infoAssociation = SCObjectAssociation<SCNetResponseProductInfoModel>.init(policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    private static let communicationTypeAssociation = SCObjectAssociation<SCProductCommunicationType>.init(policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    private static let isBluetoothCommunicationAssociation = SCObjectAssociation<Bool>.init(policy: .OBJC_ASSOCIATION_ASSIGN)
    
    var corner: UIRectCorner? {
        get {
            return SCNetResponseProductModel.cornerAssociation[self]
        }
        set {
            SCNetResponseProductModel.cornerAssociation[self] = newValue
        }
    }
    
    var searchName: String? {
        get {
            return SCNetResponseProductModel.searchNameAssociation[self]
        }
        set {
            SCNetResponseProductModel.searchNameAssociation[self] = newValue
        }
    }
    
    var info: SCNetResponseProductInfoModel? {
        get {
            return SCNetResponseProductModel.infoAssociation[self]
        }
        set {
            SCNetResponseProductModel.infoAssociation[self] = newValue
        }
    }
    
    var communicationType: SCProductCommunicationType {
        get {
            return SCNetResponseProductModel.communicationTypeAssociation[self] ?? SCProductCommunicationType.wifiAndBluetooth
        }
        set {
            SCNetResponseProductModel.communicationTypeAssociation[self] = newValue
        }
    }
    
    var isBluetoothCommunication: Bool {
        get {
            return SCNetResponseProductModel.isBluetoothCommunicationAssociation[self] ?? false
        }
        set {
            SCNetResponseProductModel.isBluetoothCommunicationAssociation[self] = newValue
        }
    }
}

extension CBPeripheral {
    private static let macAssociation = SCObjectAssociation<String>.init(policy: .OBJC_ASSOCIATION_COPY)
    private static let productAssociation = SCObjectAssociation<String>.init(policy: .OBJC_ASSOCIATION_COPY)
    
    var mac: String? {
        get {
            return CBPeripheral.macAssociation[self]
        }
        set {
            CBPeripheral.macAssociation[self] = newValue
        }
    }
    
    var productId: String? {
        get {
            return CBPeripheral.productAssociation[self]
        }
        set {
            CBPeripheral.productAssociation[self] = newValue
        }
    }
}
