//
//  SCFamilyDetailViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/22.
//

import UIKit

class SCFamilyDetailViewModel: SCBasicViewModel {
    var roomList: [SCNetResponseFamilyRoomModel] = []
    
    func loadFamilyDetail(familyId: String, success: @escaping (() -> Void)) {
        SCSmartNetworking.sharedInstance.getFamilyDetailRequest(id: familyId) { [weak self] model in
            guard let `self` = self, let model = model else { return }
            self.roomList = model.rooms
            success()
        } failure: { error in
            
        }
    }
    
    func deleteFamily(familyId: String, success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.deleteFamilyRequest(familyId: familyId) {
            SCProgressHUD.showHUD(tempLocalize("删除成功"))
            success()
        } failure: { error in
            SCProgressHUD.showHUD(tempLocalize("删除失败"))
        }
    }
    
    func exitFamily(familyId: String, success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.exitFamilyByUserRequest(familyId: familyId, shareId: "") { result in
            SCProgressHUD.hideHUD()
            if result == true {
                SCProgressHUD.showHUD(tempLocalize("退出成功"))
                success()
            }
        } failure: { error in
            SCProgressHUD.showHUD(tempLocalize("退出失败"))
        }

    }
    
    func saveFamily(family: SCNetResponseFamilyModel, success: (() -> Void)?, failure: (() -> Void)? = nil) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.modifyFamilyRequest(familyId: family.id, name: family.name, headUrl: family.headUrl, address: family.address, country: family.country, city: family.city) {
            SCProgressHUD.showHUD(tempLocalize("修改成功"))
            success?()
        } failure: { error in
            SCProgressHUD.showHUD(tempLocalize("修改失败"))
            failure?()
        }

    }
}
