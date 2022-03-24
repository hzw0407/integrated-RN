//
//  SCFeedbackRecordModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/1/7.
//

import UIKit

extension SCNetResponseFeedbackRecordModel {
    private static let isEditingAssociation = SCObjectAssociation<Bool>.init(policy: .OBJC_ASSOCIATION_ASSIGN)
    private static let isSelectedAssociation = SCObjectAssociation<Bool>.init(policy: .OBJC_ASSOCIATION_ASSIGN)
    
    /// 是否在编辑中
    var isEditing: Bool {
        get {
            return SCNetResponseFeedbackRecordModel.isEditingAssociation[self] ?? false
        }
        set {
            SCNetResponseFeedbackRecordModel.isEditingAssociation[self] = newValue
        }
    }
    
    /// 是否选中状态
    var isSelected: Bool {
        get {
            return SCNetResponseFeedbackRecordModel.isSelectedAssociation[self] ?? false
        }
        set {
            SCNetResponseFeedbackRecordModel.isSelectedAssociation[self] = newValue
        }
    }
}
