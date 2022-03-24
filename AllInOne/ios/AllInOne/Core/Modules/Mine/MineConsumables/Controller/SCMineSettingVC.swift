//
//  SCMineSettingVC.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/22.
//

import UIKit

class SCMineSettingVC: SCBasicViewController {
    private let viewModel = SCMineViewModel()
    /// 列表
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCMineInfoEditTextCell.self, cellIdendify: SCMineIconAndArrowCell.identify, rowHeight: 56, cellDelegate: self, style: .grouped)
        tableView.backgroundColor = UIColor.clear
        tableView.register(header: UITableViewHeaderFooterView.self, idendify: "SCMineSectionHeader", height: 12)
        tableView.register(footer: UITableViewHeaderFooterView.self, idendify: "SCMineSectionFooter", height: 0.1)
        tableView.didSelectBlock = { [unowned self] (indexPath) in
            switch indexPath.row {
            case 0:
                // 推送设置
                self.navigationController?.pushViewController(SCMineSettingNoticeSwitchVC(), animated: true)
            case 1:
                // 提示音设置
                self.navigationController?.pushViewController(SCMineSettingCueToneVC(), animated: true)
            case 2:
                // 地址选择
                let vc = SCCountryListViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            case 3:
                // 时区选择
                self.showTimeZoneView()
            case 4:
                // 语言设置
                self.navigationController?.pushViewController(SCMineSettingLanguageVC(), animated: true)
            case 5:
                // 清除缓存
                self.showClearCacheView()
            default:
                return
            }
        }
        return tableView
    }()
    /// 数据
    var dataArray: [[SCMineInfoEditModel]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    /// 时区提示
    func showTimeZoneView() {
        let tipLabel = UILabel(text:"当前手机时区为 GMT+8:00,是否同步到设备？", textColor: "Mine.SCMineShareListVC.tipLabel.textColor", font: "Mine.SCMineShareListVC.tipLabel.font", alignment: .center)
        tipLabel.numberOfLines = 0
        tipLabel.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44)
        SCAlertView.alert(title: tempLocalize("提示"), customView: tipLabel, cancelTitle: tempLocalize("取消"), confirmTitle: tempLocalize("确定"), cancelCallback: {
            
        }, confirmCallback: {
            SCProgressHUD.showHUD(tempLocalize("同步成功"))
        }, isNeedManualHide: true)
    }
    /// 清除缓存
    func showClearCacheView() {
        SCAlertView.alert(title: tempLocalize("提示"), message: tempLocalize("即将开始清理缓存"), cancelTitle: tempLocalize("取消"), confirmTitle: tempLocalize("确定"), confirmCallback: {
            SCAppCacheManager.clearAllCache { [weak self] in
                let text = self?.dataArray.last?.last?.subTitle
                SCProgressHUD.showHUD(tempLocalize("清理完成！已释放\(text ?? "0KB")空间"))
                self?.loadCacheData()
            }
        })
    }
}

extension SCMineSettingVC {
    override func setupView() {
        self.title = "设置"
        self.view.addSubview(self.tableView)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(kSCNavAndStatusBarHeight)
            make.left.right.bottom.equalTo(0)
        }
    }

    override func setupData() {
        self.dataArray = self.viewModel.initSettingData()
        self.tableView.set(list: self.dataArray)
        
        self.loadCacheData()
    }
    
    private func loadCacheData() {
        SCAppCacheManager.loadCacheSizeString { [weak self] text in
            self?.dataArray.last?.last?.subTitle = text
            self?.tableView.reloadData()
        }
    }
}

