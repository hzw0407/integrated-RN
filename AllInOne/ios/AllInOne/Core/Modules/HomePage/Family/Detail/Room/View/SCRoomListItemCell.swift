//
//  SCRoomListItemCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/22.
//

import UIKit

class SCRoomListItemCell: SCBasicTableViewCell {

    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.FamilyListController.RoomListController.ItemCell.nameLabel.textColor", font: "HomePage.FamilyListController.RoomListController.ItemCell.nameLabel.font", numberLines: 0)
    
    private lazy var contentLabel: UILabel = UILabel(textColor: "HomePage.FamilyListController.RoomListController.ItemCell.contentLabel.textColor", font: "HomePage.FamilyListController.RoomListController.ItemCell.contentLabel.font", numberLines: 0)
    
    private lazy var arrowImageView: UIImageView = UIImageView(image: "Global.ItemCell.arrowImage")
    
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
        self.contentLabel.text = String(model.deviceNum) + tempLocalize("个设备")
        self.arrowImageView.isHidden = model.isEditing
        if model.isUsed {
            self.arrowImageView.isHidden = true
        }
        if !model.isOwner {
            self.arrowImageView.isHidden = true
        }
    }
}

extension SCRoomListItemCell {
    override func setupView() {
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.contentLabel)
        self.contentView.addSubview(self.arrowImageView)
    }
    
    override func setupLayout() {
        let margin: CGFloat = 24
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.top.equalToSuperview().offset(16)
            make.right.equalTo(self.arrowImageView.snp.left).offset(-10)
        }
        self.contentLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.nameLabel)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(3)
            make.bottom.equalToSuperview().offset(-16)
        }
        self.arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-margin)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
}
