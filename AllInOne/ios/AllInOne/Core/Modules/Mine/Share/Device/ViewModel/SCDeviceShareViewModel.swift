//
//  SCDeviceShareViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/29.
//

import UIKit

class SCDeviceShareViewModel: SCBasicViewModel {
    var shareList: [SCNetResponseDeviceModel] = []
    var acceptList: [SCNetResponseShareInfoModel] = []
    
    private var shareOtherList: [SCNetResponseShareInfoModel] = []
    
    private var isLoadedDeviceData: Bool = false
    private var isLoadedShareData: Bool = false
    
    func loadData(success: (() -> Void)?) {
        self.loadDeviceList { [weak self] in
            guard let `self` = self else { return }
            self.isLoadedDeviceData = true
            if self.isLoadedShareData && self.isLoadedDeviceData {
                self.reloadData()
                success?()
            }
        }
        
        self.loadShareList { [weak self] in
            guard let `self` = self else { return }
            self.isLoadedShareData = true
            if self.isLoadedShareData && self.isLoadedDeviceData {
                self.reloadData()
                success?()
            }
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
    
    private func reloadData() {
        for device in self.shareList {
            let items = self.shareOtherList.filter({ $0.targetId == device.deviceId })
            device.shareItems = items
            device.isShared = items.count > 0
        }
    }
    
    private func loadDeviceList(success: (() -> Void)?) {
        SCSmartNetworking.sharedInstance.getDeviceListRequest { [weak self] list in
            guard let `self` = self else { return }
            var items: [SCNetResponseDeviceModel] = []
            for item in list {
                item.isOwner = item.owner == SCSmartNetworking.sharedInstance.user?.id
                if item.isOwner {
                    items.append(item)
                }
            }
            self.shareList = items
            success?()
        } failure: { error in
            
        }
    }
    
    private func loadShareList(success: (() -> Void)?) {
        SCSmartNetworking.sharedInstance.getShareHistoryRequest(targetId: nil, type: 0, page: 1, pageSize: 1000) { [weak self] history in
            guard let `self` = self, let history = history else { return }
            var shareOtherItems: [SCNetResponseShareInfoModel] = []
            var acceptItems: [SCNetResponseShareInfoModel] = []
            for item in history.items {
                item.shareType = SCShareInfoType(rawValue: item.type) ?? .device
                item.shareStatus = SCShareInfoStatus(rawValue: item.status) ?? .normal
                item.isOwner = item.inviterId == SCSmartNetworking.sharedInstance.user?.id
                
                if item.shareType == .device {
                    if !item.isOwner {
                        acceptItems.append(item)
                    }
                    else {
                        shareOtherItems.append(item)
                    }
                }
            }
            self.shareOtherList = shareOtherItems
            self.acceptList = acceptItems
            success?()
        } failure: { error in
            
        }

    }
}
