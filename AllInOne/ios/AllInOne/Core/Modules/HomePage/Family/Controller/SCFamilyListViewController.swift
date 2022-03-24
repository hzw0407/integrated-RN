//
//  SCFamilyListViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/20.
//

import UIKit

class SCFamilyListViewController: SCBasicViewController {

    var familyList: [SCNetResponseFamilyModel] = []
    
    private var items: [[SCNetResponseFamilyModel]] = []
    
    private var addFamilyBlock: (() -> Void)?
    
    private let viewModel = SCFamilyListViewModel()
    
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCFamilyListCell.self, cellIdendify: SCFamilyListCell.identify, rowHeight: nil, style: .grouped) { [weak self] indexPath in
            guard let `self` = self, self.familyList.count > indexPath.row else { return }
            let vc = SCFamilyDetailViewController()
            vc.family = self.familyList[indexPath.row]
            vc.add { [weak self] in
                self?.familyList.remove(at: indexPath.row)
                self?.setupData()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        tableView.register(cell: SCFamilyListAutoChangeCell.self, idendify: SCFamilyListAutoChangeCell.identify, section: 1, cellDelegate: nil)
        tableView.register(header: SCFamilyListSectionHeaderView.self, idendify: SCFamilyListSectionHeaderView.identify, height: nil)
        tableView.set(headerHeights: [nil, 20])
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.familyList.count == 0 {
            self.loadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    func add(addFamilyHandle: (() -> Void)?) {
        self.addFamilyBlock = addFamilyHandle
    }
}

extension SCFamilyListViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("家庭列表")
        self.addRightBarButtonItem(image: "HomePage.FamilyListController.NavigationBar.addFamilyImage", action: #selector(addFamilyButtonAction))
    }
    
    override func setupView() {
        self.view.addSubview(self.tableView)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
        }
    }
    
    override func setupData() {
        self.items.removeAll()
        self.items.append(self.familyList)
        let item = SCNetResponseFamilyModel()
        self.items.append([item])
        
        for familys in self.items {
            for (i, family) in familys.enumerated() {
                var cornerRawValue: UInt = 0
                if i == 0 {
                    cornerRawValue = cornerRawValue | UIRectCorner.topLeft.rawValue | UIRectCorner.topRight.rawValue
                }
                if i == familys.count - 1 {
                    cornerRawValue = cornerRawValue | UIRectCorner.bottomLeft.rawValue | UIRectCorner.bottomRight.rawValue
                }
                if cornerRawValue > 0 {
                    family.corner = UIRectCorner(rawValue: cornerRawValue)
                }
                else {
                    family.corner = nil
                }
                family.isOwner = family.creatorId == SCSmartNetworking.sharedInstance.user?.id
            }
        }
        
        self.tableView.set(list: self.items)
        self.tableView.set(list: self.items, headerList: [tempLocalize("我的家庭"), nil])
    }
    
    private func loadData() {
        self.viewModel.loadFamilyData { [weak self] list in
            self?.familyList = list
            self?.setupData()
        } failure: {
            
        }

    }
    
    @objc private func addFamilyButtonAction() {
        let vc = SCAddFamilyViewController()
        vc.add { [weak self] in
            self?.addFamilyBlock?()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
