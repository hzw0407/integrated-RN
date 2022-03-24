//
//  SCMineViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/26.
//

import UIKit

class SCMineViewController: SCBasicViewController {

    private let viewModel = SCMineViewModel()

    private lazy var personInfoView: SCMinePersonInformationView = {
        let view = SCMinePersonInformationView()
        view.add {
            let vc = SCPersonInformationViewController()
            vc.model = self.viewModel.model
            self.navigationController?.pushViewController(vc, animated: true)

        }
        return view
    }()
    /// 头
    private lazy var headerView: SCMinePersonInfoHeaderView = {
        let headerView = SCMinePersonInfoHeaderView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 144))
        headerView.editClickBlock = { () in
            self.navigationController?.navigationBar.isHidden = false
            let vc = SCMineInfoEditController()
            vc.dataModel = self.viewModel.model
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
     
        return headerView
    }()
    /// 尾
    private lazy var footerView: UIView = {
        let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 80))
        let logoutBtn = UIButton(tempLocalize("退出登录"), titleColor: "Mine.MineController.SCMinePersonInfoFooterView.logoutBtn.textColor", font: "Mine.MineController.SCMinePersonInfoFooterView.logoutBtn.font", target: self, action: #selector(logoutBtnAction), backgroundColor: "Mine.MineController.SCMinePersonInfoFooterView.logoutBtn.backgroundColor", cornerRadius: 18)
        footerView.addSubview(logoutBtn)
        logoutBtn.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(12)
            make.right.equalTo(-20)
            make.bottom.equalTo(-12)
        }
        return footerView
    }()
    /// 列表
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCMineIconAndArrowCell.self, cellIdendify: SCMineIconAndArrowCell.identify, rowHeight: 56, cellDelegate: self, style: .grouped)
        tableView.backgroundColor = UIColor.clear
        tableView.tableHeaderView = self.headerView
        tableView.tableFooterView = self.footerView
        tableView.register(header: UITableViewHeaderFooterView.self, idendify: "SCMineSectionHeader", height: 12)
        tableView.register(footer: UITableViewHeaderFooterView.self, idendify: "SCMineSectionFooter", height: 0.1)
        tableView.didSelectBlock = { [unowned self] (indexPath) in
            self.pushVC(indexPath: indexPath)
        }
        return tableView
    }()
    /// 数据
    var dataArray: NSArray = NSArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        
     
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.viewModel.loadData { [weak self] in
            guard let `self` = self else { return }
            if let model = self.viewModel.model {
                self.personInfoView.set(model: model)
                self.headerView.setDataModel(model: model)
            }
        }
     
    }
    
    func pushVC(indexPath: IndexPath) {
        self.navigationController?.navigationBar.isHidden = false
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                // 共享
//                self.navigationController?.pushViewController(SCMineShareMainVC(), animated: true)
                let vc = SCShareTypeViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case 1:
                /// 设备耗材
                self.navigationController?.pushViewController(SCMineConsumablesVC(), animated: true)
                break
            case 2:
                /// 家庭房间管理
                let vc = SCFamilyListViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case 3:
                /// 设置
                break
            default:
                break
            }
        } else if indexPath.section == 1 {
            
            switch indexPath.row {
            case 0:
                // 设置
                self.navigationController?.pushViewController(SCMineSettingVC(), animated: true)
            case 1:
                /// 帮助与反馈
//                self.navigationController?.pushViewController(SCMineHelpVC(), animated: true)
                let vc = SCFeedbackTypeViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            case 2:
                /// 协议
                self.navigationController?.pushViewController(SCPrivacyWebController(), animated: true)
            case 3:
                /// 关于我们
                self.navigationController?.pushViewController(SCMineAboutController(), animated: true)
            default:
                break
            }
            /// 注销
          //  self.navigationController?.pushViewController(SCMineAccountCancellationVC(), animated: true)
        }
    }
}

extension SCMineViewController {
    override func setupNavigationBar() {
        
    }
    
    override func setupView() {
        self.view.addSubview(self.tableView)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setupData() {
        self.dataArray = self.viewModel.initData()
        self.tableView.set(list: self.dataArray as! [[Any]])
    }
    
 
    
}

extension SCMineViewController {
    @objc private func rightBarButtonItemAction() {
        SCSmartNetworking.sharedInstance.logoutRequest {
            SCSmartNetworking.sharedInstance.clearUser()
            SCUserCenter.sharedInstance.pushToLogin()
        } failure: { error in
            
        }

    }
    @objc private func logoutBtnAction() {
        SCAlertView.alert(title: tempLocalize("提示"), message: tempLocalize("确定退出登录？"), cancelTitle: tempLocalize("取消"), confirmTitle: tempLocalize("确定"), confirmCallback: {
            SCUserCenter.sharedInstance.pushToLogin()
        })
    }
}
