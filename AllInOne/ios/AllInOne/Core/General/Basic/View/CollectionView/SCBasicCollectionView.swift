//
//  SCBasicCollectionView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/14.
//

import UIKit

class SCBasicCollectionView: UICollectionView {

    private var list: [[Any]] = []
    private var headerList: [Any] = []
    private var cellIdentify: String = ""
    private var headerIdentify: String = ""
    private var footerIdentify: String = ""
    private var cellDelegate: AnyObject?
    
    private var didSelectBlock: ((IndexPath) -> Void)?
    private var didScrollBlock: ((UIScrollView) -> Void)?
    private var didEndDraggingBlock: ((UIScrollView) -> Void)?
    
    private var layout: UICollectionViewLayout = UICollectionViewLayout()
    
    private var flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    private var itemSizes: [[CGSize]]?

    init(cellClass: AnyClass, cellIdendify: String, layout: UICollectionViewLayout, cellDelegate: AnyObject? = nil, didSelectHandle: ((IndexPath) -> Void)? = nil) {
        super.init(frame: .zero, collectionViewLayout: layout)
        self.backgroundColor = .clear
        self.layout = layout
        if let layout = layout as? UICollectionViewFlowLayout {
            self.flowLayout = layout
        }
        self.dataSource = self
        self.delegate = self
        
        self.register(cellClass, forCellWithReuseIdentifier: cellIdendify)
        
        self.cellIdentify = cellIdendify
        self.didSelectBlock = didSelectHandle
        self.cellDelegate = cellDelegate
    }
    
    func register(header aClass: AnyClass, idendify: String, size: CGSize) {
        self.register(aClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: idendify)
        self.headerIdentify = idendify
        self.flowLayout.headerReferenceSize = size
    }
    
    func register(footer aClass: AnyClass, idendify: String, size: CGSize) {
        self.register(aClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: idendify)
        self.footerIdentify = idendify
        self.flowLayout.footerReferenceSize = size
    }
    
    func add(didScrollHandle: ((UIScrollView) -> Void)? = nil, didEndDraggingHandle: ((UIScrollView) -> Void)? = nil) {
        self.didScrollBlock = didScrollHandle
        self.didEndDraggingBlock = didEndDraggingHandle
    }
    
    func set(list: [[Any]], headerList: [Any] = []) {
        self.list = list
        self.headerList = headerList
        self.reloadData()
    }
    
    func set(itemSizes: [[CGSize]]?) {
        self.itemSizes = itemSizes
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SCBasicCollectionView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.list[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentify, for: indexPath)
        let model = self.list[indexPath.section][indexPath.row]
        cell.set(model: model)
        cell.set(delegate: self.cellDelegate)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.headerIdentify, for: indexPath)
            if self.headerList.count > indexPath.section {
                let model = self.headerList[indexPath.section]
                view.set(model: model)
            }
            return view
        }
        else if kind == UICollectionView.elementKindSectionFooter {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.footerIdentify, for: indexPath)
            return view
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.didSelectBlock?(indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.didScrollBlock?(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.didEndDraggingBlock?(scrollView)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if self.itemSizes != nil {
//            return self.itemSizes![indexPath.section][indexPath.row]
//        }
//        else {
//            return self.layout.itemSize
//        }
//    }
}
