//
//  SCMoveRoomDeviceCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/20.
//

import UIKit

class SCMoveRoomDeviceCell: SCBasicTableViewCell {

    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.HomePageController.MoveRoomDeviceController.ItemCell.nameLabel.textColor", font: "HomePage.HomePageController.MoveRoomDeviceController.ItemCell.nameLabel.font")
    
    private lazy var countLabel: UILabel = UILabel(textColor: "HomePage.HomePageController.MoveRoomDeviceController.ItemCell.countLabel.textColor", font: "HomePage.HomePageController.MoveRoomDeviceController.ItemCell.countLabel.font")
    
    private lazy var selectImageView: UIImageView = UIImageView(image: "HomePage.HomePageController.MoveRoomDeviceController.ItemCell.selectImage")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func set(model: Any?) {
        guard let model = model as? SCNetResponseFamilyRoomModel else { return }
        
        self.nameLabel.text = model.roomName
        self.countLabel.text = String(model.devices.count) + tempLocalize("个设备")
        self.selectImageView.isHidden = !model.isSelected
    }
}

extension SCMoveRoomDeviceCell {
    override func setupView() {
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.countLabel)
        self.contentView.addSubview(self.selectImageView)
    }
    
    override func setupLayout() {
        let margin: CGFloat = 24
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.top.equalToSuperview().offset(16)
            make.right.equalTo(self.selectImageView.snp.left).offset(-5)
        }
        self.countLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.nameLabel)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(3)
            make.bottom.equalToSuperview().offset(-16)
        }
        self.selectImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-margin)
            make.width.height.equalTo(24)
        }
    }
}
