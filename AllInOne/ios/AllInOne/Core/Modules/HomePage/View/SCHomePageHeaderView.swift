//
//  SCHomePageHeaderView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/13.
//

import UIKit

class SCHomePageHeaderView: SCBasicView {
    
    var familyName: String = "" {
        didSet {
//            self.familyButton.setTitle(familyName, for: .normal)
            self.familyLabel.text = self.familyName
        }
    }
    
    var notificaitonBadgeText: String? {
        didSet {
            self.notificaitonBadgeLabel.text = self.notificaitonBadgeText
        }
    }

    private lazy var familyButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(familyButtonAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var familyLabel: UILabel = {
        let label = UILabel(textColor: "HomePage.HomePageController.familyButton.textColor", font: "HomePage.HomePageController.familyButton.font")
        return label
    }()
    private lazy var familyImageView: UIImageView = UIImageView(image: "HomePage.HomePageController.familyButton.image")

    private lazy var addDeviceButton: UIButton = UIButton(image: "HomePage.HomePageController.addDeviceButton.image", target: self, action: #selector(addDeviceButtonAction), imageEdgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    
    private lazy var notificationButton: UIButton = UIButton(image: "HomePage.HomePageController.notificationButton.image", target: self, action: #selector(notificationButtonAction), imageEdgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    
    private lazy var notificaitonBadgeLabel: UILabel = {
        let label = UILabel(text: "", textColor: "HomePage.HomePageController.notificationButton.badgeColor", font: "HomePage.HomePageController.notificationButton.badgeFont", backgroundColor: "HomePage.HomePageController.notificationButton.badgeBackgroundColor", alignment: .center)
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        return label
    }()
    
    private var familyBlock: (() -> Void)?
    private var notificationBlock: (() -> Void)?
    private var addDeviceBlock: (() -> Void)?
    
    func addActions(familyHandle: (() -> Void)?, notificationHandle: (() -> Void)?, addDeviceHandle: (() -> Void)?) {
        self.familyBlock = familyHandle
        self.notificationBlock = notificationHandle
        self.addDeviceBlock = addDeviceHandle
    }
}

extension SCHomePageHeaderView {
    override func setupView() {
        self.addSubview(self.familyLabel)
        self.addSubview(self.familyImageView)
        self.addSubview(self.familyButton)
        self.addSubview(self.addDeviceButton)
        self.addSubview(self.notificationButton)
        self.notificationButton.addSubview(self.notificaitonBadgeLabel)
    }
    
    override func setupLayout() {
        self.familyLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(31)
            make.centerY.equalToSuperview()
        }
        self.familyImageView.snp.makeConstraints { make in
            make.left.equalTo(self.familyLabel.snp.right).offset(8)
            make.width.height.equalTo(20)
            make.centerY.equalTo(self.familyLabel)
            make.right.lessThanOrEqualTo(self.notificationButton.snp.left).offset(-60)
        }
        self.familyButton.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(self.familyLabel)
            make.right.equalTo(self.familyImageView)
        }
        self.addDeviceButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(34)
            make.centerY.equalToSuperview()
        }
        self.notificationButton.snp.makeConstraints { make in
            make.right.equalTo(self.addDeviceButton.snp.left).offset(-10)
            make.width.height.centerY.equalTo(self.addDeviceButton)
        }
        self.notificaitonBadgeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.notificationButton).offset(6)
            make.centerY.equalTo(self.notificationButton).offset(-6)
            make.height.equalTo(12)
        }
    }
}

extension SCHomePageHeaderView {
    @objc private func familyButtonAction() {
        self.familyBlock?()
    }
    
    @objc private func addDeviceButtonAction() {
        self.addDeviceBlock?()
    }
    
    @objc private func notificationButtonAction() {
        self.notificationBlock?()
    }
}
