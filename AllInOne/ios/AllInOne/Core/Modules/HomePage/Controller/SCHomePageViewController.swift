//
//  SCHomePageViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/26.
//

import UIKit
import AliyunOSSiOS
import MJRefresh

class SCHomePageViewController: SCBasicViewController {
    /// 开始编辑时的原始房间设备列表
    private var originalEditingList: [SCNetResponseDeviceModel] = []
    /// 数据处理
    private let viewModel = SCHomePageViewModel()
    
    /// 设备列表是否在编辑状态
    private var isEditStatus: Bool = false {
        didSet {
            self.reloadEditState()
            if !self.isEditStatus {
                self.setupMJHeader()
            }
        }
    }
    
    /// 当前房间索引
    private var currentRoomIndex: Int {
        return self.pageView.currentIndex
    }
    /// 当前选中的设备索引
    private var currentSelectedDeviceIndices: [Int] = []
    
    /// pageView中的scrollView能否拖拽
    private var isPageViewScrollEnabled: Bool = false
    /// 主scrollView能否拖拽
    private var isScrollEnabled: Bool = true
    /// 滑动中的OffsetY
    private var panOffsetY: CGFloat = 0
    /// 添加设备成功后分配房间时的房间列表弹窗
    private var addDeviceRoomsView: SCAddDeviceRoomsView = SCAddDeviceRoomsView()
    /// 添加设备成功后分配房间时的房间列表
    private var addDeviceRoomList: [SCNetResponseFamilyRoomModel] = []
    /// 添加设备成功后分配房间时的房间
    private var addDeviceRoom: SCNetResponseFamilyRoomModel?
    /// 编辑房间设备列表时的顶部工具栏(保存、选中所有)
    private lazy var editingBar: SCHomePageNavigationBar = SCHomePageNavigationBar { [weak self] in /// 保存
        guard let `self` = self else { return }
        if self.viewModel.roomList.count > self.currentRoomIndex {
            let room  = self.viewModel.roomList[self.currentRoomIndex]
            let deviceIds = room.devices.map { return $0.deviceId }
            self.viewModel.saveRoomDevicesSortRequest(roomId: room.id, deviceIds: deviceIds) { [weak self] in
                guard let `self` = self else { return }
                self.reloadCurrentRoom()
                self.isEditStatus = false
            } failure: { [weak self] in
                guard let `self` = self else { return }
                room.devices = self.originalEditingList
                self.reloadCurrentRoom()
                self.isEditStatus = false
            }
        }
        
    } selectAllHandle: { [weak self] in // 选中/取消所有
        guard let `self` = self else { return }
        self.selectAllAction()
    }
    /// 普通状态下顶部工具栏(家庭、消息中心、添加设备)
    private lazy var headerView: SCHomePageHeaderView = {
        let view = SCHomePageHeaderView()
        view.addActions { // 点击家庭
            SCHomePageAlertFamilyListView.show(list: self.viewModel.alertFamilys) { [weak self] item in
                guard let `self` = self else { return }
                if item.isFamilyManager {
                    let vc = SCFamilyListViewController()
                    vc.familyList = self.viewModel.familyList
                    vc.add { [weak self] in
                        self?.loadData(isNewFamily: true)
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    guard let familyId = item.family?.id else { return }
                    self.viewModel.saveFamilyId(familyId: familyId) { [weak self] in
                        guard let `self` = self else { return }
                        
                        self.reloadFamily()
                    }
                }
            }
        } notificationHandle: { [weak self] in // 点击通知
            guard let `self` = self else { return }
            let vc = SCMessageCenterViewController()
            vc.familyList = self.viewModel.familyList
            self.navigationController?.pushViewController(vc, animated: true)
        } addDeviceHandle: { [weak self] in // 点击添加设备
            guard let `self` = self else { return }
            guard self.viewModel.family.isOwner else {
                SCProgressHUD.showHUD(tempLocalize("共享家庭成员暂不支持添加设备，请管理员添加"))
                return
            }
            let vc = SCAddDeviceViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            SCBPLog("点击添加设备")
        }

        return view
    }()
    
    private lazy var pageView: SCHomePageView = {
        let pageView = SCHomePageView { [weak self] in
            guard let `self` = self else { return }
            let vc = SCRoomListViewController()
            vc.family = self.viewModel.family
            self.navigationController?.pushViewController(vc, animated: true)
            #if DEBUG
            self.addDeviceToRoom(deviceId: "1493098897774891008", sn: "TESTSN0101", productId: "1493098577833381888")
            #endif
        } didSelectItemHandle: { [weak self] index in
            guard let `self` = self, self.viewModel.roomList.count > self.currentRoomIndex, self.viewModel.roomList[self.currentRoomIndex].devices.count > index else { return }
            let room = self.viewModel.roomList[self.currentRoomIndex]
            let item = room.devices[index]
            if self.isEditStatus {
                item.isSelected = !item.isSelected
                self.reloadCurrentRoom()
                self.reloadBottomView()
            }
            else { // 进入设备
                self.enterDevice(index: index)
            }
        } longPressHandle: {  [weak self] index, gesture in
            guard let `self` = self else { return }
            guard self.viewModel.family.isOwner else {
                SCProgressHUD.showHUD(tempLocalize("共享家庭的设备不支持编辑"))
                return
            }
            guard self.viewModel.roomList.count > self.currentRoomIndex, self.viewModel.roomList[self.currentRoomIndex].devices.count > index else { return }
            let room = self.viewModel.roomList[self.currentRoomIndex]
            let item = room.devices[index]
            if !self.isEditStatus {
                item.isSelected = true
                self.currentSelectedDeviceIndices = [index]
                self.isEditStatus = true
                self.reloadBottomView()
                
                self.scrollView.mj_header = nil
            }
        } dragEndedHandle: { [weak self] devices in
            guard let `self` = self, self.viewModel.roomList.count > self.currentRoomIndex else { return }
            let room = self.viewModel.roomList[self.currentRoomIndex]
            room.devices = devices
        } didScrollHandle: { [weak self] scrollView in
            self?.pageViewScrollDidScroll(scrollView)
        }
        return pageView
    }()
    
    private lazy var bootomView: SCHomePageBottomView = SCHomePageBottomView { [weak self] type in
        guard let `self` = self else { return }
        guard self.viewModel.roomList.count > self.currentRoomIndex else { return }
        let room = self.viewModel.roomList[self.currentRoomIndex]
        let usedRoom = self.viewModel.roomList.filter({ $0.isUsed }).first ?? self.viewModel.roomList[0]
        let selectDevices = room.devices.filter({ $0.isSelected })
        let selectIds = selectDevices.map { return $0.deviceId }
        switch type {
        case .addToUsed:
//            let usedRoomId = self.viewModel.roomList.filter({ $0.isUsed }).first?.id ?? ""
            self.viewModel.addToUsedRoom(deviceIds: selectIds, roomId: room.id, usedRoomId: usedRoom.id) { [weak self] in
                usedRoom.devices.append(contentsOf: selectDevices)
                self?.isEditStatus = false
            } failure: { [weak self] in
                guard let `self` = self else { return }
                room.devices = self.originalEditingList
                self.reloadCurrentRoom()
                self.isEditStatus = false
            }
            break
        case .moveTop:
            let originalIds = room.devices.map { return $0.deviceId }
            self.viewModel.moveDeviceToTopRequest(roomId: room.id, topDeviceIds: selectIds, originalDeviceIds: originalIds) { [weak self] in
                guard let `self` = self else { return }
                var devices = selectDevices
                for item in room.devices {
                    if !item.isSelected {
                        devices.append(item)
                    }
                }
                room.devices = devices
                self.isEditStatus = false
            } failure: { [weak self] in
                guard let `self` = self else { return }
                room.devices = self.originalEditingList
                self.reloadCurrentRoom()
                self.isEditStatus = false
            }
            break
        case .moveOutUsed:
            self.viewModel.moveDevicesOutOfUsed(deviceIds: selectIds, roomId: room.id) { [weak self] in
                guard let `self` = self else { return }
                room.devices.removeAll { device in
                    return device.isSelected
                }
                self.isEditStatus = false
            } failure: { [weak self] in
                guard let `self` = self else { return }
                room.devices = self.originalEditingList
                self.reloadCurrentRoom()
                self.isEditStatus = false
            }
            break
        case .move:
            let vc = SCMoveRoomDeviceViewController()
            vc.deviceIds = selectIds
            vc.fromRoomId = room.id
            vc.rooms = self.viewModel.roomList
            self.navigationController?.pushViewController(vc, animated: true)
            self.isEditStatus = false
            break
        case .share:
            let vc = SCAccountTypeViewController()
            vc.sourceType = .shareDevice
            vc.param = ["deviceIds": selectIds]
            self.navigationController?.pushViewController(vc, animated: true)
            self.isEditStatus = false
            break
        case .delete:
            SCAlertView.alertDefault(title: nil, message: tempLocalize("确定删除选中的设备吗"), confirmCallback: { [weak self ] in
                guard let `self` = self else { return }
                let deviceId = selectIds.first ?? ""
                self.viewModel.unbindDeviceFromRoom(deviceId: deviceId, roomId: room.id) { [weak self] in
                    guard let `self` = self else { return }
                    room.devices.removeAll { device in
                        return device.isSelected
                    }
                    self.isEditStatus = false
                }
            })
            break
        case .rename:
            let device = selectDevices.first
            let deviceId = selectIds.first ?? ""
            SCAlertView.alertText(title: tempLocalize("修改设备名称"), range: NSRange(location: 0, length: 12), placeholder: tempLocalize("输入设备名称"), content: device?.nickname, confirmCallback: { [weak self] text in
                guard let `self` = self else { return }
                self.viewModel.modifyDeviceNickname(deviceId: deviceId, roomId: room.id, name: text) { [weak self] in
                    guard let `self` = self else { return }
                    device?.nickname = text
                    self.isEditStatus = false
                }
            })
            break
        }
    }
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.contentSize = CGSize(width: kSCScreenWidth, height: kSCScreenHeight - kSCBottomSafeHeight - 49 + (72 + kSCStatusBarHeight - 20))
        scroll.delegate = self
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(scrollPanGestureAction(_:)))
        pan.delegate = self
        scroll.addGestureRecognizer(pan)
        if #available(iOS 11.0, *) {
            scroll.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        return scroll
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        self.viewModel.loadFamilyId()
        self.isEditStatus = false
        self.loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SCSmartNetworking.sharedInstance.unsubscribeAll()
    }
}

