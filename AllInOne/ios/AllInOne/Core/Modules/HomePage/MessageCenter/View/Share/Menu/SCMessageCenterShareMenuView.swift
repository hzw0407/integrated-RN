//
//  SCMessageCenterShareMenuView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/24.
//

import UIKit

class SCMessageCenterShareMenuView: SCBasicView {

    private var list: [SCMessageCenterShareMenuItemModel] = []
    
    private var didSelectBlock: ((SCMessageCenterShareMessageType) -> Void)?
    
    private lazy var collectionView: SCBasicCollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.estimatedItemSize = CGSize(width: 40, height: 52)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView = SCBasicCollectionView(cellClass: SCMessageCenterShareMenuCell.self, cellIdendify: SCMessageCenterShareMenuCell.identify, layout: layout) { [weak self] indexPath in
            guard let `self` = self else { return }
            self.list.forEach { item in
                item.isSelected = false
            }
            let item = self.list[indexPath.row]
            item.isSelected = true
            self.collectionView.reloadData()
            self.didSelectBlock?(item.type)
        }
        return collectionView
    }()

    convenience init(frame: CGRect, didSelectHandle: ((SCMessageCenterShareMessageType) -> Void)?) {
        self.init(frame: frame)
        self.didSelectBlock = didSelectHandle
    }
    
    func set(list: [SCMessageCenterShareMenuItemModel]) {
        self.list = list
        self.collectionView.set(list: [list])
    }
}

extension SCMessageCenterShareMenuView {
    override func setupView() {
        self.addSubview(self.collectionView)
    }
    
    override func setupLayout() {
        self.collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
    }
}


