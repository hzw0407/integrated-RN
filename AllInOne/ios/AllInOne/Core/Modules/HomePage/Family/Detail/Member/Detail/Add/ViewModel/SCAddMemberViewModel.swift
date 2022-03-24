//
//  SCAddMemberViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/23.
//

import UIKit

class SCAddMemberViewModel: SCBasicViewModel {
    func addMember(familyId: String, username: String, success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.addFamilyMemberRequest(familyId: familyId, username: username) {  
            SCProgressHUD.showHUD(tempLocalize("共享成功"))
            success()
        } failure: { error in
            if error.codeType == .userNotExists {
                SCProgressHUD.showHUD(tempLocalize("用户不存在"))
            }
            else {
                SCProgressHUD.showHUD(tempLocalize("共享失败"))
            }
        }

    }
}
