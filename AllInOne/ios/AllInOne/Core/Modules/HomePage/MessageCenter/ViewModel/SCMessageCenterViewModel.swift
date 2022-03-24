//
//  SCMessageCenterViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/29.
//

import UIKit

class SCMessageCenterViewModel: SCBasicViewModel {
    private (set) var shareItems: [SCNetResponseShareInfoModel] = []
    private var currentSharePage: Int = 0
    
    private var currentDevicePage: Int = 0
    private (set) var deviceItems: [SCNetResponseDeviceNotificaitonRecordModel] = []
    
    
    private (set) var deviceShareItems: [SCNetResponseShareNotificaitonRecordModel] = []
    private (set) var familyShareItems: [SCNetResponseShareNotificaitonRecordModel] = []
    private var currentPageByDeviceShare: Int = 0
    private var currentPageByFamilyShare: Int = 0
    
    func refreshShareData(type: SCMessageCenterShareMessageType, success: ((_ hasMoreData: Bool) -> Void)?, failure: (() -> Void)?) {
        if type == .device {
            self.currentPageByDeviceShare = 0
        }
        else if type == .family {
            self.currentPageByFamilyShare = 0
        }
        SCSmartNetworking.sharedInstance.getShareNotificationRecordRequest(targetId: nil, type: type.rawValue, page: 1, pageSize: 30) { [weak self] history in
            guard let `self` = self, let history = history else { return }
            for item in history.items {
                item.shareType = SCShareInfoType(rawValue: item.type) ?? .device
                item.shareStatus = SCShareInfoStatus(rawValue: item.status) ?? .normal
                item.isOwner = item.from == SCSmartNetworking.sharedInstance.user?.id
            }
            var hasMoreData = history.total > self.deviceShareItems.count
            if type == .device {
                self.deviceShareItems = history.items
                hasMoreData = history.total > self.deviceShareItems.count
            }
            else {
                self.familyShareItems = history.items
                hasMoreData = history.total > self.familyShareItems.count
            }
            success?(hasMoreData)
        } failure: { error in
            failure?()
        }

    }
    
    func loadMoreShareData(type: SCMessageCenterShareMessageType, success: ((_ hasMoreData: Bool) -> Void)?, failure: (() -> Void)?) {
        var page = 0
        if type == .device {
            self.currentPageByDeviceShare += 1
            page = self.currentPageByDeviceShare
        }
        else if type == .family {
            self.currentPageByFamilyShare += 1
            page = self.currentPageByFamilyShare
        }
        SCSmartNetworking.sharedInstance.getShareNotificationRecordRequest(targetId: nil, type: type.rawValue, page: page, pageSize: 30) { [weak self] history in
            guard let `self` = self, let history = history else { return }
            for item in history.items {
                item.shareType = SCShareInfoType(rawValue: item.type) ?? .device
                item.shareStatus = SCShareInfoStatus(rawValue: item.status) ?? .normal
                item.isOwner = item.from == SCSmartNetworking.sharedInstance.user?.id
            }
            var hasMoreData = history.total > self.deviceShareItems.count
            if type == .device {
                self.deviceShareItems += history.items
                hasMoreData = history.total > self.deviceShareItems.count
            }
            else {
                self.familyShareItems += history.items
                hasMoreData = history.total > self.familyShareItems.count
            }
            success?(hasMoreData)
        } failure: { error in
            failure?()
        }
    }
    
//    func refreshShareData(success: ((_ hasMoreData: Bool) -> Void)?, failure: (() -> Void)?) {
//        self.currentSharePage = 0
//        SCSmartNetworking.sharedInstance.getShareHistoryRequest(targetId: nil) { [weak self] history in
//            guard let `self` = self, let history = history else { return }
//            for item in history.items {
//                item.shareType = SCShareInfoType(rawValue: item.type) ?? .device
//                item.shareStatus = SCShareInfoStatus(rawValue: item.status) ?? .normal
//                item.isOwner = item.inviterId == SCSmartNetworking.sharedInstance.user?.id
//            }
//            self.shareItems = history.items
//            let hasMoreData = history.total > self.shareItems.count
//            success?(hasMoreData)
//        } failure: { error in
//            failure?()
//        }
//    }
//
//    func loadMoreShareData(success: ((_ hasMoreData: Bool) -> Void)?, failure: (() -> Void)?) {
//        self.currentSharePage += 1
//        SCSmartNetworking.sharedInstance.getShareHistoryRequest(targetId: nil, page: self.currentSharePage) { [weak self] history in
//            guard let `self` = self, let history = history else { return }
//            for item in history.items {
//                item.shareType = SCShareInfoType(rawValue: item.type) ?? .device
//                item.shareStatus = SCShareInfoStatus(rawValue: item.status) ?? .normal
//                item.isOwner = item.inviterId == SCSmartNetworking.sharedInstance.user?.id
//            }
//            self.shareItems += history.items
//            let hasMoreData = history.total > self.shareItems.count
//            success?(hasMoreData)
//        } failure: { error in
//            failure?()
//        }
//    }
    
    /// type: 共享类型，0-设备共享，1-家庭共享
    /// replyType: 1-同意，2-拒绝
    /// familyId 家庭id，共享设备时必填
    /// inviterId 邀请者用户ID
    /// targetId 被分享的目标ID
    func replyShare(type: Int, replyType: Int, familyId: String?, inviterId: String, targetId: String, success: (() -> Void)?, failure: (() -> Void)? = nil) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.replyForShareRequest(type: type, replyType: replyType, familyId: familyId, inviterId: inviterId, targetId: targetId) {
            SCProgressHUD.hideHUD()
            success?()
        } failure: { error in
            SCProgressHUD.hideHUD()
            failure?()
        }

    }
    
    func replyShare(recordId: String, shareId: String, status: Int, familyId: String?, familyName: String?, success: (() -> Void)?, failure: (() -> Void)? = nil) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.replyByShareNotificationRecordRequest(recordId: recordId, shareId: shareId, status: status, familyId: familyId, familyName: familyName) {
            SCProgressHUD.hideHUD()
            success?()
        } failure: { error in
            SCProgressHUD.hideHUD()
            failure?()
        }
    }
    
    func refreshDeviceData(success: ((_ hasMoreData: Bool) -> Void)?, failure: (() -> Void)?) {
        self.currentDevicePage = 0
        SCSmartNetworking.sharedInstance.getDeviceNotificationRecordRequest(page: self.currentDevicePage) { [weak self] history in
            guard let `self` = self, let history = history else { return }
            self.deviceItems = history.items
            let hasMoreData = history.total > self.deviceItems.count
            success?(hasMoreData)
        } failure: { error in
            failure?()
        }
    }
    
    func loadMoreDeviceData(success: ((_ hasMoreData: Bool) -> Void)?, failure: (() -> Void)?) {
        self.currentDevicePage += 1
        SCSmartNetworking.sharedInstance.getDeviceNotificationRecordRequest(page: self.currentDevicePage) { [weak self] history in
            guard let `self` = self, let history = history else { return }
            self.deviceItems += history.items
            let hasMoreData = history.total > self.deviceItems.count
            success?(hasMoreData)
        } failure: { error in
            failure?()
        }
    }
}
