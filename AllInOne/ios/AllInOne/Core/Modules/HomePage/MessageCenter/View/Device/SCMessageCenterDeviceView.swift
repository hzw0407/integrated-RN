//
//  SCMessageCenterDeviceView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/24.
//

import UIKit

class SCMessageCenterDeviceView: SCBasicView {

    private var list: [SCNetResponseDeviceNotificaitonRecordModel] = []

    private var didClickMenuBlock: (() -> Void)?
    private var didSelectBlock: ((SCNetResponseDeviceNotificaitonRecordModel) -> Void)?
    private var headerRefreshBlock: (() -> Void)?
    private var footerRefreshBlock: (() -> Void)?
    
    private lazy var menuView: SCMessageCeterDeviceMenuView = SCMessageCeterDeviceMenuView { [weak self] in
        self?.didClickMenuBlock?()
    }
    
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCMessageCenterShareDeviceCell.self, cellIdendify: SCMessageCenterShareDeviceCell.identify, rowHeight: nil, hasEmptyView: true) { [weak self] indexPath in
            guard let `self` = self else { return }
        }
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.headerRefreshBlock?()
        })
        tableView.mj_footer = MJRefreshAutoFooter(refreshingBlock: { [weak self] in
            self?.footerRefreshBlock?()
        })
        return tableView
    }()
    
    convenience init(didClickMenuHandle: (() -> Void)?, didSelectHandle: ((SCNetResponseDeviceNotificaitonRecordModel) -> Void)?, headerRefreshHandle: (() -> Void)? = nil, footerRefreshHandle: (() -> Void)? = nil) {
        self.init(frame: .zero)
        self.didClickMenuBlock = didClickMenuHandle
        self.didSelectBlock = didSelectHandle
        self.headerRefreshBlock = headerRefreshHandle
        self.footerRefreshBlock = footerRefreshHandle
    }
    
    func set(title: String) {
        self.menuView.title = title
    }
    
    func set(list: [SCNetResponseDeviceNotificaitonRecordModel]) {
        self.list = list
        self.tableView.set(list: [list])
    }
    
    func endRefresh() {
        self.tableView.mj_header?.endRefreshing()
        self.tableView.mj_footer?.endRefreshing()
    }
    
    func set(footerHidden isHidden: Bool) {
        self.tableView.mj_footer?.isHidden = isHidden
    }
}

extension SCMessageCenterDeviceView {
    override func setupView() {
        self.addSubview(self.menuView)
    }
    
    override func setupLayout() {
        self.menuView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(52)
        }
    }
}