extension SCHomePageViewController {
    override func setupView() {
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.headerView)
        self.scrollView.addSubview(self.pageView)
        self.view.addSubview(self.editingBar)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            self?.scrollView.contentOffset = .zero
        }
    }
    
    override func setupLayout() {
        self.headerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(kSCScreenWidth)
            make.top.equalToSuperview().offset(kSCStatusBarHeight)
            make.height.equalTo(72)
        }
        self.pageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(self.headerView)
            make.top.equalTo(self.headerView.snp.bottom).offset(kSCStatusBarHeight - 20)
            make.height.equalTo(kSCScreenHeight - kSCStatusBarHeight - kSCBottomSafeHeight - 49)
        }
        self.scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.snp.bottomMargin)
        }
        self.editingBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(-(kSCStatusBarHeight + 72 + kSCStatusBarHeight - 20))
            make.height.equalTo(kSCStatusBarHeight + 72)
        }
        self.bootomView.frame = CGRect(x: 0, y: kSCScreenHeight, width: kSCScreenWidth, height: kSCBottomSafeHeight + 60)
    }
    
    override func setupData() {
        let types: [SCHomePageBottomItemType] = [.moveTop, .moveOutUsed, .move, .share, .delete, .rename]
        self.bootomView.list = types
        
        self.setupMJHeader()
    }
    
    override func setupObservers() {
        kAddObserver(self, #selector(bindDeviceSuccessNotification(_:)), kBindDeviceSuccessNotificationKey, nil)
        kAddObserver(self, #selector(willEnterForegroundNotification), UIApplication.willEnterForegroundNotification.rawValue)
    }
    
    private func setupMJHeader() {
        self.scrollView.mj_header = MJRefreshNormalHeader { [weak self] in
            guard let `self` = self else { return }
            self.loadData()
        }
        self.scrollView.mj_header?.ignoredScrollViewContentInsetTop = -kSCStatusBarHeight
        self.scrollView.mj_header?.isHidden = true
    }
    
    private func loadData(isNewFamily: Bool = false) {
        self.viewModel.loadData(isNewFamily: isNewFamily) { [weak self] in
            guard let `self` = self else { return }
            self.reloadFamily()
            self.scrollView.mj_header?.endRefreshing()
        } failure: { [weak self] in
            guard let `self` = self else { return }
            self.scrollView.mj_header?.endRefreshing()
        }
    }
    
    @objc private func bindDeviceSuccessNotification(_ notification: Notification) {
        guard let json = notification.userInfo as? [String: String] else { return }
        guard let sn = json["sn"], let deviceId = json["deviceId"], let productId = json["productId"] else { return }
        self.addDeviceToRoom(deviceId: deviceId, sn: sn, productId: productId)
    }
    
    @objc private func willEnterForegroundNotification() {
        if self.view.window != nil {
            self.isEditStatus = false
            self.loadData()
        }
    }
}

extension SCHomePageViewController {
    private func showEditingBar() {
        kGetNormalWindow()?.addSubview(self.bootomView)
        UIView.animate(withDuration: 0.3) {
            self.editingBar.transform = CGAffineTransform(translationX: 0, y: kSCStatusBarHeight + (72 + kSCStatusBarHeight - 20))
            self.bootomView.transform = CGAffineTransform(translationX: 0, y: -(kSCBottomSafeHeight + 60))
        }
    }
    
    private func hideEditingBar() {
        UIView.animate(withDuration: 0.3) {
            self.editingBar.transform = CGAffineTransform.identity
            self.bootomView.transform = CGAffineTransform.identity
        } completion: { _ in
            self.bootomView.removeFromSuperview()
        }

    }
    
    private func selectAllAction() {
        guard self.viewModel.roomList.count > self.currentRoomIndex else { return }
        let room = self.viewModel.roomList[self.currentRoomIndex]
        let isSelected: Bool = room.devices.filter({ $0.isSelected }).count != room.devices.count
        for device in room.devices {
            device.isSelected = isSelected
        }
        self.reloadCurrentRoom()
    }
    
    private func reloadFamily() {
        self.pageView.reloadData(rooms: self.viewModel.roomList)
        self.headerView.familyName = self.viewModel.family.name
    }
    
    private func reloadEditState() {
        guard self.viewModel.roomList.count > self.currentRoomIndex else { return }
        let room = self.viewModel.roomList[self.currentRoomIndex]
        if self.isEditStatus {
            self.showEditingBar()
            self.originalEditingList = room.devices
        }
        else {
            self.hideEditingBar()
        }
        for device in room.devices {
            device.isEditing = self.isEditStatus
            if !device.isEditing {
                device.isSelected = false
            }
        }
        self.reloadCurrentRoom()
    }
    
    private func reloadCurrentRoom() {
        guard self.viewModel.roomList.count > self.currentRoomIndex else { return }
        let room = self.viewModel.roomList[self.currentRoomIndex]
        self.pageView.reloadData(atIndex: self.currentRoomIndex)
        self.editingBar.selectCount = room.devices.filter({ $0.isSelected }).count
    }
    
    private func reloadBottomView() {
        guard self.viewModel.roomList.count > self.currentRoomIndex else { return }
        let room = self.viewModel.roomList[self.currentRoomIndex]
        let selectDevices = room.devices.filter({ $0.isSelected })
        var types: [SCHomePageBottomItemType] = []
        let usedRoom = self.viewModel.roomList.filter({ $0.isUsed }).first ?? self.viewModel.roomList[0]
        let usedDevices = usedRoom.devices
        var hasNoUsedDevice = false
        var hasNoOwnerDevice: Bool = false
        for device in selectDevices {
            if !device.isOwner {
                hasNoOwnerDevice = true
            }
            if let _ = usedDevices.first(where: { item in
                return device.deviceId == item.deviceId
            }) {
                
            }
            else {
                hasNoUsedDevice = true
                break
            }
        }
        
        if selectDevices.count == 1 {
            if room.isUsed {
                types = [.moveTop, .moveOutUsed, .share, .delete, .rename]
            }
            else {
                if hasNoUsedDevice {
                    types = [.addToUsed, .move, .share, .delete, .rename]
                }
                else {
                    types = [.move, .share, .delete, .rename]
                }
            }
        }
        else if selectDevices.count > 1 {
            if room.isUsed {
                types = [.moveTop, .moveOutUsed, .share]
            }
            else {
                if hasNoUsedDevice {
                    types = [.addToUsed, .move, .share]
                }
                else {
                    types = [.move, .share]
                }
            }
        }
        var typeList: [SCHomePageBottomItemType] = []
        if hasNoOwnerDevice {
            for type in types {
                if type == .addToUsed || type == .moveOutUsed || type == .moveTop || type == .delete {
                    typeList.append(type)
                }
            }
        }
        else {
            typeList = types
        }
        self.bootomView.list = typeList
    }
    
    private func enterDevice(index: Int) {
        guard self.viewModel.roomList.count > self.currentRoomIndex, self.viewModel.roomList[self.currentRoomIndex].devices.count > index else { return }
        let device = self.viewModel.roomList[self.currentRoomIndex].devices[index]
        
        SCSmartNetworking.sharedInstance.setDevice(productId: device.productId, sn: device.sn)
//        SCSmartNetworking.sharedInstance.setDevice(productId: "f000k08DF1cm8BFA", sn: "TEST202100001")
        let vc = SCSweeperCleaningViewController()
        vc.device = device
        self.navigationController?.pushViewController(vc, animated: true)
        
        SCBPLog("进入设备 设备ID:\(device.id), 产品ID:\(device.productId), 工程类型:\(device.productModeCode)")
    }
}

// MARK: - 拖拽相关方法
extension SCHomePageViewController: UIScrollViewDelegate, UIGestureRecognizerDelegate {
    /// 支持混合手势
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /// 拖拽事件
    @objc private func scrollPanGestureAction(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.panOffsetY = 0
            self.isScrollEnabled = false
            self.isPageViewScrollEnabled = false
            break
        case .changed:
            let currentY = gesture.translation(in: self.scrollView).y
            if self.isScrollEnabled || self.isPageViewScrollEnabled { // 说明在这次滑动过程中经过了临界点
                if self.panOffsetY == 0 {
                    self.panOffsetY = currentY
                }
                let offsetY = self.panOffsetY - currentY
                
                if self.isScrollEnabled {
                    let supposeY = (72 + kSCStatusBarHeight - 20) + offsetY
                    self.scrollView.contentOffset = CGPoint(x: 0, y: supposeY)
                }
                else {
                    self.pageView.setContentOffset(offset: CGPoint(x: 0, y: offsetY))
                }
            }
            else if !self.isScrollEnabled && !self.isPageViewScrollEnabled && self.scrollView.contentOffset.y >= 72 + kSCStatusBarHeight - 20 {
                self.isScrollEnabled = true
//                if self.panOffsetY == 0 {
//                    self.panOffsetY = currentY
//                }
//                let offsetY = self.panOffsetY - currentY
//                let supposeY = 72 + offsetY
//                self.scrollView.contentOffset = CGPoint(x: 0, y: supposeY)
            }
            
            break
        case .ended:
            self.refreshScrollByEndDragging()
            break
        default:
            break
        }
    }
    
    /// 主ScrollView拖拽中
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 72 + kSCStatusBarHeight - 20 {
            self.changedScrollEnabled(isScrollEnabled: false, needChangeValue: true)
        }
        if scrollView.contentOffset.y < 0 {
            self.scrollView.mj_header?.isHidden = false
        }
        else {
            self.scrollView.mj_header?.isHidden = true
        }
    }
    
    /// PageView ContentView scrollView 拖拽中
    private func pageViewScrollDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            scrollView.setContentOffset(CGPoint.zero, animated: false)
            self.changedScrollEnabled(isScrollEnabled: true, needChangeValue: true)
        }
    }
    
    /// 改变主ScrollView与PageView ScrollView的属性
    private func changedScrollEnabled(isScrollEnabled: Bool, needChangeValue: Bool = false) {
        self.isScrollEnabled = isScrollEnabled
        self.scrollView.isScrollEnabled = isScrollEnabled
        
        self.isPageViewScrollEnabled = !isScrollEnabled
        self.pageView.isScrollEnabled = !isScrollEnabled
    }

    /// 结束拖拽后刷新scrollview
    func refreshScrollByEndDragging() {
        if self.scrollView.mj_header?.isRefreshing == true {
            return
        }
        do { // 刷新主ScrollView位置
            var contentOffsetY: CGFloat = 0
            if self.scrollView.contentOffset.y < (72 + kSCStatusBarHeight - 20) / 2 {
                contentOffsetY = 0
                self.changedScrollEnabled(isScrollEnabled: true)
            }
            else {
                contentOffsetY = 72 + kSCStatusBarHeight - 20
                self.changedScrollEnabled(isScrollEnabled: false)
            }
            self.scrollView.setContentOffset(CGPoint(x: 0, y: contentOffsetY), animated: true)
        }
        
        // 刷新pageView scrolView位置
        self.pageView.refreshScrollOffsetByEndDragging()
    }
}

