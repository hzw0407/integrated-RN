//
//  SCMineChangePasswordController.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/15.
//

import UIKit

class SCMineChangePasswordController: SCBasicViewController {
    
    private let viewModel = SCMineViewModel()
    /// 列表
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCMineInfoEditTextCell.self, cellIdendify: SCMineIconAndArrowCell.identify, rowHeight: 56, cellDelegate: self, style: .grouped) { [unowned self] (indexPath) in
            self.pushVC(indexPath: indexPath)
        }
        tableView.backgroundColor = UIColor.clear
        tableView.register(header: UITableViewHeaderFooterView.self, idendify: "SCMineSectionHeader", height: 12)
        tableView.register(footer: UITableViewHeaderFooterView.self, idendify: "SCMineSectionFooter", height: 0.1)
        return tableView
    }()
    /// 数据
    var dataArray: NSArray = NSArray()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func pushVC(indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            /// 原始密码
            self.navigationController?.pushViewController(SCMineResetPasswordController(), animated: true)
        case 1:
            /// 手机号验证
            let vc = SCMineVerificationVC()
            vc.type = .phoneVerification
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            /// 邮箱验证
            let vc = SCMineVerificationVC()
            vc.type = .emailVerification
            self.navigationController?.pushViewController(vc, animated: true)
        case 3:
            print("3")
        default:
            break
        }
    }
}

extension SCMineChangePasswordController {
    override func setupView() {
        self.title = "修改密码"
        self.view.addSubview(self.tableView)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.topOffset)
            make.left.right.bottom.equalTo(0)
        }
    }

    override func setupData() {
        self.dataArray = self.viewModel.initChangePasswordData()
        self.tableView.set(list: self.dataArray as! [[Any]])
    }
}
