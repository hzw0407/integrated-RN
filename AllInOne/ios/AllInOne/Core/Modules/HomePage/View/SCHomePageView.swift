//
//  SCHomePageView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/13.
//

import UIKit

class SCHomePageView: SCBasicView {
    
    var currentIndex: Int {
        return self.pageViewManager.currentIndex
    }
    
    var isScrollEnabled: Bool = false {
        didSet {
            for view in self.listViews {
                view.isScrollEnabled = self.isScrollEnabled
            }
        }
    }
    
    private var rooms: [SCNetResponseFamilyRoomModel] = []
    private var listViews: [SCHomePageDeviceListView] = []
    
    private var settingsBlock: (() -> Void)?
    private var didSelectItemBlock: ((Int) -> Void)?
    private var longPressBlock: ((Int, UILongPressGestureRecognizer) -> Void)?
    private var dragEndedBlock: (([SCNetResponseDeviceModel]) -> Void)?
    private var didScrollBlock: ((UIScrollView) -> Void)?
    private var didEndDraggingBlock: ((UIScrollView) -> Void)?

    private lazy var style: PageStyle = {
        let style = PageStyle()
        style.titleColor = ThemeColorPicker(keyPath: "HomePage.HomePageController.menuView.normalTitleColor").value() as! UIColor
        style.titleSelectedColor = ThemeColorPicker(keyPath: "HomePage.HomePageController.menuView.selectTitleColor").value() as! UIColor
        style.titleFont = ThemeFontPicker(stringLiteral: "HomePage.HomePageController.menuView.normalTitleFont").value() as! UIFont
//        style.titleSelectedFont = ThemeFontPicker(stringLiteral: "HomePage.HomePageController.menuView.selectTitleFont").value() as? UIFont
        style.titleViewBackgroundColor = ThemeColorPicker(keyPath: "HomePage.HomePageController.menuView.backgroundColor").value() as! UIColor
        style.contentViewBackgroundColor = ThemeColorPicker(keyPath: "HomePage.HomePageController.listView.backgroundColor").value() as! UIColor
        
        style.isTitleViewScrollEnabled = true
        style.isTitleScaleEnabled = true
        style.titleMaximumScaleFactor = 1.2
        
        return style
    }()
    
    private lazy var pageViewManager: PageViewManager = {
        let manager = PageViewManager(style: style, titles: [""], childViews: [UIView()])
        return manager
    }()
    
    private lazy var settingsButton: UIButton = UIButton(image: "HomePage.HomePageController.menuView.settingsImage", target: self, action: #selector(settingsButtonAction))
    
    convenience init(settingsHandle: (() -> Void)?, didSelectItemHandle: ((Int) -> Void)?, longPressHandle: ((Int, UILongPressGestureRecognizer) -> Void)?, dragEndedHandle: (([SCNetResponseDeviceModel]) -> Void)?, didScrollHandle: ((UIScrollView) -> Void)?) {
        self.init(frame: .zero)
        
        self.longPressBlock = longPressHandle
        self.settingsBlock = settingsHandle
        self.didSelectItemBlock = didSelectItemHandle
        self.dragEndedBlock = dragEndedHandle
        self.didScrollBlock = didScrollHandle
    }
    
    func reloadData(rooms: [SCNetResponseFamilyRoomModel]) {
        var needResetContentView: Bool = false
        if self.checkRoomsSortChangedStatus(sourceRooms: self.rooms, targetRooms: rooms) {
            needResetContentView = true
        }
        self.rooms = rooms
        var index = self.currentIndex
        if self.currentIndex >= rooms.count {
            index = 0
        }
        if needResetContentView {
            let (titles, listViews) = self.listTitlesAndViews()
            guard titles.count > 0 else { return }
            
            self.listViews = listViews
            self.pageViewManager.configure(titles: titles, childViews: listViews, style: self.style, currentIndex: index)
        }
        else {
            var titles: [String] = []
            for (i, room) in rooms.enumerated() {
                if i >= self.listViews.count { continue }
                let view = self.listViews[i]
                view.set(list: room.devices)
                view.isScrollEnabled = self.isScrollEnabled
                
                titles.append(room.roomName)
            }
            self.pageViewManager.titleView.configure(titles: titles, currentIndex: index)
        }
    }
    
    func reloadData(atIndex index: Int) {
        guard self.listViews.count > index, self.rooms.count > index else { return }
        let room = self.rooms[index]
        let listView = self.listViews[index]
        listView.isEditing = room.devices.first?.isEditing == true
        listView.set(list: room.devices)
        
        self.pageViewManager.disabled = listView.isEditing
    }
    
    func setContentOffset(offset: CGPoint) {
        guard self.listViews.count > self.currentIndex else { return }
        let listView = self.listViews[self.currentIndex]
        
        listView.setContentOffset(offset: offset)
    }
    
    func refreshScrollOffsetByEndDragging() {
        guard self.listViews.count > self.currentIndex else { return }
        let listView = self.listViews[self.currentIndex]
        listView.refreshScrollOffsetByEndDragging()
    }
}

extension SCHomePageView {
    override func setupView() {
        self.addSubview(self.pageViewManager.titleView)
        self.addSubview(self.pageViewManager.contentView)
        self.addSubview(self.settingsButton)
    }
    
    override func setupLayout() {
        self.pageViewManager.titleView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(self.settingsButton.snp.left).offset(-10)
            make.height.equalTo(60)
            make.top.equalToSuperview()
        }
        self.settingsButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(20)
            make.centerY.equalTo(self.pageViewManager.titleView.snp.centerY)
        }
        self.pageViewManager.contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.pageViewManager.titleView.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }
    
    private func listTitlesAndViews() -> ([String], [SCHomePageDeviceListView]) {
        var views: [SCHomePageDeviceListView] = []
        var titles: [String] = []
        for room in self.rooms {
            let view = SCHomePageDeviceListView { [weak self] index in
                self?.didSelectItemBlock?(index)
            } longPressHandle: { [weak self] index, gesture in
                self?.longPressBlock?(index, gesture)
            } dragEndedHandle: { [weak self] copyList in
                self?.dragEndedBlock?(copyList)
            } didScrollHandle: { [weak self] scrollView in
                self?.didScrollBlock?(scrollView)
            }
            view.set(list: room.devices)
            view.isScrollEnabled = self.isScrollEnabled
            views.append(view)
            
            titles.append(room.roomName)
        }
        return (titles, views)
    }
    
    private func checkRoomsSortChangedStatus(sourceRooms: [SCNetResponseFamilyRoomModel], targetRooms: [SCNetResponseFamilyRoomModel]) -> Bool {
        if sourceRooms.count != targetRooms.count { return true }
        for (i, source) in sourceRooms.enumerated() {
            let target = targetRooms[i]
            if source.id != target.id {
                return true
            }
        }
        return false
    }
}

extension SCHomePageView {
    @objc private func settingsButtonAction() {
        self.settingsBlock?()
    }
}

extension SCHomePageView {
    
}