extension SCHomePageViewController {
    private func addDeviceToRoom(deviceId: String, sn: String, productId: String, isNewRoom: Bool = false) {
        self.addDeviceRoomList = self.viewModel.roomList.filter({ !$0.isUsed })
        for (i, item) in self.addDeviceRoomList.enumerated() {
            if isNewRoom {
                item.isSelected = i == self.addDeviceRoomList.count - 1
            }
            else {
                item.isSelected = i == 0
            }
        }
        self.addDeviceRoomsView.set(list: self.addDeviceRoomList, isOwner: self.viewModel.family.isOwner) { [weak self] index in
            guard let `self` = self else { return }
            for (i, room) in self.addDeviceRoomList.enumerated() {
                room.isSelected = i == index
            }
            self.addDeviceRoomsView.reloadData()
        } addHandle: { [weak self] in
            SCAlertView.hide()
            SCAlertView.alertText(title: tempLocalize("新建房间名"), range: NSRange(location: 0, length: 12), placeholder: tempLocalize("请输入房间名"), cancelTitle: tempLocalize("上一步"), confirmTitle: tempLocalize("下一步"), cancelCallback: { [weak self] in
                self?.alertAddDeviceRoomListView(deviceId: deviceId, sn: sn, productId: productId)
            }, confirmCallback: { [weak self] text in
                guard let `self` = self else { return }
                self.viewModel.addRoom(familyId: self.viewModel.family.id, name: text) { [weak self] in
                    guard let `self` = self else { return }
                    self.viewModel.loadFamilyDetail(familyId: self.viewModel.family.id, success: { [weak self] in
                        self?.addDeviceToRoom(deviceId: deviceId, sn: sn, productId: productId, isNewRoom: true)
                    }, failure: {
                        
                    })
                }
            }, isNeedManualHide: true)
        }
        
        self.alertAddDeviceRoomListView(deviceId: deviceId, sn: sn, productId: productId)
    }
    
