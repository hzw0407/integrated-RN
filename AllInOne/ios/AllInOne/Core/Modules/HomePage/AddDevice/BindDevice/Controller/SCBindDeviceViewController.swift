//
//  SCBindDeviceViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/3.
//

import UIKit
import WCDBSwift
import CoreBluetooth

let kBindDeviceSuccessNotificationKey = "kBindDeviceSuccessNotificationKey"

class SCBindDeviceViewController: SCBasicViewController {
    var product: SCNetResponseProductModel?
    var config: SCBindDeviceConfig?
    var peripheral: CBPeripheral?
    
    private var supportBluetooth: Bool {
        return self.product != nil && self.product!.isBluetoothCommunication
    }
    
    private var currentSteps: [SCBindDeviceStepModel] = []
    private var allSteps: [SCBindDeviceStepModel] = []
    
    private lazy var coverImageView: UIImageView = UIImageView(image: "HomePage.AddDeviceController.BindDeviceController.coverImage", contentMode: .scaleAspectFit)
    
    private lazy var instructionLabel: UILabel = UILabel(text: tempLocalize("正在连接，请将设备尽量靠近路由器"), textColor: "HomePage.AddDeviceController.BindDeviceController.instructionLabel.textColor", font: "HomePage.AddDeviceController.BindDeviceController.instructionLabel.font", numberLines: 0, alignment: .center)
    
    private lazy var lineView: UIView = UIView(lineBackgroundColor: "omePage.AddDeviceController.BindDeviceController.lineBackgroundColor")
    
    private lazy var tableView: SCBasicTableView = SCBasicTableView(cellClass: SCBindDeviceStepCell.self, cellIdendify: SCBindDeviceStepCell.identify, rowHeight: nil, cellDelegate: self)
    
    private var apBindStep: SCBindDeviceAccessPointStep = .none {
        didSet {
            self.reloadAcceptPointData()
        }
    }
    private var apResultType: SCBindDeviceAccessPointResultType? {
        didSet {
            self.reloadAcceptPointData()
        }
    }
    
    private var bleBindStep: SCBindDeviceBluetoothStep = .none {
        didSet {
            self.reloadBluetoothData()
        }
    }
    
    private var bleResultType: SCBindDeviceAccessPointResultType? {
        didSet {
            self.reloadBluetoothData()
        }
    }
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.theme_textColor = "Login.InputCell.textField.textColor"
        textView.theme_font = "Login.InputCell.textField.font"
//        textField.delegate = self
        textView.isEditable = false
        textView.isHidden = true
        return textView
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.startBindDevice()
    }
}

