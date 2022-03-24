//
//  SCDeviceShareAddViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/29.
//

import UIKit

class SCDeviceShareAddViewController: SCBasicViewController {

    var devices: [SCNetResponseDeviceModel] = []
    
    private lazy var viewModel: SCDeviceShareAddViewModel = SCDeviceShareAddViewModel()
    
    private lazy var titleLabel: UILabel = UILabel(textColor: "Mine.DeviceShareController.AddController.titleLabel.textColor", font: "Mine.DeviceShareController.AddController.titleLabel.font", numberLines: 0)
    
    private lazy var collectionView: SCBasicCollectionView = {
        let layout = UICollectionViewFlowLayout()
        let itemWidth: CGFloat = 68
        let spacing: CGFloat = 20
        let horizontalMargin = (kSCScreenWidth - itemWidth * 3 - spacing * 2) / 2
        let verticalMargin: CGFloat = 0
        
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: verticalMargin, left: horizontalMargin, bottom: verticalMargin, right: horizontalMargin)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        let collectionView = SCBasicCollectionView(cellClass: SCDeviceShareAddItemCell.self, cellIdendify: SCDeviceShareAddItemCell.identify, layout: layout)
        return collectionView
    }()
    
    private lazy var textField: SCTextField = {
        let textField = SCTextField {
            
        } textDidChangeHandle: { [weak self] text in
            self?.refreshShareButton()
        }
        
        textField.placeholder = tempLocalize("请输入对方用户名")
        return textField
    }()
    
    private lazy var shareButton: UIButton = UIButton(tempLocalize("共享设备"), titleColor: "Mine.DeviceShareController.AddController.shareButton.textColor", font: "Mine.DeviceShareController.AddController.shareButton.font", target: self, action: #selector(shareButtonAction), disabledTitleColor: "Mine.DeviceShareController.AddController.shareButton.disabledTextColor", backgroundColor: "Mine.DeviceShareController.AddController.shareButton.backgroundColor", cornerRadius: 12)

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension SCDeviceShareAddViewController {
    override func setupView() {
        self.title = tempLocalize("添加共享")
        
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.collectionView)
        self.view.addSubview(textField)
        self.view.addSubview(self.shareButton)
        
        self.refreshShareButton()
    }
    
    override func setupLayout() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(self.view.snp.topMargin).offset(20)
        }
        self.collectionView.snp.makeConstraints { make in
            make.width.equalTo(kSCScreenWidth)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(40)
            make.height.equalTo(68)
        }
        self.textField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(self.collectionView.snp.bottom).offset(50)
            make.height.equalTo(56)
        }
        self.shareButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-36)
            make.height.equalTo(56)
        }
    }
    
    override func setupData() {
        let imageUrls = self.devices.map{ return $0.photoUrl }
        let names = self.devices.map{ return $0.nickname }
        self.titleLabel.text = names.joined(separator: tempLocalize("、"))
        self.collectionView.set(list: [imageUrls])
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            guard let `self` = self else { return }
            let rows = CGFloat((self.devices.count - 1) / 3 + 1)
            var height = 68 * rows + 20 * (rows - 1)
            let sum: CGFloat = 36 + 56 + 40 + 56 + 50 + 40
            let maxHeight = self.view.bounds.height - self.titleLabel.frame.maxY - sum
            if height > maxHeight {
                height = maxHeight
            }
            var width = kSCScreenWidth
            if self.devices.count < 3 {
                width = kSCScreenWidth - CGFloat(3 - self.devices.count) * (68 + 20)
            }
            self.collectionView.snp.updateConstraints { make in
                make.height.equalTo(height)
                make.width.equalTo(width)
            }
        }
    }
    
    private func refreshShareButton() {
        if let text = self.textField.text, text.count > 0 {
            self.shareButton.isEnabled = true
            self.shareButton.theme_backgroundColor = "Mine.DeviceShareController.AddController.shareButton.backgroundColor"
        }
        else {
            self.shareButton.isEnabled = false
            self.shareButton.theme_backgroundColor = "Mine.DeviceShareController.AddController.shareButton.disabledBackgroundColor"
        }
    }
    
    @objc private func shareButtonAction() {
        guard let text = self.textField.text else { return }
        let deviceIds = self.devices.map { return $0.deviceId }
        self.viewModel.shareDevices(deviceIds: deviceIds, toUsername: text) { [weak self] in
            guard let `self` = self else { return }
            let viewControllers = self.navigationController?.viewControllers ?? []
            for vc in viewControllers.reversed() {
                if vc is SCDeviceShareListViewController {
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
        }
    }
}


