//
//  SCCountryListViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/24.
//

import UIKit

class SCCountryListViewController: SCBasicViewController {

    private var list: [[SCCountryModel]] = []
    
    private var searchList: [SCCountryModel] = []
    
    private var currentItem: SCCountryModel?
    
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCCountryListCell.self, cellIdendify: SCCountryListCell.identify, rowHeight: 46, style: .grouped) { [weak self] indexPath in
            guard let `self` = self else { return }
            let item = self.list[indexPath.section][indexPath.row]
            item.isSelected = true
            self.currentItem?.isSelected = false
            self.currentItem = item
            self.tableView.reloadData()
        }
        tableView.register(header: SCCountrySectionHeaderView.self, idendify: SCCountrySectionHeaderView.identify, height:  nil)
        tableView.add { [weak self] in
            guard let `self` = self else { return }
            self.view.endEditing(true)
        }
        return tableView
    }()
    
    private lazy var searchTableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCCountryListCell.self, cellIdendify: SCCountryListCell.identify, rowHeight: 50) { [weak self] indexPath in
            guard let `self` = self, self.searchList.count > indexPath.row else { return }
            let item = self.searchList[indexPath.row]
            item.isSelected = true
            self.currentItem?.isSelected = false
            self.currentItem = item
            self.searchTableView.reloadData()
        }
        tableView.isHidden = true
        tableView.add {
            self.view.endEditing(true)
        }
        return tableView
    }()
    
//    private lazy var searchBar = SCCountrySearchView { text in
//        self.tableView.isHidden = text.count > 0
//        self.searchTableView.isHidden = text.count == 0
//        self.reloadData(searchText: text.lowercased())
//    }
    
    private lazy var searchBar: SCAddDeviceSearchView = {
        let view = SCAddDeviceSearchView { [weak self] text in
            guard let `self` = self else { return }
            self.tableView.isHidden = text.count > 0
            self.searchTableView.isHidden = text.count == 0
            self.reloadData(searchText: text.lowercased())
        }
        view.backColor = "CountryList.SearchBar.backgroundColor"
        view.placeholder = tempLocalize("搜索")
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}

extension SCCountryListViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("选择国家/地区")
        self.setupRightBarButtonItem(title: tempLocalize("确认"), action: #selector(rightBarButtonItemAction), titleColor: "CountryList.saveButton.textColor")
    }
    
    override func setupView() {
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.searchTableView)
    }
    
    override func setupLayout() {
        self.searchBar.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.topMargin)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        self.tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.searchBar.snp.bottom)
        }
        self.searchTableView.snp.makeConstraints { make in
            make.edges.equalTo(self.tableView)
        }
    }
    
    override func setupData() {
        var list: [[SCCountryModel]] = []
        let sectionModels = SCCountryModelORM.getCountryList(languageType: SCLocalize.appLanguage(), currentAb: SCUserCenter.sharedInstance.country?.ab ?? "")
        var titles: [String] = []
        
        for section in sectionModels {
            list.append(section.items)
            titles.append(section.title)
            
            if let item = section.items.first(where: { obj in
                return obj.isSelected
            }) {
                self.currentItem = item
            }
        }
        
        self.list = list
        self.tableView.set(list: self.list, headerList: sectionModels)
        
        self.tableView.set(sectionTitles: titles, color: "CountryList.SectionIndex.textColor")
    }
    
    private func reloadData(searchText text: String) {
        var items: [SCCountryModel] = []
        for section in self.list {
            for item in section {
                if item.name.range(of: text) != nil {
                    items.append(item)
                    continue
                }
                if item.name2.count > 0 && item.name2.range(of: text ) != nil {
                    items.append(item)
                }
            }
        }
        
        self.searchList = items
        self.searchTableView.set(list: [self.searchList])
    }
    
    @objc private func rightBarButtonItemAction() {
        guard let item = self.currentItem else { return }
        SCUserCenter.sharedInstance.country = item
        self.navigationController?.popViewController(animated: true)
        
        SCUserCenter.sharedInstance.set(zone: item.ab)
    }
}
