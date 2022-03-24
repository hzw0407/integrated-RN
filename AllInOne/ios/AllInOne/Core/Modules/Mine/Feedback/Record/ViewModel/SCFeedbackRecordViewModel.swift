//
//  SCFeedbackRecordViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/1/7.
//

import UIKit

class SCFeedbackRecordViewModel: SCBasicViewModel {
    var items: [SCNetResponseFeedbackRecordModel] = []
    private (set) var hasMoreData: Bool = false
    private var currentPage: Int = 1
    
    func refreshData(success: ((_ hasMoreData: Bool) -> Void)?, failure: (() -> Void)?) {
        self.currentPage = 1
        SCSmartNetworking.sharedInstance.getFeedbackRecordRequest(page: self.currentPage) { [weak self] history in
            guard let `self` = self, let history = history else { return }
            self.items = history.items
            let hasMoreData = history.total > self.items.count
            self.hasMoreData = hasMoreData
            success?(hasMoreData)
        } failure: { error in
             failure?()
        }
    }
    
    func loadMoreData(success: ((_ hasMoreData: Bool) -> Void)?, failure: (() -> Void)?) {
        self.currentPage += 1
        SCSmartNetworking.sharedInstance.getFeedbackRecordRequest(page: self.currentPage) { [weak self] history in
            guard let `self` = self, let history = history else { return }
            self.items += history.items
            let hasMoreData = history.total > self.items.count
            self.hasMoreData = hasMoreData
            success?(hasMoreData)
        } failure: { error in
             failure?()
        }
    }
    
    func deleteFeedbackRecord(ids: [String], success: (() -> Void)?) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.deleteFeedbackRecordRequest(ids: ids) {
            SCProgressHUD.showHUD(tempLocalize("删除成功"))
            success?()
        } failure: { error in
            SCProgressHUD.showHUD(tempLocalize("删除失败"))
        }

    }
}
