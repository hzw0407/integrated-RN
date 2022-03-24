//
//  SCAddMemberAccoundTypeViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/23.
//

import UIKit

class SCAddMemberAccoundTypeViewController: SCBasicViewController {

    var familyId: String = ""
    
    private var list: [SCAddMemberAccountType] = []
    
    private lazy var tableView: SCBasicTableView = SCBasicTableView(cellClass: SCAddMemberAccountTypeCell.self, cellIdendify: SCAddMemberAccountTypeCell.identify, rowHeight: nil) { [weak self] indexPath in
        guard let `self` = self else { return }
        let type = self.list[indexPath.row]
        if type == .aijia {
            let vc = SCAddMemberViewController()
            vc.familyId = self.familyId
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension SCAddMemberAccoundTypeViewController {
    override func setupView() {
        self.title = tempLocalize("共享给")
        self.view.addSubview(self.tableView)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
        }
    }
    
    override func setupData() {
        self.list = [.wechat, .aijia]
        self.tableView.set(list: [self.list])
    }
}
