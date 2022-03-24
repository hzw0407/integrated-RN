//
//  SCHomePageAlertFamilyListView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/20.
//

import UIKit

class SCHomePageAlertFamilyListItem {
    var family: SCNetResponseFamilyModel?
    var name: String {
        if let family = self.family {
            return family.name
        }
        else {
            return tempLocalize("家庭管理")
        }
    }
    var isSelected: Bool = false
    var isFamilyManager: Bool {
        return self.family == nil
    }
    var hasLineView: Bool = false
}

class SCHomePageAlertFamilyListView: SCBasicView {
    
    private static let shared = SCHomePageAlertFamilyListView()
    
    private var list: [SCHomePageAlertFamilyListItem] = []
    
    private var didSelectBlock: ((SCHomePageAlertFamilyListItem) -> Void)?
    private var height: CGFloat = 0
    
    private var topOffsetY: CGFloat = kSCStatusBarHeight + 72

    private lazy var backgroundView: UIButton = {
        let btn = UIButton()
        btn.theme_backgroundColor = "HomePage.HomePageController.AlertFamilyListView.backgroundColor"
        btn.addTarget(self, action: #selector(backgroundButtonAction), for: .touchUpInside)
        return btn
    }()
//    private lazy var backgroundView: UIView = {
//        let view = UIView()
//        view.theme_backgroundColor = "HomePage.HomePageController.AlertFamilyListView.backgroundColor"
//        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapGestureAction))
//        tap.delegate = self
//        view.addGestureRecognizer(tap)
//        return view
//    }()
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCHomePageAlertFamilyListCell.self, cellIdendify: SCHomePageAlertFamilyListCell.identify, rowHeight: 52, cellDelegate: nil) { [weak self] indexPath in
            guard let `self` = self else { return }
            SCHomePageAlertFamilyListView.hide()
            let item = self.list[indexPath.row]
            self.didSelectBlock?(item)
        }
        tableView.layer.cornerRadius = 12
        tableView.layer.masksToBounds = true
        tableView.theme_backgroundColor = "HomePage.HomePageController.AlertFamilyListView.ItemCell.backgroundColor"
        return tableView
    }()
    
    class func show(list: [SCHomePageAlertFamilyListItem], topOffsetY: CGFloat = kSCStatusBarHeight + 72, leftOffset: CGFloat? = nil, width: CGFloat? = nil, didSelectHandle: ((SCHomePageAlertFamilyListItem) -> Void)?) {
        let `self` = SCHomePageAlertFamilyListView.shared
        self.topOffsetY = topOffsetY
        self.didSelectBlock = didSelectHandle
        self.list = list
        self.tableView.set(list: [list])
        var height = CGFloat(self.list.count * 52)
        let maxHeight = kSCScreenHeight / 2 - self.topOffsetY
        if height > maxHeight {
            height = maxHeight
        }
        var frame = self.tableView.frame
        frame.origin.y = self.topOffsetY
        if width != nil {
            frame.size.width = width!
        }
        if leftOffset != nil {
            frame.origin.x = leftOffset!
        }
        self.tableView.frame = frame
        
        frame.size.height = height
        kGetNormalWindow()?.addSubview(self)
        UIView.animate(withDuration: 0.3) {
            self.tableView.frame = frame
        } completion: { _ in
            
        }
    }
    
    class func hide() {
        let `self` = SCHomePageAlertFamilyListView.shared
        var frame = self.tableView.frame
        frame.size.height = 0
        UIView.animate(withDuration: 0.3) {
            self.tableView.frame = frame
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}

extension SCHomePageAlertFamilyListView {
    override func setupView() {
        self.addSubview(self.backgroundView)
        self.addSubview(self.tableView)
    }
    
    override func setupLayout() {
        self.frame = UIScreen.main.bounds
        let width = self.frame.width / 2 - 20
        self.tableView.frame = CGRect(x: 20, y: self.topOffsetY, width: width, height: 0)
        self.backgroundView.frame = self.bounds
    }
    
    @objc private func backgroundButtonAction() {
        SCHomePageAlertFamilyListView.hide()
    }
}

class SCHomePageAlertFamilyListCell: SCBasicTableViewCell {
    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.HomePageController.AlertFamilyListView.ItemCell.nameLabel.textColor", font: "HomePage.HomePageController.AlertFamilyListView.ItemCell.nameLabel.font")
    
    private lazy var selectImageView: UIImageView = UIImageView(image: "HomePage.HomePageController.AlertFamilyListView.ItemCell.selectImage")
    
    private lazy var familyManagerImageView: UIImageView = UIImageView(image: "HomePage.HomePageController.AlertFamilyListView.ItemCell.settingsImage")
    
    private lazy var lineView: UIView = UIView(lineBackgroundColor: "HomePage.HomePageController.AlertFamilyListView.ItemCell.lineBackgroundColor")
    
    override func set(model: Any?) {
        guard let model = model as? SCHomePageAlertFamilyListItem else { return }
        self.nameLabel.text = model.name
        self.selectImageView.isHidden = !model.isSelected
        self.familyManagerImageView.isHidden = !model.isFamilyManager
        self.lineView.isHidden = !model.hasLineView
    }
    
    override func setupView() {
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.selectImageView)
        self.contentView.addSubview(self.familyManagerImageView)
        self.contentView.addSubview(self.lineView)
    }
    
    override func setupLayout() {
        let margin: CGFloat = 20
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.right.equalTo(self.selectImageView.snp.left).offset(-5)
            make.top.bottom.equalToSuperview().inset(16)
        }
        self.selectImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-margin)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        self.familyManagerImageView.snp.makeConstraints { make in
            make.edges.equalTo(self.selectImageView)
        }
        self.lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(margin)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}
