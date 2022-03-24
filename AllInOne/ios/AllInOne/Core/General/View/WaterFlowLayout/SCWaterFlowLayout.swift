//
//  SCWaterFlowLayout.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/22.
//

import UIKit

/**
 布局样式
 */
enum SCWaterFlowLayoutStyle: Int {
    /// 竖向瀑布流 item等宽不等高
    case verticalEqualWidth = 0
    /// 水平瀑布流 item等高不等宽 不支持头脚视图
    case horizontalEqualHeight
    /// 竖向瀑布流 item等高不等宽
    case verticalEqualHeight
    /// 特为国务院客户端原创栏目滑块样式定制-水平栅格布局
    case horizontalGrid
    /// 线性布局
    case lineWaterFlow
}

@objc protocol SCWaterFlowLayoutDelegate {
    /**
     返回item的大小
     注意：根据当前的瀑布流样式需知的事项：
     当样式为verticalEqualWidth 传入的size.width无效 ，所以可以是任意值，因为内部会根据样式自己计算布局
     horizontalEqualHeight 传入的size.height无效 ，所以可以是任意值 ，因为内部会根据样式自己计算布局
     horizontalGrid   传入的size宽高都有效， 此时返回列数、行数的代理方法无效，
     verticalEqualHeight 传入的size宽高都有效， 此时返回列数、行数的代理方法无效
     */
    func waterFlowLayout(_ layout: SCWaterFlowLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    
    /** 头视图Size */
    func waterFlowLayout(_ layout: SCWaterFlowLayout, sizeForHeaderViewInSection section: Int) -> CGSize
    
    /** 脚视图Size */
    func waterFlowLayout(_ layout: SCWaterFlowLayout, sizeForFooterViewInSection section: Int) -> CGSize
    
    /// 以下为可选
    /** 列数*/
    @objc optional func columnCount(inWaterFlowLayout layout: SCWaterFlowLayout) -> Int
    
    /** 行数*/
    @objc optional func rowCount(inWaterFlowLayout layout: SCWaterFlowLayout) -> Int
    
    /** 列间距*/
    @objc optional func columnMargin(inWaterFlowLayout layout: SCWaterFlowLayout) -> CGFloat
    
    /** 行间距*/
    @objc optional func rowMargin(inWaterFlowLayout layout: SCWaterFlowLayout) -> CGFloat
    
    /** 边缘之间的间距*/
    @objc optional func edgeInset(inWaterFlowLayout layout: SCWaterFlowLayout) -> UIEdgeInsets
}

/** 默认的列数*/
fileprivate let SCDefaultColumnCount = 3
/** 默认的行数*/
fileprivate let SCDefaultRowCount = 5

/** 每一列之间的间距*/
fileprivate let SCDefaultColumnMargin: CGFloat = 10
/** 每一行之间的间距*/
fileprivate let SCDefaultRowMargin: CGFloat = 10
/** 边缘之间的间距*/
fileprivate let SCDefaultEdgeInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

class SCWaterFlowLayout: UICollectionViewLayout {
    // MARK: - public variable
    /// 代理
    weak var delegate: SCWaterFlowLayoutDelegate?
    /// 样式
    var flowLayoutStyle: SCWaterFlowLayoutStyle = .horizontalEqualHeight
    
    // MARK: - private variable
    /// 存放所有cell的布局属性
    private var attrsArray = [UICollectionViewLayoutAttributes]()
    /// 存放每一列的最大y值
    private var columnHeights = [CGFloat]()
    /// 存放每一行的最大x值
    private var rowWidths = [CGFloat]()
    /// 内容的高度
    private var maxColumnHeight: CGFloat = 0
    /// 内容的宽度
    private var maxRowWidth: CGFloat = 0
    
    
}

// MARK: - private function
extension SCWaterFlowLayout {
    // MARK: - 每一列之间的间距
    private func columnMargin() -> CGFloat {
        guard let margin = self.delegate?.columnMargin?(inWaterFlowLayout: self) else {
            return SCDefaultColumnMargin
        }
        return margin
    }
    
