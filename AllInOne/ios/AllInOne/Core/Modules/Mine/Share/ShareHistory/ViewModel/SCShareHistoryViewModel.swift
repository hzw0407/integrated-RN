//
//  SCShareHistoryViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/28.
//

import UIKit
import sqlcipher

class SCShareHistoryViewModel: SCBasicViewModel {

    private (set) var items: [SCNetResponseShareInfoModel] = []
    private var currentPage: Int = 1
    
    func refreshData(success: ((_ hasMoreData: Bool) -> Void)?, failure: (() -> Void)?) {
        self.currentPage = 1
        SCSmartNetworking.sharedInstance.getShareHistoryRequest(targetId: nil) { [weak self] history in
            guard let `self` = self, let history = history else { return }
            for item in history.items {
                item.shareType = SCShareInfoType(rawValue: item.type) ?? .device
                item.shareStatus = SCShareInfoStatus(rawValue: item.status) ?? .normal
                item.isOwner = item.inviterId == SCSmartNetworking.sharedInstance.user?.id
            }
            self.items = history.items
            let hasMoreData = history.total > self.items.count
            success?(hasMoreData)
        } failure: { error in
            failure?()
        }
    }
    
    func loadMoreData(success: ((_ hasMoreData: Bool) -> Void)?, failure: (() -> Void)?) {
        self.currentPage += 1
        SCSmartNetworking.sharedInstance.getShareHistoryRequest(targetId: nil, page: self.currentPage) { [weak self] history in
            guard let `self` = self, let history = history else { return }
            for item in history.items {
                item.shareType = SCShareInfoType(rawValue: item.type) ?? .device
                item.shareStatus = SCShareInfoStatus(rawValue: item.status) ?? .normal
                item.isOwner = item.inviterId == SCSmartNetworking.sharedInstance.user?.id
            }
            self.items += history.items
            let hasMoreData = history.total > self.items.count
            success?(hasMoreData)
        } failure: { error in
            failure?()
        }
    }
    
    /// type: 共享类型，0-设备共享，1-家庭共享
    /// replyType: 1-同意，2-拒绝
    /// familyId 家庭id，共享设备时必填
    /// inviterId 邀请者用户ID
    /// targetId 被分享的目标ID
    func reply(type: Int, replyType: Int, familyId: String?, inviterId: String, targetId: String, success: (() -> Void)?, failure: (() -> Void)? = nil) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.replyForShareRequest(type: type, replyType: replyType, familyId: familyId, inviterId: inviterId, targetId: targetId) {
            SCProgressHUD.hideHUD()
            success?()
        } failure: { error in
            SCProgressHUD.hideHUD()
            failure?()
        }

    }
}
