//
//  SCMessageCenterShareDeviceCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/24.
//

import UIKit

class SCMessageCenterShareDeviceItemModel {
    
}

class SCMessageCenterShareDeviceCell: SCBasicTableViewCell {

    private lazy var coverImageView: UIImageView = UIImageView(contentMode: .scaleAspectFit)
    
    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.MessageCenterController.DeviceMessage.ItemCell.nameLabel.textColor", font: "HomePage.MessageCenterController.DeviceMessage.ItemCell.nameLabel.font")
    
    private lazy var timeLabel: UILabel = UILabel(textColor: "HomePage.MessageCenterController.DeviceMessage.ItemCell.timeLabel.textColor", font: "HomePage.MessageCenterController.DeviceMessage.ItemCell.timeLabel.font")
    
    private lazy var statusLabel: UILabel = UILabel(textColor: "HomePage.MessageCenterController.DeviceMessage.ItemCell.statusLabel.textColor", font: "HomePage.MessageCenterController.DeviceMessage.ItemCell.statusLabel.font")
    
    private lazy var arrowImageView: UIImageView = UIImageView(image: "Global.ItemCell.arrowImage")
    
    override func set(model: Any?) {
        guard let model = model as? SCNetResponseDeviceNotificaitonRecordModel else { return }
        
//        self.coverImageView.sd_setImage(with: URL(string: <#T##String#>), completed: <#T##SDExternalCompletionBlock?##SDExternalCompletionBlock?##(UIImage?, Error?, SDImageCacheType, URL?) -> Void#>)
        self.nameLabel.text = model.title
        let time = TimeInterval(model.createTime) ?? 0
        self.timeLabel.text = Date.dateString(timeInterval: time, format: "hh:mm")
        self.statusLabel.text = model.msg
    }
}

extension SCMessageCenterShareDeviceCell {
    override func setupView() {
        self.contentView.addSubview(self.coverImageView)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.timeLabel)
        self.contentView.addSubview(self.statusLabel)
        self.contentView.addSubview(self.arrowImageView)
    }
    
    override func setupLayout() {
        self.coverImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(44)
            make.centerY.equalToSuperview()
        }
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.coverImageView.snp.right).offset(20)
            make.top.equalToSuperview().offset(14)
            make.right.equalTo(self.arrowImageView.snp.left).offset(-10)
        }
        self.timeLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.nameLabel)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(2)
        }
        self.statusLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.nameLabel)
            make.top.equalTo(self.timeLabel.snp.bottom).offset(6)
            make.bottom.equalToSuperview().offset(-14)
        }
        self.arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
}
