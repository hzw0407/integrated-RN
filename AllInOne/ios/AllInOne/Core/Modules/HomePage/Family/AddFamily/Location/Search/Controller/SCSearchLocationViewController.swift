//
//  SCSearchLocationViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/21.
//

import UIKit
import AMapSearchKit

class SCSearchLocationViewController: SCBasicViewController {

    var key: String = ""
    
    private var searchDoneBlock: ((SCSearchLocationItemModel) -> Void)?
    
    private var list: [SCSearchLocationItemModel] = []
    
    private lazy var search: AMapSearchAPI? = {
        let search = AMapSearchAPI()
        search?.delegate = self
        return search
    }()
    
    private lazy var request: AMapInputTipsSearchRequest = AMapInputTipsSearchRequest()
    
    private var geo: AMapGeocodeSearchRequest = AMapGeocodeSearchRequest()
    
    private lazy var searchView: SCSearchLocationView = SCSearchLocationView { [weak self] text in
        self?.key = text
        self?.searchKey()
    }
    
    private lazy var tableView: SCBasicTableView = SCBasicTableView(cellClass: SCSearchLoactionItemCell.self, cellIdendify: SCSearchLoactionItemCell.identify, rowHeight: nil) { [weak self] indexPath in
        guard let `self` = self, self.list.count > indexPath.row else { return }
        let item = self.list[indexPath.row]
        self.searchDoneBlock?(item)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func add(searchDoneHandle: ((SCSearchLocationItemModel) -> Void)?) {
        self.searchDoneBlock = searchDoneHandle
    }
}

extension SCSearchLocationViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("搜索位置")
    }
    
    override func setupView() {
        self.view.addSubview(self.searchView)
        self.view.addSubview(self.tableView)
    }
    
    override func setupLayout() {
        self.searchView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.top.equalTo(self.view.snp.topMargin).offset(12)
        }
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.searchView.snp.bottom).offset(12)
        }
    }
    
    override func setupData() {
        self.searchView.text = self.key
    }
    
    private func searchKey() {
        self.request.keywords = self.key
        
        self.search?.aMapInputTipsSearch(self.request)
    }
}

extension SCSearchLocationViewController: AMapSearchDelegate {
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        
    }
    
    func onInputTipsSearchDone(_ request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!) {
        if response.count == 0 { return }
        
        var items: [SCSearchLocationItemModel] = []
        for tip in response.tips {
            let item = SCSearchLocationItemModel()
            item.title = tip.name
            item.content = tip.address
            if let location = tip.location {
                item.location.latitude = location.latitude
                item.location.longitude = location.longitude
                item.location.address = tip.address
            }
            items.append(item)
        }
        self.list = items
        self.tableView.set(list: [self.list])
    }
}
