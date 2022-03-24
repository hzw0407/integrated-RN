//
//  SCAddDeviceProductListView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/14.
//

import UIKit

class SCAddDeviceProductListView: SCBasicView {
    
    private var didSelectItemBlock: ((SCNetResponseProductModel) -> Void)?

    private var parents: [SCNetResponseProductTypeParentModel] = []
    private var middles: [SCNetResponseProductTypeMiddleModel] = []
    private var items: [[SCNetResponseProductModel]] = []
    
    private var currentParentIndex: Int = 0
    
    private lazy var parentTableView: SCBasicTableView = SCBasicTableView(cellClass: SCAddDeviceProductParentCell.self, cellIdendify: SCAddDeviceProductParentCell.identify, rowHeight: nil) { [weak self] indexPath in
        guard let `self` = self else { return }
        self.currentParentIndex = indexPath.row
        self.reloadParentData()
        self.reloadChildData()
    }
    
    private lazy var childListCollectionView: SCBasicCollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = kSCScreenWidth - 116 - 20
        let columns: CGFloat = 3
        let itemWidth: CGFloat = CGFloat(floorf(Float(width / columns)))
        let itemHeight: CGFloat = 113
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        let collectionView = SCBasicCollectionView(cellClass: SCAddDeviceProductItemCell.self, cellIdendify: SCAddDeviceProductItemCell.identify, layout: layout) { [weak self] indexPath in
            guard let `self` = self, indexPath.section < self.items.count, indexPath.row < self.items[indexPath.section].count else { return }
            let item = self.items[indexPath.section][indexPath.row]
            self.didSelectItemBlock?(item)
        }
        
        collectionView.register(header: SCAddDeviceProductChildHeaderView.self, idendify: SCAddDeviceProductChildHeaderView.identify, size: CGSize(width: width, height: 56))
        collectionView.register(footer: SCBasicCollectionReusableView.self, idendify: SCBasicCollectionReusableView.identify, size: CGSize(width: width, height: 20))
        
        return collectionView
    }()
    
    init(didSelectItemHandle: ((SCNetResponseProductModel) -> Void)?) {
        super.init(frame: .zero)
        
        self.didSelectItemBlock = didSelectItemHandle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reload(parents: [SCNetResponseProductTypeParentModel]) {
        self.parents = parents
        self.reloadParentData()
        self.reloadChildData()
    }
    
    private func reloadParentData() {
        for (i, parent) in self.parents.enumerated() {
            parent.isSelected = i == self.currentParentIndex
        }
        self.parentTableView.set(list: [self.parents])
    }
    
    private func reloadChildData() {
        guard self.parents.count > self.currentParentIndex else { return }
        var items: [[SCNetResponseProductModel]] = []
        let parent = self.parents[self.currentParentIndex]
        self.middles = parent.items
        for middle in self.middles {
            items.append(middle.items)
        }
        self.items = items
        self.childListCollectionView.set(list: items, headerList: middles)
        if self.childListCollectionView.contentOffset.y > 0 {
            self.childListCollectionView.scrollToItem(at: IndexPath(), at: .top, animated: false)
        }
    }
}

extension SCAddDeviceProductListView {
    override func setupView() {
        self.addSubview(self.parentTableView)
        self.addSubview(self.childListCollectionView)
    }
    override func setupLayout() {
        self.parentTableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(110)
        }
        self.childListCollectionView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(CGFloat(Int(kSCScreenWidth - 20 - 110 - 6) / 3) * 3)
        }
    }
}
