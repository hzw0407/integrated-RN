//
//  SCShareTypeViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/29.
//

import UIKit

class SCShareTypeViewController: SCBasicViewController {

    private var list: [SCShareInfoType] = []
    
    private lazy var tableView: SCBasicTableView = SCBasicTableView(cellClass: SCShareTypeItemCell.self, cellIdendify: SCShareTypeItemCell.identify, rowHeight: 100) { [weak self] indexPath in
        guard let `self` = self else { return }
        let type = self.list[indexPath.row]
        if type == .family {
            let vc = SCFamilyListViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if type == .device {
            let vc = SCDeviceShareListViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
}

extension SCShareTypeViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("共享")
        self.setupRightBarButtonItem(title: tempLocalize("共享历史"), action: #selector(shareHistoryAction))
    }
    
    override func setupView() {
        self.view.addSubview(self.tableView)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin).offset(6)
        }
    }
    
    override func setupData() {
        self.list = [.family, .device]
        self.tableView.set(list: [self.list])
    }
    
    @objc private func shareHistoryAction() {
        let vc = SCShareHistoryViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
