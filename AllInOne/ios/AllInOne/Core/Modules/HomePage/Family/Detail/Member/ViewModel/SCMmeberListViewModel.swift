//
//  SCMmeberListViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/22.
//

import UIKit

class SCMmeberListViewModel: SCBasicViewModel {
    func loadMemberList(familyId: String, success: @escaping (([SCNetResponseFamilyMemberModel]) -> Void)) {
        SCSmartNetworking.sharedInstance.getFamilyMemberListRequest(familyId: familyId) { list in
            success(list)
        } failure: { error in
            
        }

    }
}
