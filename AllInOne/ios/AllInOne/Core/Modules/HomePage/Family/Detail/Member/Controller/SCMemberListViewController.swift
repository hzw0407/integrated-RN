//
//  SCMemberListViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/22.
//

import UIKit

class SCMemberListViewController: SCBasicViewController {

    var family: SCNetResponseFamilyModel? {
        didSet {
            self.familyId = self.family?.id ?? ""
            
        }
    }
    
    private var familyId: String = ""
    private var list: [SCNetResponseFamilyMemberModel] = []
    
    private let viewModel: SCMmeberListViewModel = SCMmeberListViewModel()
    
    private lazy var tableView: SCBasicTableView = SCBasicTableView(cellClass: SCMemberListItemCell.self, cellIdendify: SCMemberListItemCell.identify, rowHeight: 74, style: .grouped) { [weak self] indexPath in
        guard let `self` = self, self.list.count > indexPath.row else { return }
        let vc = SCMemberDetailViewController()
        vc.member = self.list[indexPath.row]
        vc.family = self.family
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private lazy var addButton: UIButton = UIButton(tempLocalize("新增共享成员"), titleColor: "HomePage.FamilyListController.MemberListController.addButton.textColor", font: "HomePage.FamilyListController.MemberListController.addButton.font", target: self, action: #selector(addButtonAction), backgroundColor: "HomePage.FamilyListController.MemberListController.addButton.backgroundColor", cornerRadius: 12)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadData()
    }
}

extension SCMemberListViewController {
    override func setupView() {
        self.title = tempLocalize("家庭成员")
        
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.addButton)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
            make.bottom.equalTo(self.addButton.snp.top).offset(-10)
        }
        self.addButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-36)
        }
    }
    
    private func reloadData() {
        self.addButton.isHidden = !(self.family?.creatorId == SCSmartNetworking.sharedInstance.user?.id)
        self.tableView.set(list: [self.list])
    }
    
    private func loadData() {
        self.viewModel.loadMemberList(familyId: self.familyId) { [weak self] list in
            guard let `self` = self else { return }
            self.list = list
            self.reloadData()
        }
    }
    
    @objc private func addButtonAction() {
        let vc = SCAddMemberAccoundTypeViewController()
        vc.familyId = self.familyId
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
