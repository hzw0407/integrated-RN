//
//  SCMessageCenterMenuView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/24.
//

import UIKit

class SCMessageCenterMenuView: SCBasicView {
    
    private var list: [SCMessageCenterMenuItemModel] = []
    
    private var didSelectBlock: ((SCMessageCenterMessageType) -> Void)?
    
    private lazy var collectionView: SCBasicCollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.estimatedItemSize = CGSize(width: 40, height: 44)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView = SCBasicCollectionView(cellClass: SCMessageCenterMenuItemCell.self, cellIdendify: SCMessageCenterMenuItemCell.identify, layout: layout) { [weak self] indexPath in
            guard let `self` = self else { return }
            self.list.forEach { item in
                item.isSelected = false
            }
            let item = self.list[indexPath.row]
            item.isSelected = true
            self.reloadData()
            self.didSelectBlock?(item.type)
        }
        return collectionView
    }()

    private lazy var lineView: UIView = UIView(backgroundColor: "HomePage.MessageCenterController.MenuView.lineBackgroundColor")
    
    convenience init(didSelectHandle: ((SCMessageCenterMessageType) -> Void)?) {
        self.init(frame: .zero)
        self.didSelectBlock = didSelectHandle
    }
    
    func set(list: [SCMessageCenterMenuItemModel]) {
        self.list = list
        self.collectionView.set(list: [list])
    }
    
    func reloadData() {
        self.collectionView.reloadData()
    }
}

extension SCMessageCenterMenuView {
    override func setupView() {
        self.addSubview(self.collectionView)
        self.addSubview(self.lineView)
    }
    
    override func setupLayout() {
        self.collectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(24 - 6)
            make.left.right.equalToSuperview().inset(20 - 6)
        }
        self.lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}
