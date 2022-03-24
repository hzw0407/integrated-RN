//
//  SCAddFamilyViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/21.
//

import UIKit

class SCAddFamilyViewController: SCBasicViewController {

    private var list: [SCAddFamilyItemModel] = []
    
    private var addFamilyBlock: (() -> Void)?
    
    private lazy var tableView: SCBasicTableView = SCBasicTableView(cellClass: SCAddFamilyItemCell.self, cellIdendify: SCAddFamilyItemCell.identify, rowHeight: nil) { [weak self] indexPath in
        guard let `self` = self else { return }
        let model = self.list[indexPath.row]
        switch model.type {
        case .name:
            SCAlertView.alertText(title: tempLocalize("家庭名称"), range: NSRange(location: 0, length: 12), placeholder: tempLocalize("请输入家庭名称"), confirmCallback: { [weak self] text in
                guard let `self` = self else { return }
                if text.count > 0 {
                    model.content = text
                    self.reloadData()
                }
            })
            break
        case.location:
            SCFamilyLocationViewController.checkMapPrivacy { [weak self] in
                guard let `self` = self else { return }
                let vc = SCFamilyLocationViewController()
                vc.add { [weak self] location in
                    model.content = location.locationName
                    self?.reloadData()
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        default:
            break
        }
    }
    
    private lazy var addFamilyButton: UIButton = UIButton(tempLocalize("添加家庭"), titleColor: "HomePage.FamilyListController.AddFamilyController.addFamilyButton.textColor", font: "HomePage.FamilyListController.AddFamilyController.addFamilyButton.font", target: self, action: #selector(addFamilyButtonAction), disabledTitleColor: "HomePage.FamilyListController.AddFamilyController.addFamilyButton.disabledTextColor", backgroundColor: "HomePage.FamilyListController.AddFamilyController.addFamilyButton.backgroundColor", cornerRadius: 12)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func add(addFamilyComplete: (() -> Void)?) {
        self.addFamilyBlock = addFamilyComplete
    }
}

extension SCAddFamilyViewController {
    override func setupView() {
        self.title = tempLocalize("添加家庭")
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.addFamilyButton)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
            make.bottom.equalTo(self.addFamilyButton.snp.bottom).offset(-10)
        }
        self.addFamilyButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-36)
        }
    }
    
    override func setupData() {
        let types: [SCAddFamilyItemType] = [.name, .location]
        let names: [String] = [tempLocalize("家庭名称"), tempLocalize("家庭位置")]
        let images: [ThemeImagePicker?] = ["HomePage.FamilyListController.AddFamilyController.ItemCell.coverImage.nameImage", "HomePage.FamilyListController.AddFamilyController.ItemCell.coverImage.locationImage"]
        let placeholders: [String] = [tempLocalize("请输入新建家庭的名称"), tempLocalize("请设定家庭位置")]
        
        var items: [SCAddFamilyItemModel] = []
        for (i, type) in types.enumerated() {
            let item = SCAddFamilyItemModel()
            item.type = type
            item.name = names[i]
            item.image = images[i]
            item.placeholder = placeholders[i]
            item.hasNext = true
            
            items.append(item)
        }
        self.list = items
        self.tableView.set(list: [self.list])
        
        self.refreshAddButtonState()
    }
    
    private func reloadData() {
        self.tableView.reloadData()
        self.refreshAddButtonState()
    }
    
    private func refreshAddButtonState() {
        let nameItem = self.list.filter({ $0.type == .name }).first!
        let locationItem = self.list.filter({ $0.type == .location }).first!
        
        if nameItem.content.count > 0 && locationItem.content.count > 0 {
            self.addFamilyButton.isEnabled = true
            self.addFamilyButton.theme_backgroundColor = "HomePage.FamilyListController.AddFamilyController.addFamilyButton.backgroundColor"
        }
        else {
            self.addFamilyButton.isEnabled = false
            self.addFamilyButton.theme_backgroundColor = "HomePage.FamilyListController.AddFamilyController.addFamilyButton.disabledBackgroundColor"
        }
    }
    
    @objc private func addFamilyButtonAction() {
        let nameItem = self.list.filter({ $0.type == .name }).first!
        let locationItem = self.list.filter({ $0.type == .location }).first!
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.addFamilyRequest(name: nameItem.content, address: locationItem.content) { [weak self] in
            SCProgressHUD.hideHUD()
            self?.addFamilyBlock?()
            self?.navigationController?.popToRootViewController(animated: true)
        } failure: { error in
            SCProgressHUD.showHUD(tempLocalize("添加失败"))
        }

    }
}
