//
//  SCMineConsumablesVC.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/22.
//

import UIKit

class SCMineConsumablesVC: SCBasicViewController {
    private let viewModel = SCMineViewModel()
    /// 列表
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCMineConsumableCell.self, cellIdendify: SCMineConsumableCell.identify, rowHeight: 56, cellDelegate: self, style: .grouped, hasEmptyView: true)
        tableView.backgroundColor = UIColor.clear
        tableView.register(header: SCMineConsumableHeaderView.self, idendify: SCMineConsumableHeaderView.identify, height: 40)
        tableView.register(footer: UITableViewHeaderFooterView.self, idendify: "SCMineSectionFooter", height: 0.1)
        tableView.didSelectBlock = { [unowned self] (indexPath) in
            
        }
        return tableView
    }()
    /// 选择按钮
    private lazy var titleButton: UIButton = {
        let btn = UIButton("", titleColor: "Mine.SCMineConsumablesVC.titleButton.textColor", font: "Mine.SCMineConsumablesVC.titleButton.font", target: self, action: #selector(titleButtonAction))
        btn.theme_setImage("Mine.SCMineConsumablesVC.titleButton.normalImage", forState: .normal)
        return btn
    }()
    
    private lazy var popView: SCMineHouseSelectView = {
        let popView = SCMineHouseSelectView.init()
        return popView
    }()
    /// 数据
    var dataArray: [[SCMineConsumableModel]] = []
    /// 头部数据
    var headerList: [SCMineConsumableHeaderModel] = []
    /// 房间数据
    var houseDataArray: [SCNetResponseFamilyModel] = []
    
    private var familyItems: [SCHomePageAlertFamilyListItem] = []
    private var currentIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func lbWidth(lable: UILabel) -> CGFloat {
        lable.sizeToFit()
        return lable.bounds.size.width
    }
    func updateTitleView() {
        self.titleButton.frame = CGRect.init(x: 0, y: 0, width: 200, height: 300)
        self.titleButton.layoutIfNeeded()
        let offsetX = self.lbWidth(lable: self.titleButton.titleLabel!)
        self.titleButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: offsetX + 24 + 28, bottom: 0, right: 0)
        self.titleButton.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -24, bottom: 0, right: 0)
    }
}

extension SCMineConsumablesVC {
    override func setupView() {
        self.navigationItem.titleView = self.titleButton
        self.view.addSubview(self.tableView)
        self.updateTitleView()
        // 房间选择
        self.popView.didSelectBlock = { [unowned self] (indexPath, model) in
            self.titleButton.setTitle(model.name, for: .normal)
            self.loadData(familyId: model.id)
            
            self.updateTitleView()
            self.dismissPopView()
        }
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(kSCNavAndStatusBarHeight)
            make.left.right.bottom.equalTo(0)
        }
    }
    override func setupData() {
     
   

        
        SCSmartNetworking.sharedInstance.getFamilyListRequest { [weak self] modelList in
            
            self?.houseDataArray = modelList
            let model = modelList.filter({ $0.id == SCHomePageViewModel.currentFamilyId() }).first
            self?.titleButton.setTitle(model?.name ?? "", for: .normal)
            self?.updateTitleView()
            self?.reloadFamilyData(familys: modelList)
        } failure: { error in
            
        }

        
        // 房间数据
//        let titles = ["杉川的家庭", "南山公司十楼..."]
//        for index in 0..<titles.count {
//            let sectionModel = SCMineHouseSelectModel.init()
//            sectionModel.title = titles[index]
//            sectionModel.isSelected = index == 0
//            self.houseDataArray.append(sectionModel)
//        }
        
        self.loadData(familyId: SCHomePageViewModel.currentFamilyId() ?? "")
    }
    
    func reloadFamilyData(familys: [SCNetResponseFamilyModel]) {
        var items: [SCHomePageAlertFamilyListItem] = []
        for family in familys {
            let item = SCHomePageAlertFamilyListItem()
            item.family = family
            item.hasLineView = true
            item.isSelected = SCHomePageViewModel.currentFamilyId() == family.id
            family.isOwner = family.creatorId == SCSmartNetworking.sharedInstance.user?.id
            items.append(item)
        }
        self.familyItems = items
    }
    
    func loadData(familyId: String) {
        self.viewModel.initConsumableData(familyId: familyId, completHandle:{request,response,err in
            self.dataArray = request as! [[SCMineConsumableModel]]
         let responseList = response as! [SCMineConsumableModel]
            
            for model in responseList {
                let sectionModel = SCMineConsumableHeaderModel.init()
               sectionModel.name = model.nickname
                sectionModel.location = model.roomName
                self.headerList.append(sectionModel)
            }
            self.tableView.set(list: self.dataArray, headerList: self.headerList)
            self.tableView.reloadData()
        })
    }
}

// MARK: - Actions
extension SCMineConsumablesVC {
    @objc private func titleButtonAction() {
//        self.showPopView()
        
        let width: CGFloat = 200
        let x = (kSCScreenWidth - width) / 2
        SCHomePageAlertFamilyListView.show(list: self.familyItems, topOffsetY: kSCNavAndStatusBarHeight, leftOffset: x, width: width) { [weak self] item in
            guard let `self` = self else { return }
            self.familyItems.forEach { item in
                item.isSelected = false
            }
            item.isSelected = true
            
            self.loadData(familyId: item.family!.id)
            self.titleButton.setTitle(item.family?.name ?? "", for: .normal)
            self.updateTitleView()
        }
    }
    
    func showPopView() {
        if self.view.subviews.contains(self.popView) {
            self.popView.isHidden = false
        } else {
            self.view.addSubview(self.popView)
            self.popView.snp.makeConstraints { make in
                make.size.equalTo(CGSize.init(width: 160, height: 112))
                make.top.equalTo(kSCNavAndStatusBarHeight)
                make.centerX.equalToSuperview()
            }
        }
        self.popView.dataArray = [self.houseDataArray]
    }
    
    func dismissPopView() {
        self.popView.isHidden = true
    }
}
