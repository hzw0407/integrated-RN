//
//  SCHomePageDeviceModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/17.
//

import UIKit

/*
 房间类型
 */
enum SCFamilyRoomType: Int {
    /// 普通
    case normal = 0
    /// 常用
    case used = 1
    /// 共享
    case share = 2
    /// 不显示 (未分配)
    case none = -1
}

extension SCNetResponseDeviceModel {
    private static let isEditingAssociation = SCObjectAssociation<Bool>.init(policy: .OBJC_ASSOCIATION_ASSIGN)
    private static let isSelectedAssociation = SCObjectAssociation<Bool>.init(policy: .OBJC_ASSOCIATION_ASSIGN)
    private static let isOwnerAssociation = SCObjectAssociation<Bool>.init(policy: .OBJC_ASSOCIATION_ASSIGN)
    
    /// 是否在编辑中
    var isEditing: Bool {
        get {
            return SCNetResponseDeviceModel.isEditingAssociation[self] ?? false
        }
        set {
            SCNetResponseDeviceModel.isEditingAssociation[self] = newValue
        }
    }
    
    /// 是否选中状态
    var isSelected: Bool {
        get {
            return SCNetResponseDeviceModel.isSelectedAssociation[self] ?? false
        }
        set {
            SCNetResponseDeviceModel.isSelectedAssociation[self] = newValue
        }
    }
    
    var isOwner: Bool {
        get {
            return SCNetResponseDeviceModel.isOwnerAssociation[self] ?? false
        }
        set {
            SCNetResponseDeviceModel.isOwnerAssociation[self] = newValue
        }
    }
}

extension SCNetResponseFamilyRoomModel {
    private static let isSelectedAssociation = SCObjectAssociation<Bool>.init(policy: .OBJC_ASSOCIATION_ASSIGN)
    private static let isEditingAssociation = SCObjectAssociation<Bool>.init(policy: .OBJC_ASSOCIATION_ASSIGN)
    private static let isOwnerAssociation = SCObjectAssociation<Bool>.init(policy: .OBJC_ASSOCIATION_ASSIGN)
    
    /// 是否选中状态
    var isSelected: Bool {
        get {
            return SCNetResponseFamilyRoomModel.isSelectedAssociation[self] ?? false
        }
        set {
            SCNetResponseFamilyRoomModel.isSelectedAssociation[self] = newValue
        }
    }
    
    /// 是否为常用
    var isUsed: Bool {
        return self.roomType == SCFamilyRoomType.used.rawValue
    }
    
    var isEditing: Bool {
        get {
            return SCNetResponseFamilyRoomModel.isEditingAssociation[self] ?? false
        }
        set {
            SCNetResponseFamilyRoomModel.isEditingAssociation[self] = newValue
        }
    }
    
    var isOwner: Bool {
        get {
            return SCNetResponseFamilyRoomModel.isOwnerAssociation[self] ?? false
        }
        set {
            SCNetResponseFamilyRoomModel.isOwnerAssociation[self] = newValue
        }
    }
}

extension SCNetResponseFamilyModel {
    private static let isSelectedAssociation = SCObjectAssociation<Bool>.init(policy: .OBJC_ASSOCIATION_ASSIGN)
    private static let isOnOfAutoChangeAssociation = SCObjectAssociation<Bool>.init(policy: .OBJC_ASSOCIATION_ASSIGN)
    private static let cornerAssociation = SCObjectAssociation<UIRectCorner>.init(policy: .OBJC_ASSOCIATION_COPY)
    private static let isOwnerAssociation = SCObjectAssociation<Bool>.init(policy: .OBJC_ASSOCIATION_ASSIGN)
    
    /// 是否选中状态
    var isSelected: Bool {
        get {
            return SCNetResponseFamilyModel.isSelectedAssociation[self] ?? false
        }
        set {
            SCNetResponseFamilyModel.isSelectedAssociation[self] = newValue
        }
    }
    
    var isOnOfAutoChange: Bool {
        get {
            return SCNetResponseFamilyModel.isOnOfAutoChangeAssociation[self] ?? false
        }
        set {
            SCNetResponseFamilyModel.isOnOfAutoChangeAssociation[self] = newValue
        }
    }
    
    var corner: UIRectCorner? {
        get {
            return SCNetResponseFamilyModel.cornerAssociation[self] 
        }
        set {
            SCNetResponseFamilyModel.cornerAssociation[self] = newValue
        }
    }
    
    var isOwner: Bool {
        get {
            return SCNetResponseFamilyModel.isOwnerAssociation[self] ?? false
        }
        set {
            SCNetResponseFamilyModel.isOwnerAssociation[self] = newValue
        }
    }
}
