//
//  SCAddRoomViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/22.
//

import UIKit

class SCAddRoomViewController: SCBasicViewController {
    
    private var list: [SCAddRoomItemModel] = []
        
    private var addRoomBlock: ((String) -> Void)?

    private lazy var searchView: SCAddRoomSearchView = SCAddRoomSearchView { [weak self] in
        guard let `self` = self else { return }
        self.list.forEach { item in
            item.isSelected = false
        }
        self.collectionView.set(list: [self.list])
    }
    
    private lazy var tipLabel: UILabel = UILabel(text: tempLocalize("推荐房间名称"), textColor: "HomePage.FamilyListController.RoomListController.AddRoomController.tipLabel.textColor", font: "HomePage.FamilyListController.RoomListController.AddRoomController.tipLabel.font")
    
    private lazy var lineView: UIView = UIView(lineBackgroundColor: "HomePage.FamilyListController.RoomListController.AddRoomController.lineBackgroundColor")
    
    private lazy var collectionView: SCBasicCollectionView = {
        let layout = SCWaterFlowLayout()
        layout.delegate = self
        layout.flowLayoutStyle = .verticalEqualHeight
        
        let collectionView = SCBasicCollectionView(cellClass: SCAddRoomItemCell.self, cellIdendify: SCAddRoomItemCell.identify, layout: layout) { [weak self] indexPath in
            guard let `self` = self else { return }
            let model = self.list[indexPath.row]
            self.list.forEach { item in
                item.isSelected = false
            }
            model.isSelected = true
            self.searchView.text = model.name
            self.collectionView.set(list: [self.list])
        }
        return collectionView
    }()

    func set(addRoomHandle: ((String) -> Void)?) {
        self.addRoomBlock = addRoomHandle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension SCAddRoomViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("添加房间")
        self.addRightBarButtonItem(image: "Global.GeneralImage.saveImage", action: #selector(saveButtonAction))
    }
    
    override func setupView() {
        self.view.addSubview(self.searchView)
        self.view.addSubview(self.tipLabel)
        self.view.addSubview(self.lineView)
        self.view.addSubview(self.collectionView)
    }
    
    override func setupLayout() {
        let margin: CGFloat = 20
        self.searchView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(margin)
            make.height.equalTo(56)
            make.top.equalTo(self.view.snp.topMargin).offset(12)
        }
        self.tipLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(margin)
            make.top.equalTo(self.searchView.snp.bottom).offset(24)
        }
        self.lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(margin)
            make.height.equalTo(0.5)
            make.top.equalTo(self.tipLabel.snp.bottom).offset(12)
        }
        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.lineView.snp.bottom).offset(4)
        }
    }
    
    override func setupData() {
        let names = [tempLocalize("客厅"), tempLocalize("卧室"), tempLocalize("主卧"), tempLocalize("厨房"), tempLocalize("餐厅"), tempLocalize("卫生间"), tempLocalize("儿童房"), tempLocalize("办公室"), tempLocalize("书房"), tempLocalize("阳台"), tempLocalize("工作室"), tempLocalize("浴室"), tempLocalize("后院")]
        var items: [SCAddRoomItemModel] = []
        for name in names {
            let item = SCAddRoomItemModel()
            item.name = name
            items.append(item)
        }
        self.list = items
        self.collectionView.set(list: [self.list])
    }
}

extension SCAddRoomViewController {
    @objc private func saveButtonAction() {
        guard let name = self.searchView.text, name.count > 0 else {
            SCProgressHUD.showHUD(tempLocalize("房间名称不能为空"))
            return
        }
        self.addRoomBlock?(name)
        self.navigationController?.popViewController(animated: true)
    }
}

extension SCAddRoomViewController: SCWaterFlowLayoutDelegate {
    func waterFlowLayout(_ layout: SCWaterFlowLayout, sizeForHeaderViewInSection section: Int) -> CGSize {
        return .zero
    }
    
    func waterFlowLayout(_ layout: SCWaterFlowLayout, sizeForFooterViewInSection section: Int) -> CGSize {
        return .zero
    }
    
    func waterFlowLayout(_ layout: SCWaterFlowLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let model = self.list[indexPath.row]
        return CGSize(width: model.nameWidth, height: 30)
    }
    
    func edgeInset(inWaterFlowLayout layout: SCWaterFlowLayout) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
}
