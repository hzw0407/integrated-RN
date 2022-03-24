//
//  SCShareHistoryItemCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/28.
//

import UIKit

protocol SCShareHistoryItemCellDelegate: AnyObject {
    func cell(_ cell: SCShareHistoryItemCell, didClickStatusWithModel item: SCNetResponseShareInfoModel)
}

class SCShareHistoryItemCell: SCBasicTableViewCell {
    var item: SCNetResponseShareInfoModel?
    
    private weak var delegate: SCShareHistoryItemCellDelegate?
    
    private lazy var coverImageView: UIImageView = UIImageView(contentMode: .scaleAspectFit)
    
    private lazy var nameLabel: UILabel = UILabel(textColor: "Mine.ShareHistoryController.ItemCell.nameLabel.textColor", font: "Mine.ShareHistoryController.ItemCell.nameLabel.font")
    
    private lazy var roomLabel: UILabel = UILabel(textColor: "Mine.ShareHistoryController.ItemCell.roomNameLabel.textColor", font: "Mine.ShareHistoryController.ItemCell.roomNameLabel.font")
    
    private lazy var sourceLabel: UILabel = UILabel(textColor: "Mine.ShareHistoryController.ItemCell.sourceLabel.textColor", font: "Mine.ShareHistoryController.ItemCell.sourceLabel.font")
    
    private lazy var statusLabel: UILabel = UILabel(textColor: "Mine.ShareHistoryController.ItemCell.statusLabel.textColor", font: "Mine.ShareHistoryController.ItemCell.statusLabel.font", alignment: .right)
    
    private lazy var statusButton: UIButton = {
        let btn = UIButton(backgroundColor: "Mine.ShareHistoryController.ItemCell.statusLabel.normalBackgroundColor", cornerRadius: 8)
        btn.addTarget(self, action: #selector(statusButtonAction), for: .touchUpInside)
        return btn
    }()
    
    override func set(delegate: Any?) {
        self.delegate = delegate as? SCShareHistoryItemCellDelegate
    }
    
    override func set(model: Any?) {
        guard let model = model as? SCNetResponseShareInfoModel else { return }
        self.item = model
        self.nameLabel.text = model.name
        var souce = model.username
        if model.isOwner {
            souce = tempLocalize("我")
        }
        self.sourceLabel.text = tempLocalize("来自：") + souce
        let roomName: String = ""
        
        let imageUrl = URL(string: model.imageUrl)
        self.roomLabel.isHidden = (roomName.count == 0 || model.shareType != .device)
        if model.shareType == .device {
            self.sourceLabel.snp.remakeConstraints { make in
                make.left.equalTo(self.nameLabel)
                make.top.equalTo(self.nameLabel.snp.bottom).offset(6)
                make.right.lessThanOrEqualTo(self.statusLabel.snp.left).offset(-20)
                make.bottom.equalToSuperview().offset(-14)
            }
            
            self.coverImageView.sd_setImage(with: imageUrl)
        }
        else if model.shareType == .family {
            if roomName.count > 0 {
                self.sourceLabel.snp.remakeConstraints { make in
                    make.left.equalTo(self.nameLabel)
                    make.top.equalTo(self.sourceLabel.snp.bottom).offset(6)
                    make.right.lessThanOrEqualTo(self.statusLabel.snp.left).offset(-20)
                    make.bottom.equalToSuperview().offset(-14)
                }
            }

            self.coverImageView.sd_setImage(with: imageUrl, placeholderImage: SCThemes.image("Global.GeneralImage.defaultAvatarImage"))
        }
        
        self.statusLabel.text = model.shareStatus.name
        if model.shareStatus == .normal {
            if model.isOwner {
                self.statusButton.isHidden = true
            }
            else {
                self.statusButton.isHidden = false
            }
            self.statusLabel.theme_textColor = "Mine.ShareHistoryController.ItemCell.statusLabel.normalTextColor"
        }
        else {
            self.statusButton.isHidden = true
            self.statusLabel.theme_textColor = "Mine.ShareHistoryController.ItemCell.statusLabel.textColor"
        }
    }
    
    override func setupView() {
        self.contentView.addSubview(self.coverImageView)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.roomLabel)
        self.contentView.addSubview(self.sourceLabel)
        self.contentView.addSubview(self.statusLabel)
        self.contentView.addSubview(self.statusButton)
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
            make.right.lessThanOrEqualTo(self.statusLabel.snp.left).offset(-20)
        }
        self.roomLabel.snp.makeConstraints { make in
            make.left.equalTo(self.nameLabel)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(2)
            make.right.lessThanOrEqualTo(self.statusLabel.snp.left).offset(-20)
        }
        self.sourceLabel.snp.makeConstraints { make in
            make.left.equalTo(self.nameLabel)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(6)
            make.right.lessThanOrEqualTo(self.statusLabel.snp.left).offset(-20)
            make.bottom.equalToSuperview().offset(-14)
        }
        self.statusLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(32)
            make.centerY.equalToSuperview()
        }
        self.statusButton.snp.makeConstraints { make in
            make.left.equalTo(self.statusLabel).offset(-12)
            make.right.equalTo(self.statusLabel).offset(12)
            make.top.bottom.equalTo(self.statusLabel)
        }
    }
}

extension SCShareHistoryItemCell {
    @objc private func statusButtonAction() {
        guard let item = self.item, !item.isOwner else { return }
        self.delegate?.cell(self, didClickStatusWithModel: item)
    }
}
