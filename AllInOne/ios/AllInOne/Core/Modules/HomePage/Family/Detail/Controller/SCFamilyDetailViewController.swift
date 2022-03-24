//
//  SCFamilyDetailViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/22.
//

import UIKit

class SCFamilyDetailViewController: SCBasicViewController {
    
    var family: SCNetResponseFamilyModel = SCNetResponseFamilyModel()
    private var list: [SCAddFamilyItemModel] = []
    
    private var deleteFamilyBlock: (() -> Void)?
    
    private let viewModel = SCFamilyDetailViewModel()
    
    private lazy var tableView: SCBasicTableView = SCBasicTableView(cellClass: SCAddFamilyItemCell.self, cellIdendify: SCAddFamilyItemCell.identify, rowHeight: nil) { [weak self] indexPath in
        guard let `self` = self else { return }
        let model = self.list[indexPath.row]
        guard model.hasNext else { return }
        switch model.type {
        case .name:
            SCAlertView.alertText(title: tempLocalize("家庭名称"), range: NSRange(location: 0, length: 12), placeholder: tempLocalize("请输入家庭名称"), content: model.content, confirmCallback: { [weak self] text in
                guard let `self` = self else { return }
                let oldName = self.family.name
                self.family.name = text
                if text.count > 0 {
                    if self.family.id.count > 0 {
                        self.viewModel.saveFamily(family: self.family) { [weak self] in
                            guard let `self` = self else { return }
                            self.family.name = text
                            model.content = text
                            self.reloadData()
                        } failure: { [weak self] in
                            guard let `self` = self else { return }
                            self.family.name = oldName
                            self.reloadData()
                        }
                    }
                    else {
//                        model.content = text
                        self.reloadData()
                    }
                }
            })
            break
        case.location:
            SCFamilyLocationViewController.checkMapPrivacy { [weak self] in
                guard let `self` = self else { return }
                let vc = SCFamilyLocationViewController()
                vc.add { [weak self] location in
                    guard let `self` = self else { return }
                    let oldAdress = self.family.address
                    self.family.address = location.locationName
                    if self.family.id.count > 0 {
                        self.viewModel.saveFamily(family: self.family) { [weak self] in
                            guard let `self` = self else { return }
                            self.reloadData()
                        } failure: { [weak self] in
                            guard let `self` = self else { return }
                            self.family.address = oldAdress
                            self.reloadData()
                        }
                    }
                    else {
    //                    model.content = location.locationName
                        self.reloadData()
                    }
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case .device:
            
            break
        case .room:
            let vc = SCRoomListViewController()
            vc.family = self.family
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .member:
            let vc = SCMemberListViewController()
            vc.family = self.family
            self.navigationController?.pushViewController(vc, animated: true)
            break
        }
    }
    
    private lazy var deleteFamilyButton: UIButton = UIButton(tempLocalize("删除家庭"), titleColor: "HomePage.FamilyListController.FamilyDetailController.deleteFamilyButton.textColor", font: "HomePage.FamilyListController.FamilyDetailController.deleteFamilyButton.font", target: self, action: #selector(deleteFamilyButtonAction), backgroundColor: "HomePage.FamilyListController.FamilyDetailController.deleteFamilyButton.backgroundColor", cornerRadius: 12)
    
    private lazy var exitFamilyButton: UIButton = UIButton(tempLocalize("退出家庭"), titleColor: "HomePage.FamilyListController.FamilyDetailController.deleteFamilyButton.textColor", font: "HomePage.FamilyListController.FamilyDetailController.deleteFamilyButton.font", target: self, action: #selector(exitFamilyButtonAction), backgroundColor: "HomePage.FamilyListController.FamilyDetailController.deleteFamilyButton.backgroundColor", cornerRadius: 12)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadData()
    }
    
    func add(deleteFamilyHandle: (() -> Void)?) {
        self.deleteFamilyBlock = deleteFamilyHandle
    }
}

extension SCFamilyDetailViewController {
    override func setupView() {
        self.title = tempLocalize("家庭管理")
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.deleteFamilyButton)
        self.view.addSubview(self.exitFamilyButton)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
            make.bottom.equalTo(self.deleteFamilyButton.snp.bottom).offset(-10)
        }
        self.deleteFamilyButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-36)
        }
        self.exitFamilyButton.snp.makeConstraints { make in
            make.edges.equalTo(self.deleteFamilyButton)
        }
    }
    
    override func setupData() {
        let types: [SCAddFamilyItemType] = [.name, .location, .device, .room, .member]
        let names: [String] = [tempLocalize("家庭名称"), tempLocalize("家庭位置"), tempLocalize("全部设备数量"), tempLocalize("房间管理"), tempLocalize("家庭成员")]
        let images: [ThemeImagePicker?] = ["HomePage.FamilyListController.FamilyDetailController.ItemCell.coverImage.nameImage", "HomePage.FamilyListController.FamilyDetailController.ItemCell.coverImage.locationImage", "HomePage.FamilyListController.FamilyDetailController.ItemCell.coverImage.deviceImage", "HomePage.FamilyListController.FamilyDetailController.ItemCell.coverImage.roomImage", "HomePage.FamilyListController.FamilyDetailController.ItemCell.coverImage.memberImage"]
        let placeholders: [String] = [tempLocalize("请输入新建家庭的名称"), tempLocalize("请设定家庭位置"), "", "", ""]
        
        var items: [SCAddFamilyItemModel] = []
        for (i, type) in types.enumerated() {
            let item = SCAddFamilyItemModel()
            item.type = type
            item.name = names[i]
            item.image = images[i]
            item.placeholder = placeholders[i]
            
            if self.family.isOwner { //管理员
                item.hasNext = true
            }
            else {
                if type == .room || type == .member {
                    item.hasNext = true
                }
                else {
                    item.hasNext = false
                }
            }
            
            items.append(item)
        }
        self.list = items
        self.reloadData()
        self.loadData()
    }
    
    private func loadData() {
        self.viewModel.loadFamilyDetail(familyId: self.family.id) { [weak self] in
            guard let `self` = self else { return }
            self.family.rooms = self.viewModel.roomList
            self.reloadData()
        }
    }
    
    private func reloadData() {
        let isOwner = self.family.creatorId == SCSmartNetworking.sharedInstance.user?.id
        self.deleteFamilyButton.isHidden = !isOwner
        self.exitFamilyButton.isHidden = isOwner
        
        for item in self.list {
            switch item.type {
            case .name:
                item.content = self.family.name
            case .location:
                item.content = self.family.address
            case .device:
                item.content = self.family.deviceNum + tempLocalize("个设备")
            case .room:
                var roomNumber = (Int(self.family.roomNum) ?? 0) - 1
                if roomNumber < 0 {
                    roomNumber = self.family.rooms.count - 1
                }
                item.content = String(roomNumber) + tempLocalize("个房间")
            case .member:
                item.content = self.family.memberNum + tempLocalize("个成员")
            }
        }
        self.tableView.set(list: [self.list])
    }
    
    @objc private func deleteFamilyButtonAction() {
        SCAlertView.alert(title: tempLocalize("提示"), message: tempLocalize("确认删除家庭？"), cancelTitle: tempLocalize("取消"), confirmTitle: tempLocalize("确认"), confirmCallback: { [weak self] in
            guard let `self` = self else { return }
            self.viewModel.deleteFamily(familyId: self.family.id) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
                self?.deleteFamilyBlock?()
            }
        })
    }
    
    @objc private func exitFamilyButtonAction() {
        SCAlertView.alert(title: tempLocalize("提示"), message: tempLocalize("确认退出家庭？"), cancelTitle: tempLocalize("取消"), confirmTitle: tempLocalize("确认"), confirmCallback: { [weak self] in
            guard let `self` = self else { return }
            self.viewModel.exitFamily(familyId: self.family.id) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
                self?.deleteFamilyBlock?()
            }
        })
    }
}