    // MARK: - 每一行之间的间距
    private func rowMargin() -> CGFloat {
        guard let margin = self.delegate?.rowMargin?(inWaterFlowLayout: self) else {
            return SCDefaultRowMargin
        }
        return margin
    }
    
    // MARK: - 列数
    private func columnCount() -> Int {
        guard let count = self.delegate?.columnCount?(inWaterFlowLayout: self) else {
            return SCDefaultColumnCount
        }
        return count
    }
    
    // MARK: - 行数
    private func rowCount() -> Int {
        guard let count = self.delegate?.rowCount?(inWaterFlowLayout: self) else {
            return SCDefaultRowCount
        }
        return count
    }
    
    // MARK: - 边缘之间的间距
    private func edgeInsets() -> UIEdgeInsets {
        guard let inset = self.delegate?.edgeInset?(inWaterFlowLayout: self) else {
            return SCDefaultEdgeInset
        }
        return inset
    }
}

// MARK: - override
extension SCWaterFlowLayout {
    // MARK: - 初始化 生成每个视图的布局信息
    override func prepare() {
        super.prepare()
        
        if self.flowLayoutStyle == .verticalEqualWidth {
            //清除以前计算的所有高度
            self.maxColumnHeight = 0
            self.columnHeights.removeAll()
            
            for _ in 0..<self.columnCount() {
                self.columnHeights.append(self.edgeInsets().top)
            }
        } else if self.flowLayoutStyle == .horizontalEqualHeight {
            //清除以前计算的所有宽度
            self.maxRowWidth = 0
            self.rowWidths.removeAll()
            for _ in 0..<self.rowCount() {
                self.rowWidths.append(self.edgeInsets().left)
            }
        } else if self.flowLayoutStyle == .verticalEqualHeight || self.flowLayoutStyle == .lineWaterFlow {
            //记录最后一个的内容的横坐标和纵坐标
            self.maxColumnHeight = 0
            self.columnHeights.removeAll()
            self.columnHeights.append(self.edgeInsets().top)
            
            self.maxRowWidth = 0
            self.rowWidths.removeAll()
            self.rowWidths.append(self.edgeInsets().left)
        } else if self.flowLayoutStyle == .horizontalGrid {
            //记录最后一个的内容的横坐标和纵坐标
            self.maxColumnHeight = 0
            self.maxRowWidth = 0
            
            self.rowWidths.removeAll()
            for _ in 0..<2 {
                self.rowWidths.append(self.edgeInsets().left)
            }
        }
        
        //清除之前数组
        self.attrsArray.removeAll()
        
        //开始创建每一组cell的布局属性
        let sectionCount: Int = self.collectionView?.numberOfSections ?? 0
        for section in 0..<sectionCount {
            //获取每一组头视图header的UICollectionViewLayoutAttributes
            if let size = self.delegate?.waterFlowLayout(self, sizeForHeaderViewInSection: section), size != .zero {
                let headerAttrs = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: section))
                self.attrsArray.append(headerAttrs!)
            }
            
            //开始创建组内的每一个cell的布局属性
            let rowCount = self.collectionView?.numberOfItems(inSection: section) ?? 0
            for row in 0..<rowCount {
                let indexPath = IndexPath(row: row, section: section)
                let attrs = self.layoutAttributesForItem(at: indexPath)!
                self.attrsArray.append(attrs)
            }
            
