//
//  SCAddDeviceViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/14.
//

import UIKit

class SCAddDeviceViewController: SCBasicViewController {
    
    private let viewModel = SCAddDeviceViewModel()
    
    private var searchItems: [SCNetResponseProductModel] = []
    
    private lazy var autoSearchTitleView: SCAddDeviceAutoSearchTitleView = SCAddDeviceAutoSearchTitleView()
    
    private lazy var autoSearchView: SCAddDeviceAutoSearchView = SCAddDeviceAutoSearchView { [weak self] in
        let vc = SCScanNoneViewController()
        self?.navigationController?.pushViewController(vc, animated: true)
    } didSelectItemHandle: { [weak self] item in
        let vc = SCResetDeviceViewController()
        vc.product = item
        self?.navigationController?.pushViewController(vc, animated: true)
    }

    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
    private lazy var productListView: SCAddDeviceProductListView = SCAddDeviceProductListView { [weak self] item in
        if item.name.count == 0 && item.id.count == 0 {
            return
        }
        let vc = SCResetDeviceViewController()
        vc.product = item
        vc.viewModel = self?.viewModel
        self?.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.autoSearchTitleView.startAnimation()
        if self.viewModel.products.count > 0 {
            self.startScanDevices()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.stopScanDevices()
    }
}

extension SCAddDeviceViewController {
    override func backBarButtonAction() {
        self.viewModel.stopScan()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func setupNavigationBar() {
        self.title = tempLocalize("添加设备")
        self.addRightBarButtonItem(image: "HomePage.AddDeviceController.NavigationBar.scanCodeButton.image", action: #selector(scanCodeButtonAction))
        self.addRightBarButtonItem(image: "HomePage.AddDeviceController.NavigationBar.searchButton.image", action: #selector(searchButtonAction))
    }
    
    override func setupView() {
        self.view.addSubview(self.autoSearchTitleView)
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.autoSearchView)
        self.view.addSubview(self.productListView)
    }
    
    override func setupLayout() {
        self.autoSearchTitleView.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.topMargin)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        self.scrollView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.autoSearchTitleView.snp.bottom)
        }
        self.autoSearchView.snp.makeConstraints { make in
            make.left.top.equalTo(self.scrollView)
            make.width.equalTo(kSCScreenWidth)
            make.height.equalTo(self.autoSearchView.height)
        }
        self.productListView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(kSCScreenWidth)
            make.top.equalTo(self.autoSearchView.snp.bottom).offset(20)
        }
    }
    
    override func setupObservers() {
        kAddObserver(self, #selector(willEnterForegroundNotification), UIApplication.willEnterForegroundNotification.rawValue)
    }
    
    override func setupData() {
        self.reloadSearchData()
        
        self.viewModel.loadData { [weak self] in
            guard let `self` = self else { return }
            self.productListView.reload(parents: self.viewModel.parents)
            self.startScanDevices()
        }
    }
    
    private func startScanDevices() {
        self.viewModel.startScanDevices { [weak self] state in
            guard let `self` = self else { return }
            self.autoSearchView.state = state
        } discoverDeviceHandle: { [weak self] items in
            guard let `self` = self else { return }
            self.searchItems = items
            self.reloadSearchData()
        }
    }
    
    private func stopScanDevices() {
        self.viewModel.stopScan()
    }
}

extension SCAddDeviceViewController {
    private func reloadSearchData() {
        #if DEBUG
        var items = [SCNetResponseProductModel]()
        let c_titles = ["DM2 wifi", "M1 BLE", "扫拖机器人260 BLE", "扫拖机器人M1S wifi", "扫拖机器人280 BLE", "DFK", "时刻记得了房间"]
        for c_title in c_titles {
            let child = SCNetResponseProductModel()
            child.name = c_title
            child.dmsPrefix = "i"
            child.photoUrl = "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fsy0.img.it168.com%2Fcopy%2Ffawen8%2F3%2F3307%2F3307696%2F3%2F3307%2F3307696.jpg&refer=http%3A%2F%2Fsy0.img.it168.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1642055305&t=12e95945d42da111339693b7c47c5d7f"
            items.append(child)
        }
//        self.searchItems = items
        #endif
        
        self.autoSearchView.reload(items: self.searchItems)
        self.autoSearchTitleView.count = self.searchItems.count
        let searchTitleHeight: CGFloat = 50
        let searchViewHeight = self.autoSearchView.height
        let listHeight = kSCScreenHeight - kSCNavAndStatusBarHeight - searchTitleHeight
        let height = searchViewHeight + listHeight
        self.scrollView.contentSize = CGSize(width: kSCScreenWidth, height: height)
    }
}

extension SCAddDeviceViewController {
    @objc private func searchButtonAction() {
        let vc = SCAddDeviceSearchViewController()
        vc.parents = self.viewModel.parents
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func scanCodeButtonAction() {
        let vc = SCQRCodeScanViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func willEnterForegroundNotification() {
        self.autoSearchTitleView.startAnimation()
    }
}
