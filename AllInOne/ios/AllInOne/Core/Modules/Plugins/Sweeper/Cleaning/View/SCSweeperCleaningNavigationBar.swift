//
//  SCSweeperCleaningNavigationBar.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/2/16.
//

import UIKit

class SCSweeperCleaningNavigationBar: SCBasicView {
    
    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }
    
    private var backBlock: (() -> Void)?
    private var settingsBlock: (() -> Void)?

    private lazy var backButton: UIButton = UIButton(image: "PluginSweeperTheme.CleaningViewController.NavigationBar.backButton.image", target: self, action: #selector(backButtonAction), highlightedImage: "PluginSweeperTheme.CleaningViewController.NavigationBar.backButton.highlightedImage", imageEdgeInsets: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 20))

    private lazy var titleLabel: UILabel = UILabel(textColor: "PluginSweeperTheme.CleaningViewController.NavigationBar.titleLabel.textColor", font: "PluginSweeperTheme.CleaningViewController.NavigationBar.titleLabel.font")
    
    private lazy var settingsButton: UIButton = UIButton(image: "PluginSweeperTheme.CleaningViewController.NavigationBar.settingsButton.image", target: self, action: #selector(settingsButtonAction), imageEdgeInsets: UIEdgeInsets())
    
    convenience init(backClickHandler: (() -> Void)?, settingsClickHandler: (() -> Void)?) {
        self.init(frame: .zero)
        self.backBlock = backClickHandler
        self.settingsBlock = settingsClickHandler
    }
}

extension SCSweeperCleaningNavigationBar {
    override func setupView() {
        self.addSubview(self.backButton)
        self.addSubview(self.titleLabel)
        self.addSubview(self.settingsButton)
        
        #if DEBUG
        self.settingsButton.backgroundColor = .red
        #endif
    }
    
    override func setupLayout() {
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(50)
            make.height.equalTo(44)
            make.centerY.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.backButton.snp.right).offset(0)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(self.settingsButton.snp.left).offset(-10)
        }
        self.settingsButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.width.height.centerY.equalTo(self.backButton)
        }
    }
}

extension SCSweeperCleaningNavigationBar {
    @objc private func backButtonAction() {
        self.backBlock?()
    }
    
    @objc private func settingsButtonAction() {
        self.settingsBlock?()
    }
}
