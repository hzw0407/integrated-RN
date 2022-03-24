//
//  SCMessageCenterShareView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/24.
//

import UIKit

class SCMessageCenterShareView: SCBasicView {
    
    private var type: SCMessageCenterShareMessageType = .device
    
    private var menuList: [SCMessageCenterShareMenuItemModel] = []
    private var deviceList: [SCNetResponseShareNotificaitonRecordModel] = []
    private var familyList: [SCNetResponseShareNotificaitonRecordModel] = []
        
    private var didClickStatusBlock: ((SCNetResponseShareNotificaitonRecordModel) -> Void)?
    private var headerRefreshBlock: ((SCMessageCenterShareMessageType) -> Void)?
    private var footerRefreshBlock: ((SCMessageCenterShareMessageType) -> Void)?
    
    private lazy var menuView: SCMessageCenterShareMenuView = SCMessageCenterShareMenuView(frame: CGRect(x: 0, y: 0, width: kSCScreenWidth, height: 52)) { [weak self] type in
        guard let `self` = self else { return }
        self.type = type
        self.reloadData()
    }
    
    private lazy var listView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCMessageCenterShareCell.self, cellIdendify: SCMessageCenterShareCell.identify, rowHeight: nil, cellDelegate: self, hasEmptyView: true)
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            guard let `self` = self else { return }
            self.headerRefreshBlock?(self.type)
        })
        tableView.mj_footer = MJRefreshAutoFooter(refreshingBlock: { [weak self] in
            guard let `self` = self else { return }
            self.footerRefreshBlock?(self.type)
        })
        
        return tableView
    }()
    
    convenience init(didClickStatusHandle: ((SCNetResponseShareNotificaitonRecordModel) -> Void)?, headerRefreshHandle: ((SCMessageCenterShareMessageType) -> Void)? = nil, footerRefreshHandle: ((SCMessageCenterShareMessageType) -> Void)? = nil) {
        self.init(frame: .zero)
        self.didClickStatusBlock = didClickStatusHandle
        self.headerRefreshBlock = headerRefreshHandle
        self.footerRefreshBlock = footerRefreshHandle
    }
    
    func endRefresh() {
        self.listView.mj_header?.endRefreshing()
        self.listView.mj_footer?.endRefreshing()
    }
    
    func set(footerHidden isHidden: Bool) {
        self.listView.mj_footer?.isHidden = isHidden
    }
    
    func set(menuList: [SCMessageCenterShareMenuItemModel]) {
        self.menuList = menuList
        self.menuView.set(list: menuList)
    }
    
    func set(type: SCMessageCenterShareMessageType, items: [SCNetResponseShareNotificaitonRecordModel]) {
        if type == .device {
            self.deviceList = items
        }
        else if type == .family {
            self.familyList = items
        }
        self.reloadData()
    }
    
//    func set(deviceList: [SCNetResponseShareInfoModel], familyList: [SCNetResponseShareInfoModel]) {
//        self.deviceList = deviceList
//        self.familyList = familyList
//    }
//    
//    func set(items: [SCNetResponseShareInfoModel]) {
//        self.deviceList = items.filter({ $0.shareType == .device })
//        self.familyList = items.filter({ $0.shareType == .family })
//        
//        self.reloadData()
//    }
    
    func reloadData() {
        switch self.type {
        case .device:
            self.listView.set(list: [self.deviceList])
        case .family:
            self.listView.set(list: [self.familyList])
        }
    }
}

extension SCMessageCenterShareView {
    override func setupView() {
        self.addSubview(self.listView)
        self.listView.tableHeaderView = self.menuView
    }
    
    override func setupLayout() {
        self.listView.snp.makeConstraints { make in
            make.left.right.bottom.top.equalToSuperview()
        }
    }
}

extension SCMessageCenterShareView: SCMessageCenterShareCellDelegate {
    func cell(_ cell: SCMessageCenterShareCell, didClickStatusWithModel item: SCNetResponseShareNotificaitonRecordModel) {
        self.didClickStatusBlock?(item)
    }
}
