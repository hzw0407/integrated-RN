//
//  SCMineHouseSelectView.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/24.
//

import UIKit

class SCMineHouseSelectView: UIView {
    
    public var dataArray: [[SCNetResponseFamilyModel]] = [] {
        didSet {
            self.tableView.set(list: dataArray)
        }
    }
    public var didSelectBlock: ((IndexPath, SCNetResponseFamilyModel) -> Void)?
    /// 列表
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCMineHouseSelectCell.self, cellIdendify: SCMineHouseSelectCell.identify, rowHeight: 56, cellDelegate: self, style: .grouped)
        tableView.backgroundColor = UIColor.clear
        tableView.register(header: UITableViewHeaderFooterView.self, idendify: "SCMineSectionHeader", height: 0.1)
        tableView.register(footer: UITableViewHeaderFooterView.self, idendify: "SCMineSectionFooter", height: 0.1)
        tableView.didSelectBlock = { [unowned self] (indexPath) in
            let sectionArray = self.dataArray[indexPath.section]
            let model = sectionArray[indexPath.row]
            model.isSelected = true
            self.dataArray.forEach { array in
                array.forEach { itemModel in
                    
                        itemModel.isSelected = false
                    
                }
            }
            self.tableView.set(list: self.dataArray)
            self.didSelectBlock?(indexPath, model)
        }
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        self.layer.cornerRadius = 18
        self.layer.masksToBounds = true
        self.theme_backgroundColor = "Mine.SCMineBaseCell.colorBgView.backgroundColor"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
