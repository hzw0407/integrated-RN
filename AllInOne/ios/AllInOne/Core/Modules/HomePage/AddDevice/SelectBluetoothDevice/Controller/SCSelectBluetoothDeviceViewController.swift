//
//  SCSelectBluetoothDeviceViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/16.
//

import UIKit

class SCSelectBluetoothDeviceViewController: SCBasicViewController {
    var config: SCBindDeviceConfig?
    var product: SCNetResponseProductModel?
    
    private var isPushToNext: Bool = false
    
    private let viewModel: SCSelectBluetoothDeviceViewModel = SCSelectBluetoothDeviceViewModel()
    
    private var scanTimer: Timer?
    private var startScanTime: TimeInterval = 0
    
    private lazy var progressView: UIProgressView = {
        let progress = UIProgressView()
        progress.theme_backgroundColor = "HomePage.AddDeviceController.SelectBluetoothDeviceController.progressView.backgroundColor"
        progress.theme_progressTintColor = "HomePage.AddDeviceController.SelectBluetoothDeviceController.progressView.progressTintColor"
        return progress
    }()
    
    private lazy var scanAgainButton: UIButton = UIButton(tempLocalize("再次扫描"), titleColor: "HomePage.AddDeviceController.SelectBluetoothDeviceController.scanAgainButton.textColor", font: "HomePage.AddDeviceController.SelectBluetoothDeviceController.scanAgainButton.font", target: self, action: #selector(scanAgainButtonAction), disabledTitleColor: "HomePage.AddDeviceController.SelectBluetoothDeviceController.scanAgainButton.disabledTextColor", backgroundColor: "HomePage.AddDeviceController.SelectBluetoothDeviceController.scanAgainButton.backgroundColor", cornerRadius: 12)
    
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCSelectBluetoothDeviceCell.self, cellIdendify: SCSelectBluetoothDeviceCell.identify, rowHeight: nil) { [weak self] indexPath in
            guard let `self` = self, self.viewModel.devices.count > indexPath.row else { return }
            let device = self.viewModel.devices[indexPath.row]
            self.pushToNext(device: device)
        }
        tableView.add { [weak self] in
            self?.view.endEditing(true)
        }
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isPushToNext = false
        self.startScan()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.stopScan()
    }
}

extension SCSelectBluetoothDeviceViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("添加蓝牙设备")
    }
    
    override func setupView() {
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.progressView)
        self.view.addSubview(self.scanAgainButton)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
            make.bottom.equalTo(self.scanAgainButton.snp.top).offset(-10)
        }
        self.progressView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
            make.height.equalTo(2)
        }
        self.scanAgainButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-36)
            make.height.equalTo(56)
        }
    }
    
    private func startScan() {
        self.viewModel.product = self.product
        
        self.viewModel.startScanDevices { state in
            
        } discoverDeviceHandle: { [weak self] list in
            guard let `self` = self else { return }
            self.tableView.set(list: [list])
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) { [weak self] in
            guard let `self` = self else { return }
            if self.viewModel.devices.count == 1 {
                self.pushToNext(device: self.viewModel.devices.first!)
                return
            }
        }
        
        if self.scanTimer == nil {
            let maxDuration: TimeInterval = 15
            self.startScanTime = Date().timeIntervalSince1970
            self.scanTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [weak self] _ in
                guard let `self` = self else { return }
                self.progressView.progress = Float((Date().timeIntervalSince1970 - self.startScanTime) / maxDuration)
                if Date().timeIntervalSince1970 - self.startScanTime > maxDuration {
                    self.stopScan()
                }
            })
        }
        
        self.refreshScanAgainButton(isScaning: true)
    }
    
    private func stopTimer() {
        self.scanTimer?.invalidate()
        self.scanTimer = nil
    }
    
    private func stopScan() {
        self.viewModel.stopScan()
        self.stopTimer()
        self.progressView.progress = 0
        self.refreshScanAgainButton(isScaning: false)
    }
    
    private func pushToNext(device: SCSelectBluetoothDeviceModel) {
        if isPushToNext { return }
        let vc = SCBindDeviceViewController()
        vc.product = device.product
        vc.peripheral = device.peripheral
        vc.config = self.config
        self.navigationController?.pushViewController(vc, animated: true)
        
        self.isPushToNext = true
    }
    
    private func refreshScanAgainButton(isScaning: Bool) {
        self.scanAgainButton.isEnabled = !isScaning
        if isScaning {
            self.scanAgainButton.theme_backgroundColor = "HomePage.AddDeviceController.SelectBluetoothDeviceController.scanAgainButton.disabledBackgroundColor"
        }
        else {
            self.scanAgainButton.theme_backgroundColor = "HomePage.AddDeviceController.SelectBluetoothDeviceController.scanAgainButton.backgroundColor"
        }
    }
    
    @objc private func scanAgainButtonAction() {
        self.startScan()
    }
}
