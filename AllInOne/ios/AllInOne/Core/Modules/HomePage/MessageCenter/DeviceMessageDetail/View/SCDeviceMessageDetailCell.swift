//
//  SCDeviceMessageDetailCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/25.
//

import UIKit

class SCDeviceMessageDetailCell: SCBasicTableViewCell {
    private lazy var timeLabel: UILabel = UILabel(textColor: "HomePage.MessageCenterController.DeviceMessageDetailController.ItemCell.timeLabel.textColor", font: "HomePage.MessageCenterController.DeviceMessageDetailController.ItemCell.timeLabel.font")
    private lazy var statusLabel: UILabel = UILabel(textColor: "HomePage.MessageCenterController.DeviceMessageDetailController.ItemCell.statusLabel.textColor", font: "HomePage.MessageCenterController.DeviceMessageDetailController.ItemCell.statusLabel.font")
}

extension SCDeviceMessageDetailCell {
    override func setupView() {
        self.contentView.theme_backgroundColor = "HomePage.MessageCenterController.DeviceMessageDetailController.ItemCell.backgroundColor"
        
        self.contentView.addSubview(self.timeLabel)
        self.contentView.addSubview(self.statusLabel)
    }
    
    override func setupLayout() {
        self.timeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(40)
            make.centerY.equalTo(self.statusLabel)
        }
        self.statusLabel.snp.makeConstraints { make in
            make.left.equalTo(self.timeLabel.snp.right).offset(23)
            make.right.equalToSuperview().offset(-40)
            make.top.bottom.equalToSuperview().inset(14)
        }
    }
}
