//
//  SCDeviceShareUserListViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/29.
//

import UIKit

class SCDeviceShareUserListViewController: SCBasicViewController {

    var device: SCNetResponseDeviceModel? {
        didSet {
            self.items = self.device?.shareItems ?? []
        }
    }
    
    private var items: [SCNetResponseShareInfoModel] = []
    
    private let viewModel = SCDeviceShareUserListViewModel()
    
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCDeviceShareUserListItemCell.self, cellIdendify: SCDeviceShareUserListItemCell.identify, rowHeight: nil, hasEmptyView: true)
        tableView.canDeleteEdit = true
        tableView.set { indexPath in
            SCAlertView.alert(title: tempLocalize("提示"), message: tempLocalize("确认删除该分享？"), cancelTitle: tempLocalize("取消"), confirmTitle: tempLocalize("确定"), confirmCallback: { [weak self] in
                guard let `self` = self, self.items.count > indexPath.row else { return }
                let item = self.items[indexPath.row]
                self.viewModel.deleteShare(shareId: item.id) { [weak self] in
                    guard let `self` = self else { return }
                    self.items.remove(at: indexPath.row)
                    self.device?.shareItems = self.items
                    self.tableView.set(list: [self.items])
                }
            })
        }
        return tableView
    }()
    
    private lazy var shareButton: UIButton = UIButton(tempLocalize("添加共享"), titleColor: "Mine.DeviceShareController.UserListController.shareButton.textColor", font: "Mine.DeviceShareController.UserListController.shareButton.font", target: self, action: #selector(shareButtonAction), backgroundColor: "Mine.DeviceShareController.UserListController.shareButton.backgroundColor", cornerRadius: 12)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
}

extension SCDeviceShareUserListViewController {
    override func setupView() {
        self.title = tempLocalize("共享列表")
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.shareButton)        
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
            make.bottom.equalTo(self.shareButton.snp.top).offset(-10)
        }
        self.shareButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-36)
            make.height.equalTo(56)
        }
    }
    
    override func setupData() {
        self.tableView.set(list: [self.items])
    }
    
    @objc private func shareButtonAction() {
        guard let device = self.device else { return }
        let vc = SCDeviceShareAddViewController()
        vc.devices = [device]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