            //获取每一组脚视图footer的UICollectionViewLayoutAttributes
            if let size = self.delegate?.waterFlowLayout(self, sizeForFooterViewInSection: section), size != .zero {
                let footerAttrs = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: IndexPath(row: 0, section: section))!
                self.attrsArray.append(footerAttrs)
            }
        }
    }
    
    // MARK: - 决定一段区域所有cell和头尾视图的布局属性
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.attrsArray
    }
    
    // MARK: - 返回indexPath位置cell对应的布局属性
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //设置布局属性
        let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        switch self.flowLayoutStyle {
        case .verticalEqualWidth:
            attrs.frame = self.itemFrame(ofVerticalEqualWidthWaterFlowAtIndexPath: indexPath)
            break
        case .horizontalEqualHeight:
            attrs.frame = self.itemFrame(ofHorizontalEqualHeightWaterFlowAtIndexPath: indexPath)
            break
        case .verticalEqualHeight:
            attrs.frame = self.itemFrame(ofVerticalEqualHeightWaterFlowAtIndexPath: indexPath)
            break
        case .lineWaterFlow:
            attrs.frame = self.itemFrame(ofHorizontalLineWaterFlowAtIndexPath: indexPath)
            // 计算中心点距离
            let delta: CGFloat = abs(attrs.center.x - (self.collectionView?.contentOffset.x ?? 0) - (self.collectionView?.frame.size.width ?? 0))
            //计算比例
            let scale: CGFloat = 1 - delta / ((self.collectionView?.frame.size.width ?? 0.1) * 0.5) * 0.25
            attrs.transform = CGAffineTransform(scaleX: scale, y: scale)
            break
        case .horizontalGrid:
            attrs.frame = self.itemFrame(ofHorizontalGridWaterFlowAtIndexPath: indexPath)
        }
        
        return attrs
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attri: UICollectionViewLayoutAttributes!
        if elementKind == UICollectionView.elementKindSectionHeader {
            //头视图
            attri = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
            attri.frame = self.headerViewFrame(ofVerticalWaterFlowAtIndexPath: indexPath)
        } else {
            //脚视图
            attri = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
            attri.frame = self.footerViewFrame(ofVerticalWaterFlowAtIndexPath: indexPath)
        }
        
        return attri
    }
}

extension SCWaterFlowLayout {
    override var collectionViewContentSize: CGSize {
        switch self.flowLayoutStyle {
        case .verticalEqualWidth:
            return CGSize(width: 0, height: self.maxColumnHeight + self.edgeInsets().bottom)
        case .horizontalEqualHeight:
            return CGSize(width: self.maxRowWidth + self.edgeInsets().right, height: 0)
        case .verticalEqualHeight:
            return CGSize(width: 0, height: self.maxColumnHeight + self.edgeInsets().bottom)
        case .lineWaterFlow:
            return CGSize(width: self.maxRowWidth + self.edgeInsets().right, height: 0)
        case .horizontalGrid:
            return CGSize(width: self.maxRowWidth + self.edgeInsets().right, height: self.collectionView?.frame.size.height ?? 0)
        }
    }
}

