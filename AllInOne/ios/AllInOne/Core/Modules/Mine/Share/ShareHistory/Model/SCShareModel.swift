//
//  SCShareModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/28.
//

import UIKit

enum SCShareInfoType: Int {
    case device = 0
    case family = 1
    
    var title: String {
        switch self {
        case .device:
            return tempLocalize("共享设备")
        case .family:
            return tempLocalize("共享家庭")
        }
    }
    
    var image: ThemeImagePicker {
        switch self {
        case .device:
            return "Mine.ShareTypeController.deviceImage"
        case .family:
            return "Mine.ShareTypeController.familyImage"
        }
    }
}

enum SCShareInfoStatus: Int {
    /// 普通
    case normal = 0
    /// 已同意
    case agreed = 1
    /// 已拒绝
    case refused = 2
    
    var name: String {
        switch self {
        case .normal:
            return tempLocalize("待处理")
        case .agreed:
            return tempLocalize("已同意")
        case .refused:
            return tempLocalize("已拒绝")
        }
    }
}


extension SCNetResponseShareInfoModel {
    private static let shareTypeAssociation = SCObjectAssociation<SCShareInfoType>.init(policy: .OBJC_ASSOCIATION_COPY)
    private static let shareStatusAssociation = SCObjectAssociation<SCShareInfoStatus>.init(policy: .OBJC_ASSOCIATION_COPY)
    private static let isOwnerAssociation = SCObjectAssociation<Bool>.init(policy: .OBJC_ASSOCIATION_ASSIGN)
    
    var shareType: SCShareInfoType {
        get {
            return SCNetResponseShareInfoModel.shareTypeAssociation[self] ?? .device
        }
        set {
            SCNetResponseShareInfoModel.shareTypeAssociation[self] = newValue
        }
    }
    
    var shareStatus: SCShareInfoStatus {
        get {
            return SCNetResponseShareInfoModel.shareStatusAssociation[self] ?? .normal
        }
        set {
            SCNetResponseShareInfoModel.shareStatusAssociation[self] = newValue
        }
    }
    
    var isOwner: Bool {
        get {
            return SCNetResponseShareInfoModel.isOwnerAssociation[self] ?? false
        }
        set {
            SCNetResponseShareInfoModel.isOwnerAssociation[self] = newValue
        }
    }
}
