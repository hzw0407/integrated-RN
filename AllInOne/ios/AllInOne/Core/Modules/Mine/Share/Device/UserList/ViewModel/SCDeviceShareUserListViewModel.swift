//
//  SCDeviceShareUserListViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/30.
//

import UIKit

class SCDeviceShareUserListViewModel: SCBasicViewModel {
    func deleteShare(shareId: String, success: (() -> Void)?) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.deleteShareRequest(shareId: shareId) {
            SCProgressHUD.hideHUD()
            success?()
        } failure: { error in
            SCProgressHUD.showHUD(tempLocalize("请求失败"))
        }

    }
}
