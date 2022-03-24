//
//  SCFeedbackQuestionListViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/30.
//

import UIKit

class SCFeedbackQuestionListViewModel: SCBasicViewModel {
    
    func loadData(productId: String, success: (([SCNetResponseFaqItemModel]) -> Void)?) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.getFaqListRequest(productId: productId) { info in
            SCProgressHUD.hideHUD()
            if let info = info {
                success?(info.items)
            }
        } failure: { error in
            SCProgressHUD.hideHUD()
        }

    }
    
//    func loadQuestionList(success: ((_ list: [SCNetResponseFaqTypeModel]) -> Void)?) {
//        SCSmartNetworking.sharedInstance.getFaqTypeListRequest(type: nil) { list in
//            success?(list)
//        } failure: { error in
//
//        }
//
//    }
//
//    func loadQuestionDetailList(typeId: String, success: ((_ list: [SCNetResponseFaqContentModel]) -> Void)?) {
//        SCProgressHUD.showWaitHUD()
//        SCSmartNetworking.sharedInstance.getFaqListRequest(typeId: typeId, type: nil) { list in
//            SCProgressHUD.hideHUD()
//            success?(list)
//        } failure: { error in
//            SCProgressHUD.hideHUD()
//        }
//    }
}
