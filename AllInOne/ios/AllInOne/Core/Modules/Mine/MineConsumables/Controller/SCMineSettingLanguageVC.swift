//
//  SCMineSettingLanguageVC.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/22.
//

import UIKit

class SCMineSettingLanguageVC: SCBasicViewController {
    private let viewModel = SCMineViewModel()
    /// 列表
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCMineSettingLanguageCell.self, cellIdendify: SCMineSettingLanguageCell.identify, rowHeight: 56, cellDelegate: self, style: .grouped)
        tableView.backgroundColor = UIColor.clear
        tableView.register(header: UITableViewHeaderFooterView.self, idendify: "SCMineSectionHeader", height: 12)
        tableView.register(footer: UITableViewHeaderFooterView.self, idendify: "SCMineSectionFooter", height: 0.1)
        tableView.didSelectBlock = { [unowned self] (indexPath) in
            let sectionArray = self.dataArray[indexPath.section]
            let model = sectionArray[indexPath.row]
            model.isSelected = true
            self.dataArray.forEach { array in
                array.forEach { itemModel in
                    if itemModel != model {
                        itemModel.isSelected = false
                    }
                }
            }
            self.tableView.set(list: self.dataArray)
        }
        return tableView
    }()
    /// 数据
    var dataArray: [[SCMineSettingLanguageModel]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SCMineSettingLanguageVC {
    override func setupView() {
        self.title = tempLocalize("多语言")
        self.view.addSubview(self.tableView)
        self.addSaveBtn()
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(kSCNavAndStatusBarHeight)
            make.left.right.bottom.equalTo(0)
        }
    }
    override func setupData() {
        self.dataArray = self.viewModel.initSettingLanguageData() as! [[SCMineSettingLanguageModel]]
        self.tableView.set(list: self.dataArray)
    }
    
    func addSaveBtn() {
        let saveBtn = UIButton.init(type: .custom)
        saveBtn.theme_setImage("Mine.SCMineSettingLanguageVC.saveImage", forState: .normal)
        saveBtn.frame = CGRect.init(x: 0, y: 0, width: 20, height: 20)
        saveBtn.addTarget(self, action: #selector(saveBtnAction(btn:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveBtn)
    }
}

// MARK: - Actions
extension SCMineSettingLanguageVC {
    @objc private func saveBtnAction(btn: UIButton) {
        if let item = self.dataArray[0].first(where: { item in
            return item.isSelected
        }) {
            SCLocalize.set(appLanguageType: item.type)
        }
    }
}
