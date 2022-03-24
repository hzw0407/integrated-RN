//
//  SCMoveRoomDeviceViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/20.
//

import UIKit

class SCMoveRoomDeviceViewModel: SCBasicViewModel {
    func saveMoveRoomDevice(deviceIds: [String], fromRoomId: String, toRoomId: String, success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.moveDeviceToRoom(deviceIds: deviceIds, fromRoomId: fromRoomId, toRoomId: toRoomId) {
            SCProgressHUD.hideHUD()
            success()
        } failure: { error in
            SCProgressHUD.hideHUD()
        }
    }
}