    private func alertAddDeviceRoomListView(deviceId: String, sn: String, productId: String) {
        SCAlertView.alert(title: tempLocalize("选择房间"), customView: self.addDeviceRoomsView, confirmTitle: tempLocalize("确定"), confirmCallback: { [weak self] in
            guard let `self` = self, self.addDeviceRoomList.count > self.addDeviceRoomsView.currentIndex else { return }
            self.addDeviceRoom = self.addDeviceRoomList[self.addDeviceRoomsView.currentIndex]
            
            SCAlertView.alertText(title: tempLocalize("重命名"), range: NSRange(location: 0, length: 12), placeholder: tempLocalize("输入设备昵称"), content: nil, cancelTitle: tempLocalize("上一步"), confirmTitle: tempLocalize("确定"), cancelCallback: { [weak self] in
                self?.alertAddDeviceRoomListView(deviceId: deviceId, sn: sn, productId: productId)
            }, confirmCallback: { [weak self] text in
                guard let `self` = self else { return }
                let roomId = self.addDeviceRoom?.id ?? ""
                self.viewModel.bindDeviceToRoom(deviceId: deviceId, roomId: roomId, familyId: self.viewModel.family.id, nickname: text, sn: sn, productId: productId) { [weak self] in
                    self?.viewModel.modifyDeviceNickname(deviceId: deviceId, roomId: roomId, name: text, success: {
                        self?.loadData()
                    })
                    SCAlertView.hide()
                } failure: {
                    
                }

            }, isNeedManualHide: true)
        })
    }
}

