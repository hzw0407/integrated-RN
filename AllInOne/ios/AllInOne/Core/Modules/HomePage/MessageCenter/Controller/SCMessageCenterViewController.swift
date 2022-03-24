//
//  SCMessageCenterViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/24.
//

import UIKit

class SCMessageCenterViewController: SCBasicViewController {

    var familyList: [SCNetResponseFamilyModel] = []
    
    private let viewModel = SCMessageCenterViewModel()
    
    private var menuItems: [SCMessageCenterMenuItemModel] = []
    private var alertFamilyItems: [SCHomePageAlertFamilyListItem] = []
    private var currentFamilyId: String = ""
    
    private lazy var menuView: SCMessageCenterMenuView = SCMessageCenterMenuView { [weak self] type in
        guard let `self` = self else { return }
        var isShareHidden = true
        var isDeviceHidden = true
        var isSystemHidden = true
        switch type {
        case .share:
            isShareHidden = false
            break
        case .device:
            isDeviceHidden = false
            break
        case .system:
            isSystemHidden = false
            break
        }
        self.shareView.isHidden = isShareHidden
        self.deviceView.isHidden = isDeviceHidden
        self.systemView.isHidden = isSystemHidden
    }
    
    private lazy var shareView: SCMessageCenterShareView = SCMessageCenterShareView { [weak self] item in //点击待处理按钮
        guard let `self` = self else { return }
        if item.shareType == .device {
            let contentView = SCShareDeviceAlertContentView(imageUrl: item.photoUrl, source: item.username)
            SCAlertView.alert(title: tempLocalize("共享设备"), customView: contentView, cancelTitle: tempLocalize("拒绝"), confirmTitle: tempLocalize("同意"), cancelCallback: { [weak self] in
                guard let `self` = self else { return }
                self.replyShare(item: item, replyType: .refused)
            }, confirmCallback: { [weak self] in
                guard let `self` = self else { return }
                self.replyShare(item: item, replyType: .agreed)
            })
        }
        else {
            let contentView = SCShareFamilyAlertContentView(imageUrl: item.photoUrl, name: item.name, source: item.username)
            SCAlertView.alert(title: tempLocalize("共享家庭"), customView: contentView, cancelTitle: tempLocalize("拒绝"), confirmTitle: tempLocalize("同意"), cancelCallback: { [weak self] in
                guard let `self` = self else { return }
                self.replyShare(item: item, replyType: .refused)
            }, confirmCallback: { [weak self] in
                guard let `self` = self else { return }
                self.replyShare(item: item, replyType: .agreed)
            })
        }
    } headerRefreshHandle: { [weak self] type in
        self?.refreshShareData(type: type)
    } footerRefreshHandle: { [weak self] type in
        self?.loadMoreShareData(type: type)
    }
    
    private lazy var deviceView: SCMessageCenterDeviceView = SCMessageCenterDeviceView { [weak self] in
        guard let `self` = self else { return }
        SCHomePageAlertFamilyListView.show(list: self.alertFamilyItems, topOffsetY: kSCNavAndStatusBarHeight + 145) { [weak self] item in
            guard let `self` = self else { return }
            self.deviceView.set(title: item.family?.name ?? "")
            self.alertFamilyItems.forEach { model in
                model.isSelected = false
            }
            item.isSelected = true
            self.currentFamilyId = item.family?.id ?? ""
//            self.loadDeviceMessageData(familyId: self.currentFamilyId)
            self.refreshDeviceData()
        }
    } didSelectHandle: { [weak self] model in
        guard let `self` = self else { return }
        let vc = SCDeviceMessageDetailViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private lazy var systemView: SCMessageCenterSystemView = SCMessageCenterSystemView()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension SCMessageCenterViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("消息中心")
    }
    
    override func setupView() {
        self.view.addSubview(self.menuView)
        self.view.addSubview(self.shareView)
        self.view.addSubview(self.deviceView)
        self.view.addSubview(self.systemView)
        
        self.deviceView.isHidden = true
        self.systemView.isHidden = true
    }
    
