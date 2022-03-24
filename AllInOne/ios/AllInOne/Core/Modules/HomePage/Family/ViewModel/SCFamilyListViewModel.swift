//
//  SCFamilyListViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/23.
//

import UIKit

class SCFamilyListViewModel: SCBasicViewModel {
    func loadFamilyData(success: (([SCNetResponseFamilyModel]) -> Void)?, failure: (() -> Void)? = nil) {
        SCSmartNetworking.sharedInstance.getFamilyListRequest { list in
            success?(list)
        } failure: { error in
            failure?()
        }

    }
}
