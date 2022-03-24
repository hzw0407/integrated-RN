//
//  SCMineSettingWeekPickerView.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/23.
//

import UIKit

class SCMineSettingWeekPickerView: UIView {

    public var weekDidSelectRow: ((String) -> Void)?
    /// 列表
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCMineSettingWeekItemCell.self, cellIdendify: SCMineSettingWeekItemCell.identify, rowHeight: 56, cellDelegate: self, style: .grouped)
        tableView.backgroundColor = UIColor.clear
        tableView.register(header: UITableViewHeaderFooterView.self, idendify: "SCMineSectionHeader", height: 0.1)
        tableView.register(footer: UITableViewHeaderFooterView.self, idendify: "SCMineSectionFooter", height: 0.1)
        tableView.didSelectBlock = { [unowned self] (indexPath) in
            
        }
        return tableView
    }()
    
    var dataArray: [SCMineSettingWeekItemModel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
        let weeks = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
        for index in 0..<weeks.count {
            let model = SCMineSettingWeekItemModel()
            model.isSelected = false
            model.week = weeks[index]
            self.dataArray.append(model)
        }
        self.tableView.set(list: [self.dataArray])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.backgroundColor = UIColor.clear
        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    func getSeletedWeeks() -> [String] {
        var tempArr: [String] = []
        for index in 0..<self.dataArray.count {
            let model = self.dataArray[index]
            if model.isSelected == true {
                tempArr.append(model.week)
            }
        }
        return tempArr
    }
}

extension SCMineSettingWeekPickerView: SCMineSettingWeekItemCellDelegate {
    func cell(_ cell: SCMineSettingWeekItemCell, didSelectedAction model: SCMineSettingWeekItemModel, isSelected: Bool) {
        let weekStr = self.getSeletedWeeks().joined(separator: " ")
        self.weekDidSelectRow?(weekStr)
    }
}


