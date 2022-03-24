//
//  SCDeviceShareUserListItemCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/29.
//

import UIKit

class SCDeviceShareUserListItemCell: SCBasicTableViewCell {

    private weak var delegate: SCShareHistoryItemCellDelegate?
    
    private lazy var coverImageView: UIImageView = UIImageView(contentMode: .scaleAspectFit)
    
    private lazy var usernameLabel: UILabel = UILabel(textColor: "Mine.ShareHistoryController.ItemCell.nameLabel.textColor", font: "Mine.ShareHistoryController.ItemCell.nameLabel.font")
        
    private lazy var nameLabel: UILabel = UILabel(textColor: "Mine.ShareHistoryController.ItemCell.sourceLabel.textColor", font: "Mine.ShareHistoryController.ItemCell.sourceLabel.font")
    
    private lazy var statusLabel: UILabel = UILabel(textColor: "Mine.ShareHistoryController.ItemCell.statusLabel.textColor", font: "Mine.ShareHistoryController.ItemCell.statusLabel.font", alignment: .right)

    override func set(model: Any?) {
        guard let model = model as? SCNetResponseShareInfoModel else { return }
        self.usernameLabel.text = model.username
        self.nameLabel.text = model.name
        
        let imageUrl = URL(string: model.imageUrl)
        if model.shareType == .device {
            self.coverImageView.sd_setImage(with: imageUrl)
        }
        else if model.shareType == .family {
            self.coverImageView.sd_setImage(with: imageUrl, placeholderImage: SCThemes.image("Global.GeneralImage.defaultAvatarImage"))
        }
        
        self.statusLabel.text = model.shareStatus.name
        if model.shareStatus == .normal {
            self.statusLabel.theme_textColor = "Mine.ShareHistoryController.ItemCell.statusLabel.normalTextColor"
        }
        else {
            self.statusLabel.theme_textColor = "Mine.ShareHistoryController.ItemCell.statusLabel.textColor"
        }
    }
}

extension SCDeviceShareUserListItemCell {
    override func setupView() {
        self.contentView.addSubview(self.coverImageView)
        self.contentView.addSubview(self.usernameLabel)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.statusLabel)
    }
    
    override func setupLayout() {
        self.coverImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(44)
            make.centerY.equalToSuperview()
        }
        self.usernameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.coverImageView.snp.right).offset(20)
            make.top.equalToSuperview().offset(14)
            make.right.lessThanOrEqualTo(self.statusLabel.snp.left).offset(-20)
        }
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.usernameLabel)
            make.top.equalTo(self.usernameLabel.snp.bottom).offset(6)
            make.right.lessThanOrEqualTo(self.statusLabel.snp.left).offset(-20)
            make.bottom.equalToSuperview().offset(-14)
        }
        self.statusLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(32)
            make.centerY.equalToSuperview()
        }
    }
}
