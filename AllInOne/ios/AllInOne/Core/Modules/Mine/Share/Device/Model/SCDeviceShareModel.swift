//
//  SCDeviceShareModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/29.
//

import UIKit

enum SCDeviceShareMenuType {
    /// 共享
    case share
    /// 接收
    case accept
    
    var name: String {
        switch self {
        case .share:
            return tempLocalize("共享")
        case .accept:
            return tempLocalize("接收")
        }
    }
}

extension SCNetResponseDeviceModel {
    private static let isSharedAssociation = SCObjectAssociation<Bool>.init(policy: .OBJC_ASSOCIATION_ASSIGN)
    private static let shareItemsAssociation = SCObjectAssociation<[SCNetResponseShareInfoModel]>.init(policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    
    var isShared: Bool {
        get {
            return SCNetResponseDeviceModel.isSharedAssociation[self] ?? false
        }
        set {
            SCNetResponseDeviceModel.isSharedAssociation[self] = newValue
        }
    }
    
    var shareItems: [SCNetResponseShareInfoModel] {
        get {
            return SCNetResponseDeviceModel.shareItemsAssociation[self] ?? []
        }
        set {
            SCNetResponseDeviceModel.shareItemsAssociation[self] = newValue
        }
    }
}
