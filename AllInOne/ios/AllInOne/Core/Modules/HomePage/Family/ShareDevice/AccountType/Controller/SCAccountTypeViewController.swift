//
//  SCAccountTypeViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/25.
//

import UIKit

class SCAccountTypeViewController: SCBasicViewController {

    var param: [String: Any] = [:]
    var sourceType: SCAccountTypeSourceType = .shareDevice
    
    private var list: [SCAccountType] = []
    
    private lazy var tableView: SCBasicTableView = SCBasicTableView(cellClass: SCAccountTypeCell.self, cellIdendify: SCAccountTypeCell.identify, rowHeight: nil) { [weak self] indexPath in
        guard let `self` = self else { return }
        let type = self.list[indexPath.row]
        switch self.sourceType {
        case .shareDevice:
            if type == .aijia {
                guard let deviceIds = self.param["deviceIds"] as? [String] else { return }
                let vc = SCShareDeviceToAccountViewController()
                vc.deviceIds = deviceIds
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case .addMember:
            break
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension SCAccountTypeViewController {
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
