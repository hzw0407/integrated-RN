//
//  SCSweeperCleaningAutoPlanView.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/2/16.
//

import UIKit

class SCSweeperCleaningAutoPlanItem {
    var coverImage: ThemeImagePicker?
    var title: String = ""
    var percent: Int = 0
}

class SCSweeperCleaningAutoPlanView: SCBasicView {

    private var foldBlock: (() -> Void)?
    
    private var list: [SCSweeperCleaningAutoPlanItem] = []
    
    private lazy var titleView: SCSweeperCleaningPlanTitleView = SCSweeperCleaningPlanTitleView(coverImage: "PluginSweeperTheme.CleaningViewController.MapView.PlanTitleView.autoPlanImage", title: tempLocalize("自动模式")) { [weak self] in
        self?.foldBlock?()
    }
    
    private lazy var contentView: UIView = UIView(backgroundColor: "PluginSweeperTheme.CleaningViewController.MapView.AutoPlanView.backgroundColor", cornerRadius: 18)
    
    private lazy var tableView: SCBasicTableView = SCBasicTableView(cellClass: SCSweeperCleaningAutoPlanCell.self, cellIdendify: SCSweeperCleaningAutoPlanCell.identify, rowHeight: 50)
    
    convenience init(clickHandler: (() -> Void)?) {
        self.init(frame: .zero)
        self.foldBlock = clickHandler
    }

    func fold() {
        self.titleView.fold()
    }
    
    func unfold() {
        self.titleView.unfold()
    }
}

extension SCSweeperCleaningAutoPlanView {
    override func setupView() {
        self.layer.masksToBounds = true
        self.addSubview(self.titleView)
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.tableView)
        
        self.setupData()
    }
    
    override func setupLayout() {
        self.titleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(40)
        }
        self.contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.titleView.snp.bottom)
            make.height.equalTo(50 * 3 + 20 * 2)
        }
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func setupData() {
        let images: [ThemeImagePicker] = ["PluginSweeperTheme.CleaningViewController.MapView.AutoPlanView.ItemCell.suctionLevelImage", "PluginSweeperTheme.CleaningViewController.MapView.AutoPlanView.ItemCell.waterLevelImage", "PluginSweeperTheme.CleaningViewController.MapView.AutoPlanView.ItemCell.mopLevelImage"]
        let titles = [tempLocalize("吸力"), tempLocalize("水量"), tempLocalize("拖地强度")]
        
        for (i, title) in titles.enumerated() {
            let image = images[i]
            let item = SCSweeperCleaningAutoPlanItem()
            item.title = title
            item.coverImage = image
            item.percent = 40 + i * 10
            self.list.append(item)
        }
        self.tableView.set(list: [self.list])
    }
}
