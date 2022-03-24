//
//  SCSweeperCleaningPlanTitleView.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/2/16.
//

import UIKit
import SwiftTheme

class SCSweeperCleaningPlanTitleView: SCBasicView {
    private var foldBlock: (() -> Void)?
    
    /// 图标
    private lazy var coverImageView: UIImageView = UIImageView()
    
    /// 标题
    private lazy var titleLabel: UILabel = UILabel(textColor: "PluginSweeperTheme.CleaningViewController.MapView.PlanTitleView.titleLabel.textColor", font: "PluginSweeperTheme.CleaningViewController.MapView.PlanTitleView.titleLabel.font")
    
    /// 折叠图标
    private lazy var foldImageView: UIImageView = UIImageView(image: "PluginSweeperTheme.CleaningViewController.MapView.PlanTitleView.foldImage")

    /// 展开图标
    private lazy var unfoldImageView: UIImageView = UIImageView(image: "PluginSweeperTheme.CleaningViewController.MapView.PlanTitleView.unfoldImage")
    
    /// 折叠背景view
    private lazy var foldBackgroundView: UIView = UIView(backgroundColor: "PluginSweeperTheme.CleaningViewController.MapView.PlanTitleView.foldBackgroundColor", cornerRadius: 18)
    
    private lazy var button: UIButton = UIButton(target: self, action: #selector(buttonAction))
        
    convenience init(coverImage: ThemeImagePicker, title: String, clickHandler: (() -> Void)?) {
        self.init(frame: .zero)
        self.foldBlock = clickHandler
        self.coverImageView.theme_image = coverImage
        self.titleLabel.text = title
    }
    
    /// 折叠
    func fold() {
        self.foldImageView.alpha = 1
        self.unfoldImageView.alpha = 0
        self.foldBackgroundView.alpha = 1
        self.coverImageView.snp.updateConstraints { make in
            make.left.equalToSuperview().offset(20 + 20)
        }
    }
    
    /// 展开
    func unfold() {
        self.foldImageView.alpha = 0
        self.unfoldImageView.alpha = 1
        self.foldBackgroundView.alpha = 0
        self.coverImageView.snp.updateConstraints { make in
            make.left.equalToSuperview().offset(20)
        }
    }
}

extension SCSweeperCleaningPlanTitleView {
    override func setupView() {
        self.addSubview(self.foldBackgroundView)
        self.addSubview(self.coverImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.foldImageView)
        self.addSubview(self.unfoldImageView)
        self.addSubview(self.button)
        
        self.unfoldImageView.alpha = 0
    }
    
    override func setupLayout() {
        self.foldBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.coverImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20 + 20)
            make.width.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.coverImageView.snp.right).offset(10)
            make.top.bottom.equalToSuperview()
        }
        self.foldImageView.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel.snp.right).offset(10)
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        self.unfoldImageView.snp.makeConstraints { make in
            make.edges.equalTo(self.foldImageView)
        }
        self.button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension SCSweeperCleaningPlanTitleView {
    @objc private func buttonAction() {
        self.foldBlock?()
    }
}