extension SCBindDeviceViewController {
    override func backBarButtonAction() {
        self.stop()
        if let viewControllers = self.navigationController?.viewControllers {
            for vc in viewControllers {
                if vc.isKind(of: SCAddDeviceViewController.self) {
                    self.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    override func setupNavigationBar() {
        self.title = tempLocalize("添加设备")
    }
    
    override func setupView() {
        self.view.addSubview(self.coverImageView)
        self.view.addSubview(self.instructionLabel)
        self.view.addSubview(self.lineView)
        self.view.addSubview(self.tableView)
        
        self.view.addSubview(self.textView)
    }
    
    override func setupLayout() {
        let height = 300 / 375 * kSCScreenWidth
        self.coverImageView.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.topMargin)
            make.left.right.equalToSuperview()
            make.height.equalTo(height)
        }
        self.instructionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(40)
            make.top.equalTo(self.coverImageView.snp.bottom).offset(40)
        }
        self.lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(40)
            make.top.equalTo(self.instructionLabel.snp.bottom).offset(27)
            make.height.equalTo(0.5)
        }
        self.tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.lineView.snp.bottom).offset(30 - 8)
        }
        
        self.textView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(self.view.snp.topMargin).offset(20)
            make.bottom.equalTo(self.view.snp.bottom).offset(-20)
        }
    }
    
    override func setupObservers() {
        kAddObserver(self, #selector(applicationDidEnterForegroundNotification), UIApplication.willEnterForegroundNotification.rawValue)
        kAddObserver(self, #selector(reachabilityStatusChangedNotification), SCNetworkReachabilityStatusChangedNotificationKey)
    }
    
    override func setupData() {
        let types: [SCBindDeviceStepType] = [.connectDevice, .sendDataToDevice, .deviceConnectNet]
        for type in types {
            let model = SCBindDeviceStepModel()
            model.type = type
            self.allSteps.append(model)
        }
    }
    
    private func startBindDevice() {
        if self.supportBluetooth {
            self.startBindDeviceByBluetooth()
        }
        else {
            self.startBindDeviceByAccessPoint()
        }
    }
    
    private func stop() {
        if self.supportBluetooth {
            SCBindDeviceBluetoothService.shared.stop()
        }
        else {
            SCBindDeviceAccessPointService.shared.stop()
        }
    }
    
    private func bindSuccess(type: SCBindDeviceCommunicationType) {
        var json: [String: Any] = [:]
        if type == .accessPoint {
            json = ["sn": SCBindDeviceAccessPointService.shared.sn, "deviceId": SCBindDeviceAccessPointService.shared.deviceId, "productId": SCBindDeviceAccessPointService.shared.productId]
        }
        else if type == .bluetooth {
            json = ["sn": SCBindDeviceBluetoothService.shared.sn, "deviceId": SCBindDeviceBluetoothService.shared.deviceId, "productId": SCBindDeviceBluetoothService.shared.productId]
        }
        kPostNotification(kBindDeviceSuccessNotificationKey, userInfo: json)
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension SCBindDeviceViewController {
    @objc private func applicationDidEnterForegroundNotification() {
        self.startBindDevice()
    }
    
    @objc private func reachabilityStatusChangedNotification() {
        
    }
}

// MARK: - AccessPoint
extension SCBindDeviceViewController {
    private func startBindDeviceByAccessPoint() {
        if self.apBindStep != .none { return }
        if let config = self.config {
            // let ssid = SCLocalNetwork.sharedInstance.getSsid(), ssid.count > 0
            SCBindDeviceAccessPointService.shared.start(config: config) { [weak self] step in
                guard let `self` = self else { return }
                self.apBindStep = step
                self.textView.text = "step: " + step.name + "\n" + self.textView.text
            } completionHandler: { [weak self] result in
                guard let `self` = self else { return }
                self.apResultType = result
                switch result {
                case .success:
                    SCProgressHUD.showHUD("绑定成功")
                    self.textView.text = "result: " + "success" + "\n" + self.textView.text
                    
                    self.bindSuccess(type: .accessPoint)
                    
                    break
                case .timeout:
                    SCProgressHUD.showHUD("绑定超时")
                    self.textView.text = "result: " + "bind timeout" + "\n" + self.textView.text
                    break
                case .connectWithDeviceTimeout:
                    SCProgressHUD.showHUD("连接设备超时")
                    self.textView.text = "result: " + "connect device timeout" + "\n" + self.textView.text
                    break
                case .interrupt:
                    SCProgressHUD.showHUD("绑定中断")
                    self.textView.text = "result: " + "interrupt" + "\n" + self.textView.text
                    break
                }
            } timeHandler: { [weak self] text in
                guard let `self` = self else { return }
                self.textView.text = text + "\n" + self.textView.text
            }

        }
    }
    
    private func reloadAcceptPointData() {
        self.currentSteps.removeAll()
        for model in self.allSteps {
            switch model.type {
            case .connectDevice:
                if self.apBindStep.rawValue < SCBindDeviceAccessPointStep.connectedWidthDevice.rawValue {
                    if self.apResultType == nil {
                        model.status = .loading
                    }
                    else {
                        model.status = .fail
                    }
                }
                else {
                    model.status = .success
                }
                self.currentSteps.append(model)
                break
            case .sendDataToDevice:
                if self.apBindStep.rawValue < SCBindDeviceAccessPointStep.receivedData.rawValue {
                    if self.apResultType == nil {
                        model.status = .loading
                    }
                    else {
                        model.status = .fail
                    }
                }
                else {
                    model.status = .success
                }
                if self.apBindStep.rawValue >= SCBindDeviceAccessPointStep.connectedWidthDevice.rawValue {
                    self.currentSteps.append(model)
                }
                break
            case .deviceConnectNet:
                if self.apBindStep.rawValue < SCBindDeviceAccessPointStep.success.rawValue {
                    if self.apResultType == nil {
                        model.status = .loading
                    }
                    else {
                        model.status = .fail
                    }
                }
                else {
                    model.status = .success
                }
                if self.apBindStep.rawValue >= SCBindDeviceAccessPointStep.receivedData.rawValue {
                    self.currentSteps.append(model)
                }
                break
            }
        }
        self.tableView.set(list: [self.currentSteps])
    }
}

// MARK: - Bluetooth
extension SCBindDeviceViewController {
    private func startBindDeviceByBluetooth() {
        guard let peripheral = self.peripheral, let config = self.config else { return }
        SCBindDeviceBluetoothService.shared.connect(config: config, peripheral: peripheral) {  [weak self] step in
            guard let `self` = self else { return }
            self.bleBindStep = step
            self.textView.text = "step: " + step.name + "\n" + self.textView.text
        } completionHandler: { [weak self] result in
            guard let `self` = self else { return }
            self.bleResultType = result
            switch result {
            case .success:
                SCProgressHUD.showHUD("绑定成功")
                self.textView.text = "result: " + "success" + "\n" + self.textView.text
                
                self.bindSuccess(type: .bluetooth)
                
                break
            case .timeout:
                SCProgressHUD.showHUD("绑定超时")
                self.textView.text = "result: " + "bind timeout" + "\n" + self.textView.text
                break
            case .connectWithDeviceTimeout:
                SCProgressHUD.showHUD("连接设备超时")
                self.textView.text = "result: " + "connect device timeout" + "\n" + self.textView.text
                break
            case .interrupt:
                SCProgressHUD.showHUD("绑定中断")
                self.textView.text = "result: " + "interrupt" + "\n" + self.textView.text
                break
            }
        } timeHandler: { [weak self] text in
            guard let `self` = self else { return }
            self.textView.text = text + "\n" + self.textView.text
        }

    }
    
    private func reloadBluetoothData() {
        self.currentSteps.removeAll()
        for model in self.allSteps {
            switch model.type {
            case .connectDevice:
                if self.bleBindStep.rawValue < SCBindDeviceBluetoothStep.connectedWidthDevice.rawValue {
                    if self.bleResultType == nil {
                        model.status = .loading
                    }
                    else {
                        model.status = .fail
                    }
                }
                else {
                    model.status = .success
                }
                self.currentSteps.append(model)
                break
            case .sendDataToDevice:
                if self.bleBindStep.rawValue < SCBindDeviceBluetoothStep.receivedData.rawValue {
                    if self.bleResultType == nil {
                        model.status = .loading
                    }
                    else {
                        model.status = .fail
                    }
                }
                else {
                    model.status = .success
                }
                if self.bleBindStep.rawValue >= SCBindDeviceBluetoothStep.connectedWidthDevice.rawValue {
                    self.currentSteps.append(model)
                }
                break
            case .deviceConnectNet:
                if self.bleBindStep.rawValue < SCBindDeviceBluetoothStep.success.rawValue {
                    if self.bleResultType == nil {
                        model.status = .loading
                    }
                    else {
                        model.status = .fail
                    }
                }
                else {
                    model.status = .success
                }
                if self.bleBindStep.rawValue >= SCBindDeviceBluetoothStep.receivedData.rawValue {
                    self.currentSteps.append(model)
                }
                break
            }
        }
        self.tableView.set(list: [self.currentSteps])
    }
}

extension SCBindDeviceViewController: SCBindDeviceStepCellDelegate {
    func cell(didTapReason cell: SCBindDeviceStepCell) {
        let vc = SCBindDeviceFailReasonViewController()
        vc.product = self.product
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
