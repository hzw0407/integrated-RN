//
//  SCAddDeviceSearchViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/14.
//

import UIKit

class SCAddDeviceSearchViewController: SCBasicViewController {

    var parents: [SCNetResponseProductTypeParentModel] = []
        
    private var searchList: [SCNetResponseProductModel] = []
    
    private var backButton: UIButton = UIButton(image: "Global.NavigationBackItem.image", target: self, action: #selector(backBarButtonAction))
    
    private lazy var searchBar = SCAddDeviceSearchView { text in
        self.tableView.isHidden = text.count == 0
        self.reloadData(searchText: text.lowercased())
    }
    
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCAddDeviceSearchItemCell.self, cellIdendify: SCAddDeviceSearchItemCell.identify, rowHeight: 74) { indexPath in
            let item = self.searchList[indexPath.row]
            let vc = SCResetDeviceViewController()
            vc.product = item
            self.navigationController?.pushViewController(vc, animated: true)
        }
        tableView.add {
            self.view.endEditing(true)
        }
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

extension SCAddDeviceSearchViewController {
    override func setupView() {
        self.view.addSubview(self.backButton)
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.tableView)
    }
    
    override func setupLayout() {
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.top.equalTo(self.view.snp.topMargin).offset(2)
        }
        self.searchBar.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.topMargin).offset(2)
            make.left.equalTo(self.backButton.snp.right)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        self.tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.searchBar.snp.bottom)
        }
    }
    
    private func reloadData(searchText text: String) {
        var searchItems: [SCNetResponseProductModel] = []
        for parent in self.parents {
            for middle in parent.items {
                for item in middle.items {
                    if item.name.lowercased().range(of: text) != nil {
                        searchItems.append(item)
                    }
                }
            }
        }
        
        self.searchList = searchItems
        self.tableView.set(list: [self.searchList])
    }
}
