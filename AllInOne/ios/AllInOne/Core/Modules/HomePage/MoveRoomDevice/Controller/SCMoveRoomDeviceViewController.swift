//
//  SCMoveRoomDeviceViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/20.
//

import UIKit

class SCMoveRoomDeviceViewController: SCBasicViewController {

    var rooms: [SCNetResponseFamilyRoomModel] = []
    var deviceIds: [String] = []
    var fromRoomId: String = ""
    private var toRoomId: String = ""
    
    private var currentIndex: Int = 0
    
    private let viewModel: SCMoveRoomDeviceViewModel = SCMoveRoomDeviceViewModel()
    
    private lazy var tableView: SCBasicTableView = SCBasicTableView(cellClass: SCMoveRoomDeviceCell.self, cellIdendify: SCMoveRoomDeviceCell.identify, rowHeight: nil) { [weak self] indexPath in
        guard let `self` = self else { return }
        guard self.currentIndex < self.rooms.count, indexPath.row < self.rooms.count else { return }
        self.rooms[self.currentIndex].isSelected = false
        self.rooms[indexPath.row].isSelected = true
        self.tableView.reloadData()
        
        self.currentIndex = indexPath.row
        self.toRoomId = self.rooms[indexPath.row].id
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}

extension SCMoveRoomDeviceViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("移动设备")
        self.addRightBarButtonItem(image: "Global.GeneralImage.saveImage", action: #selector(saveButtonAction))
    }
    
    override func setupView() {
        self.view.addSubview(tableView)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
        }
    }
    
    override func setupData() {
        let items = self.rooms.filter({ !$0.isUsed })
        self.rooms = items
        self.currentIndex = self.rooms.firstIndex(where: { room in
            return room.id == self.toRoomId
        }) ?? 0
        if self.rooms.count > 0 {
            self.toRoomId = self.rooms[self.currentIndex].id
            self.rooms[self.currentIndex].isSelected = true
        }
        self.tableView.set(list: [self.rooms])
    }
}

extension SCMoveRoomDeviceViewController {
    @objc private func saveButtonAction() {
        self.viewModel.saveMoveRoomDevice(deviceIds: self.deviceIds, fromRoomId: self.fromRoomId, toRoomId: self.toRoomId) { [weak self] in
            guard let `self` = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
    }
}
