//
//  SCShareHistoryViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/28.
//

import UIKit
import MJRefresh

class SCShareHistoryViewController: SCBasicViewController {

    private let viewModel = SCShareHistoryViewModel()
    
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCShareHistoryItemCell.self, cellIdendify: SCShareHistoryItemCell.identify, rowHeight: nil, cellDelegate: self, hasEmptyView: true, didSelectHandle: nil)
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.refreshData()
        })
        tableView.mj_footer = MJRefreshAutoFooter(refreshingBlock: { [weak self] in
            self?.loadMoreData()
        })
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension SCShareHistoryViewController {
    override func setupView() {
        self.title = tempLocalize("共享历史")
        self.view.addSubview(self.tableView)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.topMargin)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func setupData() {
        self.refreshData()
    }
    
    private func refreshData() {
        self.viewModel.refreshData { [weak self] hasMoreData in
            guard let `self` = self else { return }
            self.tableView.mj_footer?.isHidden = !hasMoreData
            self.tableView.mj_header?.endRefreshing()
            self.tableView.set(list: [self.viewModel.items])
        } failure: { [weak self] in
            self?.tableView.mj_header?.endRefreshing()
        }
    }
    
    private func loadMoreData() {
        self.viewModel.loadMoreData { [weak self] hasMoreData in
            guard let `self` = self else { return }
            self.tableView.mj_footer?.isHidden = !hasMoreData
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.set(list: [self.viewModel.items])
        } failure: { [weak self] in
            self?.tableView.mj_footer?.endRefreshing()
        }
    }
}

extension SCShareHistoryViewController: SCShareHistoryItemCellDelegate {
    func cell(_ cell: SCShareHistoryItemCell, didClickStatusWithModel item: SCNetResponseShareInfoModel) {
        if item.shareType == .device {
            let contentView = SCShareDeviceAlertContentView(imageUrl: item.imageUrl, source: item.username)
            SCAlertView.alert(title: tempLocalize("共享设备"), customView: contentView, cancelTitle: tempLocalize("拒绝"), confirmTitle: tempLocalize("同意"), cancelCallback: { [weak self] in
                guard let `self` = self else { return }
                self.replyShare(item: item, replyType: .refused)
            }, confirmCallback: { [weak self] in
                guard let `self` = self else { return }
                self.replyShare(item: item, replyType: .agreed)
            })
        }
        else {
            let contentView = SCShareFamilyAlertContentView(imageUrl: item.imageUrl, name: item.name, source: item.username)
            SCAlertView.alert(title: tempLocalize("共享家庭"), customView: contentView, cancelTitle: tempLocalize("拒绝"), confirmTitle: tempLocalize("同意"), cancelCallback: { [weak self] in
                guard let `self` = self else { return }
                self.replyShare(item: item, replyType: .refused)
            }, confirmCallback: { [weak self] in
                guard let `self` = self else { return }
                self.replyShare(item: item, replyType: .agreed)
            })
        }
    }
    
    private func replyShare(item: SCNetResponseShareInfoModel, replyType: SCShareInfoStatus) {
        var familyId: String?
        if item.shareType == .device {
            familyId = SCHomePageViewModel.currentFamilyId()
        }
        self.viewModel.reply(type: item.type, replyType: replyType.rawValue, familyId: familyId, inviterId: item.inviterId, targetId: item.targetId) { [weak self] in
            guard let `self` = self else { return }
            item.status = replyType.rawValue
            item.shareStatus = replyType
            self.tableView.reloadData()
        } failure: { [weak self] in
            guard let `self` = self else { return }
            SCProgressHUD.showHUD(tempLocalize("请求失败"))
        }

    }
}
