//
//  SCMessageCenterModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/24.
//

import UIKit

enum SCMessageCenterMessageType: Int {
    case share
    case device
    case system
    
    var title: String {
        switch self {
        case .share:
            return tempLocalize("共享消息")
        case .device:
            return tempLocalize("设备消息")
        case .system:
            return tempLocalize("系统消息")
        }
    }
}

enum SCMessageCenterShareMessageType: Int {
    case device
    case family
    
    var title: String {
        switch self {
        case .device:
            return tempLocalize("设备共享")
        case .family:
            return tempLocalize("家庭共享")
        }
    }
}

class SCMessageCenterMenuItemModel {
    var isSelected: Bool = false
    var type: SCMessageCenterMessageType = .share
    var hasNewMessage: Bool = false
}

class SCMessageCenterShareMenuItemModel {
    var isSelected: Bool = false
    var type: SCMessageCenterShareMessageType = .device
    var hasNewMessage: Bool = false
}


extension SCNetResponseShareNotificaitonRecordModel {
    private static let shareTypeAssociation = SCObjectAssociation<SCShareInfoType>.init(policy: .OBJC_ASSOCIATION_COPY)
    private static let shareStatusAssociation = SCObjectAssociation<SCShareInfoStatus>.init(policy: .OBJC_ASSOCIATION_COPY)
    private static let isOwnerAssociation = SCObjectAssociation<Bool>.init(policy: .OBJC_ASSOCIATION_ASSIGN)
    
    var shareType: SCShareInfoType {
        get {
            return SCNetResponseShareNotificaitonRecordModel.shareTypeAssociation[self] ?? .device
        }
        set {
            SCNetResponseShareNotificaitonRecordModel.shareTypeAssociation[self] = newValue
        }
    }
    
    var shareStatus: SCShareInfoStatus {
        get {
            return SCNetResponseShareNotificaitonRecordModel.shareStatusAssociation[self] ?? .normal
        }
        set {
            SCNetResponseShareNotificaitonRecordModel.shareStatusAssociation[self] = newValue
        }
    }
    
    var isOwner: Bool {
        get {
            return SCNetResponseShareNotificaitonRecordModel.isOwnerAssociation[self] ?? false
        }
        set {
            SCNetResponseShareNotificaitonRecordModel.isOwnerAssociation[self] = newValue
        }
    }
}
