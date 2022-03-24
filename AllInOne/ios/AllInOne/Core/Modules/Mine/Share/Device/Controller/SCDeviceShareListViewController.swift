//
//  SCDeviceShareListViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/29.
//

import UIKit

class SCDeviceShareListViewController: SCBasicViewController {

    private var isShareEditing: Bool = false {
        didSet {
            self.reloadEditingData()
        }
    }
    
    private let viewModel = SCDeviceShareViewModel()
    
    private lazy var menuView: SCDeviceShareMenuView = SCDeviceShareMenuView { [weak self] type in
        guard let `self` = self else { return }
        if self.isShareEditing {
            return
        }
        self.shareView.isHidden = type != .share
        self.acceptView.isHidden = type != .accept
        self.menuView.type = type
        self.editButton.isHidden = type != .share
    }
    
    private lazy var shareView: SCBasicTableView = SCBasicTableView(cellClass: SCDeviceShareShareItemCell.self, cellIdendify: SCDeviceShareShareItemCell.identify, rowHeight: nil, hasEmptyView: true) { [weak self] indexPath in
        guard let `self` = self, self.viewModel.shareList.count > indexPath.row else { return }
        let item = self.viewModel.shareList[indexPath.row]
        if self.isShareEditing {
            item.isSelected = !item.isSelected
            self.shareView.reloadData()
            self.refreshShareButton()
        }
        else {
            let vc = SCDeviceShareUserListViewController()
            vc.device = item
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private lazy var acceptView: SCBasicTableView = SCBasicTableView(cellClass: SCShareHistoryItemCell.self, cellIdendify: SCShareHistoryItemCell.identify, rowHeight: nil, cellDelegate: self, hasEmptyView: true) { [weak self] indexPath in
        guard let `self` = self else { return }
        
    }
    
    private lazy var cancelButton: UIButton = UIButton(image: "Mine.DeviceShareController.cancelEditImage", target: self, action: #selector(cancelButtonAction))
    
    private lazy var editButton: UIButton = UIButton(image: "Mine.DeviceShareController.editImage", target: self, action: #selector(editButtonAction))
    
    private lazy var selectAllButton: UIButton = UIButton(image: "Mine.DeviceShareController.selectAllImage", target: self, action: #selector(selectAllButtonAction))
    
    private lazy var shareButton: SCDeviceShareBottomShareButton = SCDeviceShareBottomShareButton(self, action: #selector(shareButtonAction))
//    private lazy var shareButton: UIButton = {
//        let btn = UIButton(tempLocalize("共享"), titleColor: "Mine.DeviceShareController.shareButton.textColor", font: "Mine.DeviceShareController.shareButton.font", target: self, action: #selector(shareButtonAction), backgroundColor: "Mine.DeviceShareController.shareButton.disabledBackgroundColor")
//        btn.theme_setImage("Mine.DeviceShareController.shareButton.image", forState: .normal)
//        return btn
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadData()
    }
}

extension SCDeviceShareListViewController {
    override func setupNavigationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.editButton)
    }
    
    override func setupView() {
        self.title = tempLocalize("设备列表")
        self.view.addSubview(self.menuView)
        self.view.addSubview(self.shareView)
        self.view.addSubview(self.acceptView)
        self.view.addSubview(self.shareButton)
        
        self.acceptView.isHidden = true
        self.shareButton.isHidden = false
    }
    
    override func setupLayout() {
        self.menuView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
            make.height.equalTo(64)
        }
        self.shareView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.menuView.snp.bottom)
        }
        self.acceptView.snp.makeConstraints { make in
            make.edges.equalTo(self.shareView)
        }
        self.shareButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(78)
            make.top.equalTo(self.view.snp.bottom)
        }
    }
    
    private func loadData() {
        self.viewModel.loadData { [weak self] in
            self?.reloadData()
        }
    }
    
    private func reloadData() {
        self.shareView.set(list: [self.viewModel.shareList])
        self.acceptView.set(list: [self.viewModel.acceptList])
    }
    
    private func reloadEditingData() {
        for item in self.viewModel.shareList {
            item.isEditing = self.isShareEditing
            if !item.isEditing {
                item.isSelected = false
            }
        }
        self.shareView.reloadData()
        
        var transform: CGAffineTransform = .identity
        if self.isShareEditing {
            transform = CGAffineTransform(translationX: 0, y: -78)
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.shareButton.transform = transform
        }
        
        if self.isShareEditing {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.cancelButton)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.selectAllButton)
        }
        else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backBarButton)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.editButton)
        }
        
        self.refreshShareButton()
    }
    
    private func refreshShareButton() {
        let selectedCount = self.viewModel.shareList.filter({ $0.isSelected }).count
        if self.isShareEditing && selectedCount > 0 {
            self.shareButton.isEnabled = true
        }
        else {
            self.shareButton.isEnabled = false
        }
    }
    
    @objc private func editButtonAction() {
        self.isShareEditing = true
    }
    
    @objc private func selectAllButtonAction() {
        var isSelected: Bool = true
        let selectedCount = self.viewModel.shareList.filter({ $0.isSelected }).count
        if selectedCount == self.viewModel.shareList.count {
            isSelected = false
        }
        for item in self.viewModel.shareList {
            item.isSelected = isSelected
        }
        self.shareView.reloadData()
        self.refreshShareButton()
    }
 
    @objc private func cancelButtonAction() {
        self.isShareEditing = false
    }
    
    @objc private func shareButtonAction() {
        let items = self.viewModel.shareList.filter({ $0.isSelected })
        self.isShareEditing = false
        let vc = SCDeviceShareAddViewController()
        vc.devices = items
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SCDeviceShareListViewController: SCShareHistoryItemCellDelegate {
    func cell(_ cell: SCShareHistoryItemCell, didClickStatusWithModel item: SCNetResponseShareInfoModel) {
        let contentView = SCShareDeviceAlertContentView(imageUrl: item.imageUrl, source: item.username)
        SCAlertView.alert(title: tempLocalize("共享设备"), customView: contentView, cancelTitle: tempLocalize("拒绝"), confirmTitle: tempLocalize("同意"), cancelCallback: { [weak self] in
            guard let `self` = self else { return }
            self.replyShare(item: item, replyType: .refused)
        }, confirmCallback: { [weak self] in
            guard let `self` = self else { return }
            self.replyShare(item: item, replyType: .agreed)
        })
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
            self.acceptView.reloadData()
        } failure: { [weak self] in
            guard let `self` = self else { return }
            SCProgressHUD.showHUD(tempLocalize("请求失败"))
        }

    }
}
