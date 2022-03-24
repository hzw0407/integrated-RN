//
//  SCDeviceShareShareItemCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/29.
//

import UIKit

class SCDeviceShareShareItemCell: SCBasicTableViewCell {

    private lazy var coverImageView: UIImageView = UIImageView(contentMode: .scaleAspectFit)
    private lazy var nameLabel: UILabel = UILabel(textColor: "Mine.DeviceShareController.ShareView.ItemCell.nameLabel.textColor", font: "Mine.DeviceShareController.ShareView.ItemCell.nameLabel.font")
    private lazy var statusLabel: UILabel = UILabel(textColor: "Mine.DeviceShareController.ShareView.ItemCell.statusLabel.textColor", font: "Mine.DeviceShareController.ShareView.ItemCell.statusLabel.font")
    private lazy var arrowImageView: UIImageView = UIImageView(image: "Global.ItemCell.arrowImage")
    
    private lazy var selectImageView: UIImageView = UIImageView(image: "Global.ItemCell.selectImageView.normalImage")
    
    override func set(model: Any?) {
        guard let model = model as? SCNetResponseDeviceModel else { return }
        self.coverImageView.sd_setImage(with: URL(string: model.photoUrl))
        self.nameLabel.text = model.nickname
        self.statusLabel.text = model.isShared ? tempLocalize("已共享") : tempLocalize("未共享")
        self.arrowImageView.isHidden = model.isEditing
        
        if model.isShared {
            self.statusLabel.theme_textColor = "Mine.DeviceShareController.ShareView.ItemCell.statusLabel.sharedTextColor"
        }
        else {
            self.statusLabel.theme_textColor = "Mine.DeviceShareController.ShareView.ItemCell.statusLabel.textColor"
        }
        
        var leftOffset = -20
        if model.isEditing {
            leftOffset = 24
        }
        self.selectImageView.snp.updateConstraints { make in
            make.left.equalToSuperview().offset(leftOffset)
        }
        if model.isSelected {
            self.selectImageView.theme_image = "Global.ItemCell.selectImageView.selectImage"
        }
        else {
            self.selectImageView.theme_image = "Global.ItemCell.selectImageView.normalImage"
        }
    }

    override func setupView() {
        self.contentView.addSubview(self.coverImageView)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.statusLabel)
        self.contentView.addSubview(self.arrowImageView)
        self.contentView.addSubview(self.selectImageView)
    }
    
    override func setupLayout() {
        self.selectImageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(-20)
        }
        self.coverImageView.snp.makeConstraints { make in
            make.left.equalTo(self.selectImageView.snp.right).offset(20)
            make.width.height.equalTo(60)
            make.centerY.equalToSuperview()
        }
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.coverImageView.snp.right).offset(20)
            make.right.equalTo(self.arrowImageView.snp.left).offset(-8)
            make.top.equalToSuperview().offset(22)
        }
        self.statusLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.nameLabel)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(6)
            make.bottom.equalToSuperview().offset(-22)
        }
        self.arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
}