// MARK: - 计算item frame
extension SCWaterFlowLayout {
    // MARK: - 竖向瀑布流 item等宽不等高
    private func itemFrame(ofVerticalEqualWidthWaterFlowAtIndexPath indexPath: IndexPath) -> CGRect {
        //collectionView的宽度
        let collectionWidth: CGFloat = self.collectionView?.frame.size.width ?? 0
        //设置布局属性item的frame
        let width = (collectionWidth - self.edgeInsets().left - self.edgeInsets().right - self.columnMargin() * CGFloat(self.columnCount() - 1)) / CGFloat(self.columnCount())
        let height = self.delegate?.waterFlowLayout(self, sizeForItemAtIndexPath: indexPath).height ?? 0
        
        //找出高度最短的那一列
        var destColumn: Int = 0
        var minColumnHeight: CGFloat = self.columnHeights.first ?? 0
        for i in 1..<self.columnCount() {
            //取出第i列
            let columnHeight = self.columnHeights[i]
            if minColumnHeight > columnHeight {
                minColumnHeight = columnHeight
                destColumn = i
            }
        }
        
        let x = self.edgeInsets().left + CGFloat(destColumn) * (width + self.columnMargin())
        var y = minColumnHeight
        if y != self.edgeInsets().top {
            y += self.rowMargin()
        }
        
        //更新最短那列的高度
        let columnHeight = CGRect(x: x, y: y, width: width, height: height).maxY
        self.columnHeights[destColumn] = columnHeight
        //记录内容的高度
        if self.maxColumnHeight < columnHeight {
            self.maxColumnHeight = columnHeight
        }
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    // MARK: - 竖向瀑布流 item等高不等宽
    private func itemFrame(ofVerticalEqualHeightWaterFlowAtIndexPath indexPath: IndexPath) -> CGRect {
        //collectionView的宽度
        let collectionWidth: CGFloat = self.collectionView?.frame.size.width ?? 0
        
        var headerViewSize: CGSize = .zero
        if let size = self.delegate?.waterFlowLayout(self, sizeForHeaderViewInSection: indexPath.section), size != .zero {
            headerViewSize = size
        }
        
        let width: CGFloat = self.delegate?.waterFlowLayout(self, sizeForItemAtIndexPath: indexPath).width ?? 0
        let height: CGFloat = self.delegate?.waterFlowLayout(self, sizeForItemAtIndexPath: indexPath).height ?? 0
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        //记录最后一行的内容的横坐标和纵坐标
        if collectionWidth - (self.rowWidths.first ?? 0) > width + self.edgeInsets().right {
            x = (self.rowWidths.first ?? 0) == self.edgeInsets().left ? self.edgeInsets().left : (self.rowWidths.first ?? 0) + self.columnMargin()
            if (self.columnHeights.first ?? 0) == self.edgeInsets().top {
                y = self.edgeInsets().top
            }
            else if (self.columnHeights.first ?? 0) == self.edgeInsets().top + headerViewSize.height {
                y = self.edgeInsets().top + headerViewSize.height + self.rowMargin()
            } else {
                y = (self.columnHeights.first ?? 0) - height
            }
            self.rowWidths[0] = x + width
            if (self.columnHeights.first ?? 0) == self.edgeInsets().top || (self.columnHeights.first ?? 0) == self.edgeInsets().top + headerViewSize.height {
                self.columnHeights[0] = y + height
            }
        } else if collectionWidth - (self.rowWidths.first ?? 0) == width + self.edgeInsets().right {
            //换行
            x = self.edgeInsets().left
            y = (self.columnHeights.first ?? 0) + self.rowMargin()
            self.rowWidths[0] = x + width
            self.columnHeights[0] = y + height
        } else {
            //换行
            x = self.edgeInsets().left
            y = (self.columnHeights.first ?? 0) + self.rowMargin()
            self.rowWidths[0] = x + width
            self.columnHeights[0] = y + height
        }
        
        //记录内容的高度
        self.maxColumnHeight = self.columnHeights.first ?? 0
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    // MARK: - 水平瀑布流 item等高不等宽
    private func itemFrame(ofHorizontalEqualHeightWaterFlowAtIndexPath indexPath: IndexPath) -> CGRect {
        //collectionView的高度
        let collectionHeight: CGFloat = self.collectionView?.frame.size.height ?? 0
        //设置布局属性item的frame
        let height: CGFloat = (collectionHeight - self.edgeInsets().top - self.edgeInsets().bottom - self.rowMargin() * CGFloat(self.rowCount() - 1)) / CGFloat(self.rowCount())
        let width = self.delegate?.waterFlowLayout(self, sizeForItemAtIndexPath: indexPath).width ?? 0
        
        //找出宽度最短的那一行
        var destRow = 0
        var minRowWidth = self.rowWidths.first ?? 0
        for i in 1..<self.rowWidths.count {
            //取出第i行
            let rowWidth = self.rowWidths[i]
            if minRowWidth > rowWidth {
                minRowWidth = rowWidth
                destRow = i
            }
        }
        
        let y = self.edgeInsets().top + CGFloat(destRow) * (height + self.rowMargin())
        var x = minRowWidth
        if x != self.edgeInsets().left {
            x += self.columnMargin()
        }
        
        //更新最短那行的宽度
        self.rowWidths[destRow] = CGRect(x: x, y: y, width: width, height: height).maxX
        //记录内容的宽度
        let rowWidth = self.rowWidths[destRow]
        if self.maxRowWidth < rowWidth {
            self.maxRowWidth = rowWidth
        }
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    // MARK: - 水平栅格布局
    private func itemFrame(ofHorizontalGridWaterFlowAtIndexPath indexPath: IndexPath) -> CGRect {
        return .zero
    }
    
    // MARK: - 线性布局
    private func itemFrame(ofHorizontalLineWaterFlowAtIndexPath indexPath: IndexPath) -> CGRect {
        return .zero
    }
    
    // MARK: - 返回头视图的布局frame
    private func headerViewFrame(ofVerticalWaterFlowAtIndexPath indexPath: IndexPath) -> CGRect {
        var size: CGSize = .zero
        if let tmp = self.delegate?.waterFlowLayout(self, sizeForHeaderViewInSection: indexPath.section), tmp != .zero {
            size = tmp
        }
        
        switch self.flowLayoutStyle {
        case .verticalEqualWidth:
            let x: CGFloat = 0
            var y: CGFloat = self.maxColumnHeight == 0 ? self.edgeInsets().top : self.maxColumnHeight
            let footerSize = self.delegate?.waterFlowLayout(self, sizeForFooterViewInSection: indexPath.section)
            if footerSize == nil || footerSize!.height == 0 {
                y = self.maxColumnHeight == 0 ? self.edgeInsets().top : self.maxColumnHeight + self.rowMargin()
            }
            self.maxColumnHeight = y + size.height
            
            self.columnHeights.removeAll()
            for _ in 0..<self.columnCount() {
                self.columnHeights.append(self.maxColumnHeight)
            }
            
            return CGRect(x: x, y: y, width: self.collectionView?.frame.size.width ?? 0, height: size.height)
        case .verticalEqualHeight:
            let x: CGFloat = 0
            var y: CGFloat = self.maxColumnHeight == 0 ? self.edgeInsets().top : self.maxColumnHeight
            let footerSize = self.delegate?.waterFlowLayout(self, sizeForFooterViewInSection: indexPath.section)
            if footerSize == nil || footerSize!.height == 0 {
                y = self.maxColumnHeight == 0 ? self.edgeInsets().top : self.maxColumnHeight + self.rowMargin()
            }
            
            self.maxColumnHeight = y + size.height
            
            self.rowWidths[0] = self.collectionView?.frame.size.width ?? 0
            self.columnHeights[0] = self.maxColumnHeight
            
            return CGRect(x: x, y: y, width: self.collectionView?.frame.size.width ?? 0, height: size.height)
        default:
            break
        }
        
        return .zero
    }
    
    // MARK: - 返回脚视图的布局frame
    private func footerViewFrame(ofVerticalWaterFlowAtIndexPath indexPath: IndexPath) -> CGRect {
        var size: CGSize = .zero
        if let tmp = self.delegate?.waterFlowLayout(self, sizeForFooterViewInSection: indexPath.section), tmp != .zero {
            size = tmp
        }
        
        switch self.flowLayoutStyle {
        case .verticalEqualWidth:
            let x: CGFloat = 0
            let y: CGFloat = size.height == 0 ? self.maxColumnHeight : self.maxColumnHeight + self.rowMargin()
            
            self.maxColumnHeight = y + size.height
            
            self.columnHeights.removeAll()
            for _ in 0..<self.columnCount() {
                self.columnHeights.append(self.maxColumnHeight)
            }
            
            return CGRect(x: x, y: y, width: self.collectionView?.frame.size.width ?? 0, height: size.height)
        case .verticalEqualHeight:
            let x: CGFloat = 0
            let y: CGFloat = size.height == 0 ? self.maxColumnHeight : self.maxColumnHeight + self.rowMargin()
            
            self.maxColumnHeight = y + size.height
            
            self.rowWidths[0] = self.collectionView?.frame.size.width ?? 0
            self.columnHeights[0] = self.maxColumnHeight
            
            return CGRect(x: x, y: y, width: self.collectionView?.frame.size.width ?? 0, height: size.height)
        default:
            return .zero
        }
    }
}
