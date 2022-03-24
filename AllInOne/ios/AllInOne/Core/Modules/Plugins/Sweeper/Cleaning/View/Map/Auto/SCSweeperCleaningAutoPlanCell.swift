//
//  SCSweeperCleaningAutoPlanCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/2/16.
//

import UIKit

private let progressViewWidth: CGFloat = kSCScreenWidth / 2 - 30 - 20 - 10

class SCSweeperCleaningAutoPlanCell: SCBasicTableViewCell {

    private lazy var coverImageView: UIImageView = UIImageView()
    
    private lazy var titleLabel: UILabel = UILabel(textColor: "PluginSweeperTheme.CleaningViewController.MapView.AutoPlanView.ItemCell.titleLabel.textColor", font: "PluginSweeperTheme.CleaningViewController.MapView.AutoPlanView.ItemCell.titleLabel.font")
    
    private lazy var levelLabel: UILabel = UILabel(textColor: "PluginSweeperTheme.CleaningViewController.MapView.AutoPlanView.ItemCell.levelLabel.textColor", font: "PluginSweeperTheme.CleaningViewController.MapView.AutoPlanView.ItemCell.levelLabel.font", alignment: .right)
    
    private lazy var progressView: SCSweeperProgressView = SCSweeperProgressView(progressFromColor: "PluginSweeperTheme.CleaningViewController.MapView.AutoPlanView.ItemCell.progressView.progressFromColor", progressToColor: "PluginSweeperTheme.CleaningViewController.MapView.AutoPlanView.ItemCell.progressView.progressToColor", trackColor: "PluginSweeperTheme.CleaningViewController.MapView.AutoPlanView.ItemCell.progressView.trackColor", size: CGSize(width: progressViewWidth, height: 10), cornerRadius: 5)
    
    override func set(model: Any?) {
        guard let item = model as? SCSweeperCleaningAutoPlanItem else { return }
        self.coverImageView.theme_image = item.coverImage
        self.titleLabel.text = item.title
        self.levelLabel.text = String(item.percent)
        self.progressView.progress = CGFloat(item.percent) / 100
    }
}

extension SCSweeperCleaningAutoPlanCell {
    override func setupView() {
        self.contentView.addSubview(self.coverImageView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.levelLabel)
        self.contentView.addSubview(self.progressView)
    }
    
    override func setupLayout() {
        self.coverImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.coverImageView.snp.right).offset(5)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(self.levelLabel.snp.left).offset(-5)
        }
        self.levelLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.right.equalTo(self.progressView.snp.left).offset(-5)
            make.width.equalTo(30)
        }
        self.progressView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-30)
            make.centerY.equalToSuperview()
            make.height.equalTo(10)
            make.width.equalTo(progressViewWidth)
        }
    }
}
