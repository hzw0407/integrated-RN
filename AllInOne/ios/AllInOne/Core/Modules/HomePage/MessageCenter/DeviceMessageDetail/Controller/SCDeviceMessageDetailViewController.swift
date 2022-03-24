//
//  SCDeviceMessageDetailViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/25.
//

import UIKit

class SCDeviceMessageDetailViewController: SCBasicViewController {

    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCDeviceMessageDetailCell.self, cellIdendify: SCDeviceMessageDetailCell.identify, rowHeight: nil, style: .grouped, didSelectHandle: nil)
        tableView.register(header: SCDeviceMessageDetailSectionHeaderView.self, idendify: SCDeviceMessageDetailSectionHeaderView.identify, height: nil)
        tableView.register(footer: SCDeviceMessageDetailSectionFooterView.self, idendify: SCDeviceMessageDetailSectionFooterView.identify, height: nil)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension SCDeviceMessageDetailViewController {
    override func setupView() {
        self.view.addSubview(self.tableView)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
        }
    }
}
