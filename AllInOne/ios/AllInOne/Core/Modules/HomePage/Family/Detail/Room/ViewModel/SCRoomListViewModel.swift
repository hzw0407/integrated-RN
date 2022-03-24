//
//  SCRoomListViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/22.
//

import UIKit

class SCRoomListViewModel: SCBasicViewModel {
    func modifyRoom(familyId: String, roomId: String, name: String, success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.modifyFamilyRoomRequest(familyId: familyId, roomId: roomId, name: name, success: {
            SCProgressHUD.showHUD(tempLocalize("修改成功"))
            success()
        }, failure: { error in
            if error.codeType == .roomNameRepeat {
                SCProgressHUD.showHUD(tempLocalize("房间名称已存在"))
                return
            }
            SCProgressHUD.showHUD(tempLocalize("修改失败"))
        })
    }
    
    func deleteRooms(roomIds: [String], success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.deleteFamilyRoomsRequest(roomIds: roomIds) {
            SCProgressHUD.showHUD(tempLocalize("删除成功"))
            success()
        } failure: { error in
            SCProgressHUD.showHUD(tempLocalize("删除失败"))
        }

    }
    
    func updateRoomsSort(familyId: String, roomIds: [String], success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.updateFamilyRoomsSortRequest(familyId: familyId, roomIds: roomIds) {
            SCProgressHUD.showHUD(tempLocalize("保存成功"))
            success()
        } failure: { error in
            SCProgressHUD.showHUD(tempLocalize("保存失败"))
        }

    }
    
    func addRoom(familyId: String, roomName: String, success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.addFamilyRoomRequest(familyId: familyId, name: roomName) {
            SCProgressHUD.showHUD(tempLocalize("添加成功"))
            success()
        } failure: { error in
            SCProgressHUD.showHUD(tempLocalize("添加失败"))
        }

    }
    
    func loadFamilyDetail(familyId: String, success: @escaping (([SCNetResponseFamilyRoomModel]) -> Void)) {
        SCSmartNetworking.sharedInstance.getFamilyDetailRequest(id: familyId) { model in
            guard let model = model else { return }
            success(model.rooms)
        } failure: { error in
            
        }
    }
}
