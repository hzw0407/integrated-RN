//
//  SCResetDeviceViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/14.
//

import UIKit

class SCResetDeviceViewController: SCBasicViewController {

    var product: SCNetResponseProductModel?
    
    var viewModel: SCAddDeviceViewModel?
    
    private var isShowGuide: Bool = false
    
    private lazy var coverImageView: UIImageView = UIImageView(image: "HomePage.AddDeviceController.ResetDeviceController.coverImage", contentMode: .scaleAspectFit)
    
    private lazy var contentLabel: UILabel = UILabel(text: tempLocalize("长按“电源+回充”按键7秒，直至听到“进入网络配置”"), textColor: "HomePage.AddDeviceController.ResetDeviceController.contentLabel.textColor", font: "HomePage.AddDeviceController.ResetDeviceController.contentLabel.font", numberLines: 0, alignment: .center)
    
    private lazy var selectButton: UIButton = {
        let btn = UIButton(tempLocalize("我已长按按钮直至黄灯闪烁"), titleColor: "HomePage.AddDeviceController.ResetDeviceController.selectButton.textColor", font: "HomePage.AddDeviceController.ResetDeviceController.selectButton.font", target: self, action: #selector(selectButtonAction))
        btn.theme_setImage("HomePage.AddDeviceController.ResetDeviceController.selectButton.normalImage", forState: .normal)
        btn.theme_setImage("HomePage.AddDeviceController.ResetDeviceController.selectButton.selectImage", forState: .selected)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        return btn
    }()
    
    private lazy var nextButton: UIButton = {
        let btn = UIButton(tempLocalize("下一步"), titleColor: "HomePage.AddDeviceController.ResetDeviceController.nextButton.textColor", font: "HomePage.AddDeviceController.ResetDeviceController.nextButton.font", target: self, action: #selector(nextButtonAction), backgroundColor: "HomePage.AddDeviceController.ResetDeviceController.nextButton.backgroundColor", cornerRadius: 12)
        btn.theme_setTitleColor("HomePage.AddDeviceController.ResetDeviceController.nextButton.disabledTextColor", forState: .disabled)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.isShowGuide = false
    }
}

extension SCResetDeviceViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("重置设备")
    }
    
    override func setupView() {
        self.view.addSubview(self.coverImageView)
        self.view.addSubview(self.contentLabel)
        self.view.addSubview(self.selectButton)
        self.view.addSubview(self.nextButton)
    }
    
    override func setupLayout() {
        let height: CGFloat = (300) / 375 * kSCScreenWidth
        self.coverImageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
            make.height.equalTo(height)
        }
        self.contentLabel.snp.makeConstraints { make in
            make.top.equalTo(self.coverImageView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(73)
        }
        self.selectButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.nextButton.snp.top).offset(-20)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        self.nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-36)
        }
    }
    
    override func setupData() {
        self.refreshNextButton()
        
        self.viewModel?.loadProductInfo(id: self.product?.id ?? "") { [weak self] info in
            guard let `self` = self else { return }
            guard let info = info else { return }
            self.product?.info = info
            self.coverImageView.sd_setImage(with: URL(string: info.guideUrl), completed: nil)
            self.contentLabel.text = info.guideDesc
        }
    }
    
    private func refreshNextButton() {
        self.nextButton.isEnabled = self.selectButton.isSelected
        if self.nextButton.isEnabled {
            self.nextButton.theme_backgroundColor = "HomePage.AddDeviceController.ResetDeviceController.nextButton.backgroundColor"
        }
        else {
            self.nextButton.theme_backgroundColor = "HomePage.AddDeviceController.ResetDeviceController.nextButton.disableBackgroundColor"
        }
    }
}

extension SCResetDeviceViewController {
    @objc private func selectButtonAction() {
        self.selectButton.isSelected = !self.selectButton.isSelected
        self.refreshNextButton()
    }
    
    @objc private func nextButtonAction() {
        let vc = SCSelectWorkWifiViewController()
        vc.product = self.product
        if !self.isShowGuide {
            self.isShowGuide = true
            if SCBindDeviceBluetoothService.shared.bleState != .poweredOn {
                SCAddDeviceAutoSearchBluetoothGuideView.show(hasAuth: SCBindDeviceBluetoothService.shared.bleState != .unauthorized) {
                    let url = URL(string: UIApplication.openSettingsURLString)!
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            return
        }
        self.product?.isBluetoothCommunication = (product?.communicationType == .wifiAndBluetooth || product?.communicationType == .bluetooth) && SCBindDeviceBluetoothService.shared.bleState == .poweredOn
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
