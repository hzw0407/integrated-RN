//
//  SCAddDeviceRoomsView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/23.
//

import UIKit

class SCAddDdeviceRoomsCell: SCBasicTableViewCell {
    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.HomePageController.AddDeviceToRoom.ItemCell.nameLabel.textColor", font: "HomePage.HomePageController.AddDeviceToRoom.ItemCell.nameLabel.font")
    private lazy var selectImageView: UIImageView = UIImageView(image: "HomePage.HomePageController.AddDeviceToRoom.ItemCell.selectedImage")
    private lazy var lineView: UIView = UIView(backgroundColor: "HomePage.HomePageController.AddDeviceToRoom.ItemCell.lineBackgroundColor")
    
    override func set(model: Any?) {
        guard let room = model as? SCNetResponseFamilyRoomModel else { return }
        self.nameLabel.text = room.roomName
        self.selectImageView.isHidden = !room.isSelected
        if room.isSelected {
            self.nameLabel.theme_textColor = "HomePage.HomePageController.AddDeviceToRoom.ItemCell.nameLabel.selectedTextColor"
        }
        else {
            self.nameLabel.theme_textColor = "HomePage.HomePageController.AddDeviceToRoom.ItemCell.nameLabel.textColor"
        }
    }
    
    override func setupView() {
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.selectImageView)
        self.contentView.addSubview(self.lineView)
    }
    
    override func setupLayout() {
        let margin: CGFloat = 24
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.top.bottom.equalToSuperview().inset(17)
            make.right.equalTo(self.selectImageView.snp.left).offset(-10)
        }
        self.selectImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-margin)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        self.lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(margin)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}

class SCAddDdeviceRoomsFooterView: SCBasicView {
    private lazy var addImageView: UIImageView = UIImageView(image: "HomePage.HomePageController.AddDeviceToRoom.AddView.addImage")
    
    private lazy var titleLabel: UILabel = UILabel(text: tempLocalize("新建房间"), textColor: "HomePage.HomePageController.AddDeviceToRoom.AddView.textColor", font: "HomePage.HomePageController.AddDeviceToRoom.AddView.font", alignment: .right)
    
    private lazy var addButton: UIButton = UIButton(target: self, action: #selector(addButtonAction))
    
    private var addBlock: (() -> Void)?
    
    convenience init(frame: CGRect, addHandle: (() -> Void)?) {
        self.init(frame: frame)
        self.addBlock = addHandle
    }
    
    override func setupView() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.addImageView)
        self.addSubview(self.addButton)
    }
    
    override func setupLayout() {
        self.titleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-17)
            make.right.equalTo(self.addImageView.snp.left).offset(-8)
        }
        self.addImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.width.height.equalTo(20)
            make.centerY.equalTo(self.titleLabel)
        }
        self.addButton.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel)
            make.right.equalTo(self.addImageView)
            make.centerY.equalTo(self.titleLabel)
            make.height.equalTo(40)
        }
    }
    
    @objc private func addButtonAction() {
        self.addBlock?()
    }
}

class SCAddDeviceRoomsView: SCBasicView {
    
    private var didSelectBlock: ((Int) -> Void)?
    private var addBlock: (() -> Void)?
    
    private (set) var currentIndex: Int = 0

    private lazy var tableView: SCBasicTableView = SCBasicTableView(cellClass: SCAddDdeviceRoomsCell.self, cellIdendify: SCAddDdeviceRoomsCell.identify, rowHeight: nil) { [weak self] indexPath in
        guard let `self` = self else { return }
        self.currentIndex = indexPath.row
        self.didSelectBlock?(indexPath.row)
    }
    
    private lazy var footerView: SCAddDdeviceRoomsFooterView = SCAddDdeviceRoomsFooterView(frame: CGRect(x: 0, y: 0, width: kSCScreenWidth, height: 68)) { [weak self] in
        self?.addBlock?()
    }
    
    func set(list: [SCNetResponseFamilyRoomModel], isOwner: Bool, didSelectHandle: ((Int) -> Void)?, addHandle: (() -> Void)?) {
        self.tableView.set(list: [list])
        self.didSelectBlock = didSelectHandle
        self.addBlock = addHandle
        
        var height = CGFloat(list.count) * 56 + (isOwner ? 68 : 0)
        let maxHeight = kSCScreenHeight / 2 - 150
        if height > maxHeight {
            height = maxHeight
        }
        self.bounds = CGRect(x: 0, y: 0, width: kSCScreenWidth, height: height)
        if isOwner {
            self.tableView.tableFooterView = self.footerView
        }
        else {
            self.tableView.tableFooterView = nil
        }
    }

    func reloadData() {
        self.tableView.reloadData()
    }
    
    override func setupView() {
        self.addSubview(self.tableView)
        self.tableView.tableFooterView = self.footerView
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
