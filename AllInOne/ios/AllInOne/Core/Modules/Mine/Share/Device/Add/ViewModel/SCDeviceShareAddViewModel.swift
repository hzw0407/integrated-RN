//
//  SCDeviceShareAddViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/29.
//

import UIKit

class SCDeviceShareAddViewModel: SCBasicViewModel {
    func shareDevices(deviceIds: [String], toUsername username: String, success: (() -> Void)?) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.shareDeviceToUserRequest(username: username, deviceIds: deviceIds) {
            SCProgressHUD.showHUD(tempLocalize("共享成功"))
            success?()
        } failure: { error in
            SCProgressHUD.showHUD(tempLocalize("共享失败"))
        }

    }
}