    override func setupLayout() {
        self.menuView.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.topMargin)
            make.left.right.equalToSuperview()
            make.height.equalTo(80)
        }
        self.shareView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.menuView.snp.bottom).offset(12)
        }
        self.deviceView.snp.makeConstraints { make in
            make.edges.equalTo(self.shareView)
        }
        self.systemView.snp.makeConstraints { make in
            make.edges.equalTo(self.shareView)
        }
    }
    
    override func setupData() {
        self.setupMenuData()
        self.setupShareMessageMenuData()
        self.setupDeviceMessageData()
        
        // 加载共享数据
        self.refreshShareData(type: .device)
        self.refreshShareData(type: .family)
    }
    
    private func setupMenuData() {
        let types: [SCMessageCenterMessageType] = [.share, .device, .system]
        var items: [SCMessageCenterMenuItemModel] = []
        for (i, type) in types.enumerated() {
            let item = SCMessageCenterMenuItemModel()
            item.isSelected = i == 0
            item.type = type
            items.append(item)
        }
        self.menuView.set(list: items)
    }
    
    private func setupShareMessageMenuData() {
        let types: [SCMessageCenterShareMessageType] = [.device, .family]
        var items: [SCMessageCenterShareMenuItemModel] = []
        for (i, type) in types.enumerated() {
            let item = SCMessageCenterShareMenuItemModel()
            item.isSelected = i == 0
            item.type = type
            items.append(item)
        }
        self.shareView.set(menuList: items)
    }
    
    private func setupDeviceMessageData() {
        var items: [SCHomePageAlertFamilyListItem] = []
        self.currentFamilyId = SCHomePageViewModel.currentFamilyId() ?? (self.familyList.first?.id ?? "")
        var currentFamilyName: String = ""
        for family in self.familyList {
            let item = SCHomePageAlertFamilyListItem()
            item.family = family
            item.hasLineView = true
            item.isSelected = self.currentFamilyId == family.id
            if item.isSelected {
                currentFamilyName = family.name
            }
            items.append(item)
        }
        self.alertFamilyItems = items
        
//        self.loadDeviceMessageData(familyId: self.currentFamilyId)
        self.refreshDeviceData()
        
        self.deviceView.set(title: currentFamilyName)
    }
    
    private func refreshShareData(type: SCMessageCenterShareMessageType) {
//        self.viewModel.refreshShareData { [weak self] hasMoreData in
//            guard let `self` = self else { return }
//            self.shareView.set(footerHidden: !hasMoreData)
//            self.shareView.endRefresh()
//            self.shareView.set(items: self.viewModel.shareItems)
//        } failure: { [weak self] in
//            self?.shareView.endRefresh()
//        }
        
        self.viewModel.refreshShareData(type: type) { [weak self] hasMoreData in
            guard let `self` = self else { return }
            self.shareView.set(footerHidden: !hasMoreData)
            self.shareView.endRefresh()
            var items = self.viewModel.deviceShareItems
            if type == .family {
                items = self.viewModel.familyShareItems
            }
            self.shareView.set(type: type, items: items)
        } failure: { [weak self] in
            self?.shareView.endRefresh()
        }

    }
    
    private func loadMoreShareData(type: SCMessageCenterShareMessageType) {
//        self.viewModel.loadMoreShareData { [weak self] hasMoreData in
//            guard let `self` = self else { return }
//            self.shareView.set(footerHidden: !hasMoreData)
//            self.shareView.endRefresh()
//            self.shareView.set(items: self.viewModel.shareItems)
//        } failure: { [weak self] in
//            self?.shareView.endRefresh()
//        }

        self.viewModel.loadMoreShareData(type: type) { [weak self] hasMoreData in
            guard let `self` = self else { return }
            self.shareView.set(footerHidden: !hasMoreData)
            self.shareView.endRefresh()
            var items = self.viewModel.deviceShareItems
            if type == .family {
                items = self.viewModel.familyShareItems
            }
            self.shareView.set(type: type, items: items)
        } failure: { [weak self] in
            self?.shareView.endRefresh()
        }
    }
    
    private func refreshDeviceData() {
        self.viewModel.refreshDeviceData { [weak self] hasMoreData in
            guard let `self` = self else { return }
            self.deviceView.set(footerHidden: !hasMoreData)
            self.deviceView.endRefresh()
            self.deviceView.set(list: self.viewModel.deviceItems)
        } failure: { [weak self] in
            self?.shareView.endRefresh()
        }
    }
    
    private func loadMoreDeviceData() {
        self.viewModel.loadMoreDeviceData { [weak self] hasMoreData in
            guard let `self` = self else { return }
            self.deviceView.set(footerHidden: !hasMoreData)
            self.deviceView.endRefresh()
            self.deviceView.set(list: self.viewModel.deviceItems)
        } failure: { [weak self] in
            self?.shareView.endRefresh()
        }

    }
}

extension SCMessageCenterViewController {
    private func replyShare(item: SCNetResponseShareNotificaitonRecordModel, replyType: SCShareInfoStatus) {
        var familyId: String?
        if item.shareType == .device {
            familyId = SCHomePageViewModel.currentFamilyId()
        }
        var familyName: String?
        if item.shareType == .family {
            familyName = item.name
            if item.name.count == 0 {
                familyName = item.targetId
            }
        }
        
        self.viewModel.replyShare(recordId: item.id, shareId: item.shareId, status: replyType.rawValue, familyId: familyId, familyName: familyName) { [weak self] in
            guard let `self` = self else { return }
            item.status = replyType.rawValue
            item.shareStatus = replyType
            self.shareView.reloadData()
        } failure: {
            SCProgressHUD.showHUD(tempLocalize("请求失败"))
        }
//
//
//        self.viewModel.replyShare(type: item.type, replyType: replyType.rawValue, familyId: familyId, inviterId: item.from, targetId: item.targetId) { [weak self] in
//            guard let `self` = self else { return }
//            item.status = replyType.rawValue
//            item.shareStatus = replyType
//            self.shareView.reloadData()
//        } failure: { [weak self] in
//            guard let `self` = self else { return }
//            SCProgressHUD.showHUD(tempLocalize("请求失败"))
//        }

    }
}
