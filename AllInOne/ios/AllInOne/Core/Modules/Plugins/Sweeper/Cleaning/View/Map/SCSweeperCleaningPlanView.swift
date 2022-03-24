//
//  SCSweeperCleaningPlanView.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/2/15.
//

import UIKit

private let itemWidth: CGFloat = kSCScreenWidth - 20 * 2
private let itemSpace: CGFloat = 10
private let scrollViewWidth: CGFloat = itemWidth + 10

class SCSweeperCleaningPlanView: SCBasicView {
    
    var server: SCSweeperServer?

    var type: SCSweeperCleaningPlanType = .auto {
        didSet {
            var index: CGFloat = 0
            if self.type == .custom {
                index = 1
            }
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.scrollView.contentOffset = CGPoint(x: index * scrollViewWidth, y: 0)
            } completion: { _ in }

            self.pageControl.currentPage = Int(index)
        }
    }
    
    var customRooms: [SCSweeperCleaningCustomPlanRoomModel] = [] {
        didSet {
            self.customView.rooms = self.customRooms
        }
    }
    
    /// 是否折叠
    private var isFold: Bool = true
    
    private var changePlanTypeBlock: ((SCSweeperCleaningPlanType) -> Void)?
    
    /// 选择房间block
    private var selectCustomRoomBlock: ((SCSweeperCleaningCustomPlanRoomModel) -> Void)?
    /// 编辑房间block
    private var editCustomRoomBlock: ((SCSweeperCleaningCustomPlanRoomModel) -> Void)?
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    /// 滑动view
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.clipsToBounds = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    /// 自动模式view
    private lazy var autoView: SCSweeperCleaningAutoPlanView = SCSweeperCleaningAutoPlanView { [weak self] in
        guard let `self` = self else { return }
        self.isFold = !self.isFold
        if self.isFold {
            self.fold()
        }
        else {
            self.unfold()
        }
    }

    /// 自定义模式view
    private lazy var customView: SCSweeperCleaningCustomPlanView = SCSweeperCleaningCustomPlanView { [weak self] in
        guard let `self` = self else { return }
        self.isFold = !self.isFold
        if self.isFold {
            self.fold()
        }
        else {
            self.unfold()
        }
    } selectRoomHandler: { [weak self] room in
        self?.selectCustomRoomBlock?(room)
    } editRoomHandler: { [weak self] room in
        self?.editCustomRoomBlock?(room)
    }

    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.theme_pageIndicatorTintColor = "PluginSweeperTheme.CleaningViewController.MapView.PlanView.pageControl.pageIndicatorTintColor"
        pageControl.theme_currentPageIndicatorTintColor = "PluginSweeperTheme.CleaningViewController.MapView.PlanView.pageControl.currentPageIndicatorTintColor"
        pageControl.currentPage = 0
        pageControl.numberOfPages = 2
        if #available(iOS 14.0, *) {
            pageControl.backgroundStyle = .minimal
        } else {
            // Fallback on earlier versions
        }
        return pageControl
    }()
    
    convenience init(changePlanTypeHandler: ((SCSweeperCleaningPlanType) -> Void)?, selectCustomRoomHandler: ((SCSweeperCleaningCustomPlanRoomModel) -> Void)?, editCustomRoomHandler: ((SCSweeperCleaningCustomPlanRoomModel) -> Void)?) {
        self.init(frame: .zero)
        self.changePlanTypeBlock = changePlanTypeHandler
        
        self.selectCustomRoomBlock = selectCustomRoomHandler
        self.editCustomRoomBlock = editCustomRoomHandler
    }
}

extension SCSweeperCleaningPlanView {
    override func setupView() {
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.scrollView)
        self.scrollView.addSubview(self.autoView)
        self.scrollView.addSubview(self.customView)
        self.addSubview(self.pageControl)
    }
    
    override func setupLayout() {
        self.contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-30)
        }
        self.scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalTo(scrollViewWidth)
            make.centerX.equalToSuperview()
            make.height.equalTo(230)
        }
        
        self.autoView.frame = CGRect(x: itemSpace / 2, y: 0, width: itemWidth, height: 230)
        self.customView.frame = CGRect(x: (2 + 1) * itemSpace / 2 + itemWidth, y: 0, width: itemWidth, height: 230)
        self.scrollView.contentSize = CGSize(width: scrollViewWidth * 2, height: 230)
        
        self.pageControl.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(10)
        }
    }
}

extension SCSweeperCleaningPlanView {
    /// 折叠
    func fold() {
        UIView.animate(withDuration: 0.3) {
            var contentFrame = self.contentView.frame
            contentFrame.size.height = 40
            contentFrame.origin.y = 230 - 40
            self.contentView.frame = contentFrame
            self.contentView.snp.updateConstraints { make in
                make.height.equalTo(40)
            }
            self.autoView.fold()
            self.customView.fold()
        } completion: { _ in
            self.snp.updateConstraints { make in
                make.height.equalTo(40 + 30)
            }
        }
    }
    
    /// 展开
    func unfold() {
        self.snp.updateConstraints { make in
            make.height.equalTo(230 + 30)
        }
        
        var contentFrame = self.contentView.frame
        contentFrame.size.height = 40
        contentFrame.origin.y = 230 - 40
        self.contentView.frame = contentFrame
        UIView.animate(withDuration: 0.3) {
            var contentFrame = self.contentView.frame
            contentFrame.size.height = 230
            contentFrame.origin.y = 0
            
            self.contentView.frame = contentFrame
            
            self.contentView.snp.updateConstraints { make in
                make.height.equalTo(230)
            }
            self.autoView.unfold()
            self.customView.unfold()
        } completion: { _ in
        }
    }
}

extension SCSweeperCleaningPlanView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let index = Int(offsetX / scrollViewWidth)
        self.pageControl.currentPage = index
        
        var type: SCSweeperCleaningPlanType = .auto
        if index == 1 {
            type = .custom
        }
        if type != self.type {
            self.changePlanTypeBlock?(type)
        }
    }
}
