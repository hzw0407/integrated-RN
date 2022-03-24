//
//  SCRoomListViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/22.
//

import UIKit

class SCRoomListViewController: SCBasicViewController {

    var family: SCNetResponseFamilyModel? {
        didSet {
            guard let family = family else { return }

            self.familyId = family.id
            self.list = family.rooms
            for item in self.list {
                item.isOwner = family.isOwner
            }
            self.reloadData()
        }
    }
    
    private var addRoomBlock: (() -> Void)?
    
    private var familyId: String = ""
    private var list: [SCNetResponseFamilyRoomModel] = []
        
    private let viewModel = SCRoomListViewModel()
    
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCRoomListItemCell.self, cellIdendify: SCRoomListItemCell.identify, rowHeight: nil) { [weak self] indexPath in
            guard let `self` = self, self.list.count > indexPath.row else { return }
            let room = self.list[indexPath.row]
            guard room.isOwner else { return }
            SCAlertView.alertText(title: tempLocalize("修改房间名称"), range: NSRange(location: 0, length: 12), placeholder: tempLocalize("请输入房间名称"), content: room.roomName, confirmCallback: { [weak self] text in
                guard let `self` = self else { return }
                self.viewModel.modifyRoom(familyId: self.familyId, roomId: room.id, name: text) { [weak self] in
                    room.roomName = text
                    self?.reloadData()
                }
            })
        }
        tableView.canDeleteEdit = true
        tableView.set { [weak self] indexPath in
            guard let `self` = self else { return }
            guard let item = self.tableView.list[indexPath.section][indexPath.row] as? SCNetResponseFamilyRoomModel else { return }
            
            let block = {
                SCAlertView.alert(title: tempLocalize("删除房间"), message: tempLocalize("确认删除房间？"), cancelTitle: tempLocalize("取消"), confirmTitle: tempLocalize("确认"), confirmCallback: { [weak self] in
                    guard let `self` = self else { return }
                    self.viewModel.deleteRooms(roomIds: [item.id]) { [weak self] in
                        guard let `self` = self else { return }
                        self.list.removeAll { room in
                            return item.id == room.id
                        }
                        self.reloadData()
                    }
                })
            }
            
            if item.deviceNum > 0 {
                let message = String(format: tempLocalize("房间内包含%d个设备，请在首页设备列表长按设备，并移动至其他房间后再删除房间！"), item.deviceNum)
                SCAlertView.alert(title: tempLocalize("删除房间"), message: message, confirmTitle: tempLocalize("我知道了"), confirmCallback: {
                    block()
                })
            }
            else {
                block()
            }
        }
        return tableView
    }()
    
    private lazy var editButton: UIButton = UIButton(image: "HomePage.FamilyListController.RoomListController.editButton.editImage", target: self, action: #selector(editButtonAction), selectedImage: "HomePage.FamilyListController.RoomListController.editButton.saveImage")
    
    private lazy var addButton: UIButton = UIButton(image: "HomePage.FamilyListController.RoomListController.addImage", target: self, action: #selector(addButtonAction))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func set(addRoomHandle: (() -> Void)?) {
        self.addRoomBlock = addRoomHandle
    }
}

extension SCRoomListViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("房间管理")
        if self.family?.isOwner == true {
            self.editButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.editButton)
        }
    }
    
    override func setupView() {
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.addButton)
        
        self.addButton.isHidden = !(self.family?.isOwner == true)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
            make.bottom.equalToSuperview()
        }
        self.addButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-48)
            make.width.height.equalTo(52)
        }
    }
    
    override func setupData() {
        self.reloadData()
    }
    
    private func reloadData() {
        let items = self.list.filter({ $0.roomType != SCFamilyRoomType.share.rawValue })
        self.list = items
        self.tableView.set(list: [items])
    }
    
    @objc private func editButtonAction() {
        if self.editButton.isSelected { // 保存
            for item in self.list {
                item.isEditing = false
            }
            self.tableView.isEditing = false
            let newList: [SCNetResponseFamilyRoomModel] = (self.tableView.list[0] as? [SCNetResponseFamilyRoomModel]) ?? []
            let roomIds = newList.map{ return $0.id }
            self.viewModel.updateRoomsSort(familyId: self.familyId, roomIds: roomIds) { [weak self] in
                guard let `self` = self else { return }
                self.list = newList
                self.reloadData()
            }
        }
        else { // 编辑
            for item in self.list {
                if !item.isUsed {
                    item.isEditing = true
                }
            }
            self.tableView.set(editing: true, notEditingIndexPath: IndexPath(row: 0, section: 0))
            self.tableView.reloadData()
        }
        
        self.editButton.isSelected = !self.editButton.isSelected
    }
    
    @objc private func addButtonAction() {
        let vc = SCAddRoomViewController()
        vc.set { [weak self] name in
            guard let `self` = self else { return }
            self.viewModel.addRoom(familyId: self.familyId, roomName: name) { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.loadFamilyDetail(familyId: self.familyId) { [weak self] rooms in
                    guard let `self` = self else { return }
                    self.family?.rooms = rooms
                    self.family?.roomNum = String(rooms.count)
                    self.list = rooms
                    self.reloadData()
                }
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
