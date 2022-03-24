//
//  SCMemberDetailViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/23.
//

import UIKit

class SCMemberDetailViewModel: SCBasicViewModel {
    func deleteMember(familyId: String, inviteId: String, beInviteId: String?, success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.deleteFamilyMemberRequest(familyId: familyId, inviteId: inviteId, beInviteId: beInviteId) { result in
            SCProgressHUD.hideHUD()
            if result == true {
                success()
                SCProgressHUD.showHUD("撤销成功")
            }
        } failure: { error in
            SCProgressHUD.showHUD("撤销失败")
        }

    }
}
