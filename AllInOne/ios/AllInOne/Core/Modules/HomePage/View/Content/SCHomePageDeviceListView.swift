//
//  SCHomePageDeviceListView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/17.
//

import UIKit
import sqlcipher

class SCHomePageDeviceListView: SCBasicView {

    var isEditing: Bool = false
    
    var isScrollEnabled: Bool = false {
        didSet {
            self.collectionView.isScrollEnabled = self.isScrollEnabled
        }
    }
    
    private var list: [SCNetResponseDeviceModel] = []
    
    private var longPressBlock: ((Int, UILongPressGestureRecognizer) -> Void)?
    private var didSelectItemBlock: ((Int) -> Void)?
    private var dragEndedBlock: (([SCNetResponseDeviceModel]) -> Void)?
    private var didScrollBlock: ((UIScrollView) -> Void)?
    private var didEndDraggingBlock: ((UIScrollView) -> Void)?
    
    private var dragingStartPoint: CGPoint = .zero
    private var dragingIndexPath: IndexPath?
    private var targetIndexPath: IndexPath?
    private lazy var dragingCell: SCHomePageDeviceCell = {
        let cell = SCHomePageDeviceCell(frame: CGRect(x: 0, y: 0, width: self.layout.itemSize.width, height: self.layout.itemSize.height))
        cell.isHidden = true
        return cell
    }()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        
        let horizontalMargin: CGFloat = 20 - 6
        let horizontalSpacing: CGFloat = 0
        let verticalMargin: CGFloat = 12 - 6
        let verticalSpacing: CGFloat = 0
        let itemWidth: CGFloat = (kSCScreenWidth - horizontalMargin * 2 - horizontalSpacing) / 2
        let itemHeight: CGFloat = 120 + 6 * 2
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.sectionInset = UIEdgeInsets(top: verticalMargin, left: horizontalMargin, bottom: verticalMargin, right: horizontalMargin)
        layout.minimumInteritemSpacing = horizontalSpacing
        layout.minimumLineSpacing = horizontalSpacing
        SCHomePageDeviceCell.itemSize = layout.itemSize
        return layout
    }()
    
    private lazy var collectionView: SCBasicCollectionView = {
        let view = SCBasicCollectionView(cellClass: SCHomePageDeviceCell.self, cellIdendify: SCHomePageDeviceCell.identify, layout: self.layout, cellDelegate: self) { [weak self] indexPath in
            self?.didSelectItemBlock?(indexPath.row)
        }
        view.add { [weak self] scrollView in
            self?.didScrollBlock?(scrollView)
        } didEndDraggingHandle: { _ in
            
        }
        return view
    }()
    
    private lazy var emptyView: SCHomePageDeviceEmptyView = SCHomePageDeviceEmptyView()
    
    convenience init(didSelectItemHandle: ((Int) -> Void)?, longPressHandle: ((_ index: Int, _ gesture: UILongPressGestureRecognizer) -> Void)?, dragEndedHandle: (([SCNetResponseDeviceModel]) -> Void)?, didScrollHandle: ((UIScrollView) -> Void)?) {
        self.init(frame: .zero)
        self.longPressBlock = longPressHandle
        self.didSelectItemBlock = didSelectItemHandle
        self.dragEndedBlock = dragEndedHandle
        self.didScrollBlock = didScrollHandle
    }

    func set(list: [SCNetResponseDeviceModel]) {
        self.list = list
        self.collectionView.set(list: [list])
        
        self.emptyView.isHidden = list.count > 0
    }
    
    func reloadData() {
        self.collectionView.reloadData()
    }
    
    func setContentOffset(offset: CGPoint) {
        self.collectionView.contentOffset = offset
    }
    
    func refreshScrollOffsetByEndDragging() {
        if self.collectionView.contentOffset.y >= self.collectionView.contentSize.height - self.collectionView.bounds.height {
            self.collectionView.setContentOffset(CGPoint(x: 0, y: self.collectionView.contentSize.height - self.collectionView.bounds.height), animated: true)
        }
    }
}

extension SCHomePageDeviceListView {
    override func setupView() {
        self.addSubview(self.collectionView)
        self.collectionView.addSubview(self.dragingCell)
        self.collectionView.addSubview(self.emptyView)
        self.emptyView.isHidden = true
    }
    
    override func setupLayout() {
        self.collectionView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        self.emptyView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalTo(self)
            make.bottom.equalToSuperview()
        }
    }
}

extension SCHomePageDeviceListView: SCHomePageDeviceCellDelegate {
    func cell(_ cell: SCHomePageDeviceCell, longPressGestureRecongnizer gesture: UILongPressGestureRecognizer) {
        guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
        if !self.isEditing {
            self.longPressBlock?(indexPath.row, gesture)
        }
        else {
            let point = gesture.location(in: self.collectionView)
            switch gesture.state {
            case .began:
                self.dragBegin(point: point, gesture: gesture)
                break
            case .changed:
                self.dragChanged(point: point)
                break
            case .ended:
                if !self.dragingCell.isHidden {
                    self.dragEnded(point: point)
                    self.dragEndedBlock?(self.list)
                }
                break
            default:
                break
            }
            return
        }
        
    }
    
    private func dragBegin(point: CGPoint, gesture: UILongPressGestureRecognizer) {
        self.dragingIndexPath = self.getIndexPath(point: point)
        guard self.dragingIndexPath != nil, let cell = self.collectionView.cellForItem(at: self.dragingIndexPath!) else { return }
        let model = self.list[self.dragingIndexPath!.row]
        self.dragingCell.set(model: model)
        self.collectionView.bringSubviewToFront(self.dragingCell)
        self.dragingCell.frame = cell.frame
        self.dragingCell.isHidden = false
        let cellPoint = gesture.location(in: cell)
        self.dragingStartPoint = CGPoint(x: cellPoint.x - self.dragingCell.bounds.width / 2, y: cellPoint.y - self.dragingCell.bounds.height / 2)
        cell.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.dragingCell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.dragingCell.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }
    
    private func dragChanged(point: CGPoint) {
        self.dragingCell.center = CGPoint(x: point.x - self.dragingStartPoint.x, y: point.y - self.dragingStartPoint.y)
        self.targetIndexPath = self.getIndexPath(point: point)
        if self.targetIndexPath != nil && self.dragingIndexPath != nil {
            if self.targetIndexPath != self.dragingIndexPath {
                self.collectionView.moveItem(at: self.dragingIndexPath!, to: self.targetIndexPath!)
                
                let item = self.list[self.dragingIndexPath!.row]
                self.list.remove(at: self.dragingIndexPath!.row)
                self.list.insert(item, at: self.targetIndexPath!.row)
                self.dragingIndexPath = self.targetIndexPath
            }
        }
    }
    
    private func dragEnded(point: CGPoint) {
        guard let indexPath = self.dragingIndexPath, let cell = self.collectionView.cellForItem(at: indexPath) else { return }
        let endFrame = cell.frame
        UIView.animate(withDuration: 0.3) {
            self.dragingCell.frame = endFrame
        } completion: { _ in
            self.dragingCell.isHidden = true
            cell.isHidden = false
        }
    }
    
    private func getIndexPath(point: CGPoint) -> IndexPath? {
        for indexPath in self.collectionView.indexPathsForVisibleItems {
            if let cell = self.collectionView.cellForItem(at: indexPath) {
                if cell.frame.contains(point) {
                    return indexPath
                }
            }
        }
        return nil
    }
}
