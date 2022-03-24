//
//  SCMineSettingCueToneVC.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/22.
//

import UIKit

class SCMineSettingCueToneVC: SCBasicViewController {
    private let viewModel = SCMineViewModel()
    /// 列表
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCMineInfoEditTextCell.self, cellIdendify: SCMineInfoEditTextCell.identify, rowHeight: 56, cellDelegate: self, style: .grouped)
        tableView.backgroundColor = UIColor.clear
        tableView.register(header: UITableViewHeaderFooterView.self, idendify: "SCMineSectionHeader", height: 12)
        tableView.register(footer: UITableViewHeaderFooterView.self, idendify: "SCMineSectionFooter", height: 0.1)
        tableView.didSelectBlock = { [unowned self] (indexPath) in

        }
        return tableView
    }()
    /// 数据
    var dataArray: [[SCMineInfoEditModel]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func testAllOpen() -> Bool {
        var isAllOpen = false
        let sectionArray = self.dataArray[1]
        for index in 0..<sectionArray.count {
            let model = sectionArray[index]
            if index == 0 {
                isAllOpen = model.isSwitchOn
            } else {
                isAllOpen = isAllOpen && model.isSwitchOn
            }
        }
        return isAllOpen
    }
    
    func isOpenAll(isOpen: Bool) {
        self.dataArray.forEach { sectionArray in
            sectionArray.forEach { model in
                model.isSwitchOn = isOpen
            }
        }
    }
}

extension SCMineSettingCueToneVC {
    override func setupView() {
        self.title = "设备提示音"
        self.view.addSubview(self.tableView)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(kSCNavAndStatusBarHeight)
            make.left.right.bottom.equalTo(0)
        }
    }

    override func setupData() {
       self.viewModel.getDeviceListRequest(getDeviceListBlock: { listModel, err in
           self.dataArray = listModel as! [[SCMineInfoEditModel]]
           self.tableView.set(list: self.dataArray)
        })
     
    }
}

extension SCMineSettingCueToneVC:SCMineInfoEditTextCellDelegate {
    func cell(_ cell: SCMineInfoEditTextCell, didSelected model: SCMineInfoEditModel) {
        
    }
    
    func cell(_ cell: SCMineInfoEditTextCell, didSwicthAction model: SCMineInfoEditModel, isOpen: Bool) {
        if model.title == "开启全部" {
            self.isOpenAll(isOpen: model.isSwitchOn)
        } else {
            let sectionArray = self.dataArray[0]
            sectionArray.forEach { model in
                model.isSwitchOn = self.testAllOpen()
            }
        }
        self.tableView.reloadData()
    }
}
