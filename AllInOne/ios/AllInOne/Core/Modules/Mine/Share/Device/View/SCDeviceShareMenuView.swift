//
//  SCDeviceShareMenuView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/29.
//

import UIKit

class SCDeviceShareMenuView: SCBasicView {
    
    var type: SCDeviceShareMenuType = .share {
        didSet {
            self.reloadData()
        }
    }
    
    private var didSelectBlock: ((SCDeviceShareMenuType) -> Void)?

    private lazy var cornerView: UIView = UIView(backgroundColor: "Mine.DeviceShareController.MenuView.backgroundColor", cornerRadius: 12)
    
    private lazy var shareButton: UIButton = UIButton(tempLocalize("共享"), titleColor: "Mine.DeviceShareController.MenuView.Item.textColor", font: "Mine.DeviceShareController.MenuView.Item.font", target: self, action: #selector(shareButtonAction), selectedTitleColor: "Mine.DeviceShareController.MenuView.Item.selectedTextColor", backgroundColor: "Mine.DeviceShareController.MenuView.Item.backgroundColor", cornerRadius: 12)
    
    private lazy var acceptButton: UIButton = UIButton(tempLocalize("接收"), titleColor: "Mine.DeviceShareController.MenuView.Item.textColor", font: "Mine.DeviceShareController.MenuView.Item.font", target: self, action: #selector(acceptButtonAction), selectedTitleColor: "Mine.DeviceShareController.MenuView.Item.selectedTextColor", backgroundColor: "Mine.DeviceShareController.MenuView.Item.backgroundColor", cornerRadius: 12)
    
    convenience init(didSelectHandle: ((SCDeviceShareMenuType) -> Void)?) {
        self.init()
        self.didSelectBlock = didSelectHandle
    }
}

extension SCDeviceShareMenuView {
    override func setupView() {
        self.addSubview(self.cornerView)
        self.cornerView.addSubview(self.shareButton)
        self.cornerView.addSubview(self.acceptButton)
        self.reloadData()
    }
    
    override func setupLayout() {
        self.cornerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(40)
            make.top.bottom.equalToSuperview().inset(12)
        }
        self.shareButton.snp.makeConstraints { make in
            make.left.bottom.top.equalToSuperview().inset(4)
        }
        self.acceptButton.snp.makeConstraints { make in
            make.right.bottom.top.equalToSuperview()
            make.width.equalTo(self.shareButton)
            make.left.equalTo(self.shareButton.snp.right)
        }
    }
    
    @objc private func shareButtonAction() {
        self.didSelectBlock?(.share)
    }
    
    @objc private func acceptButtonAction() {
        self.didSelectBlock?(.accept)
    }
    
    private func reloadData() {
        self.shareButton.isSelected = self.type == .share
        self.acceptButton.isSelected = self.type == .accept
        if self.type == .share {
            self.shareButton.theme_backgroundColor = "Mine.DeviceShareController.MenuView.Item.selectedBackgroundColor"
            self.acceptButton.theme_backgroundColor = "Mine.DeviceShareController.MenuView.Item.backgroundColor"
        }
        else {
            self.shareButton.theme_backgroundColor = "Mine.DeviceShareController.MenuView.Item.backgroundColor"
            self.acceptButton.theme_backgroundColor = "Mine.DeviceShareController.MenuView.Item.selectedBackgroundColor"
        }
    }
}
