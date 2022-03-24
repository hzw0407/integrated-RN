//
//  SCMessageCenterShareCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/24.
//

import UIKit

protocol SCMessageCenterShareCellDelegate: AnyObject {
    func cell(_ cell: SCMessageCenterShareCell, didClickStatusWithModel item: SCNetResponseShareNotificaitonRecordModel)
}

class SCMessageCenterShareCell: SCBasicTableViewCell {

    private var item: SCNetResponseShareNotificaitonRecordModel?
    
    private weak var delegate: SCMessageCenterShareCellDelegate?
    
    private lazy var coverImageView: UIImageView = UIImageView(contentMode: .scaleAspectFit)
    
    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.MessageCenterController.ShareMessage.ItemCell.nameLabel.textColor", font: "HomePage.MessageCenterController.ShareMessage.ItemCell.nameLabel.font", numberLines: 0)
    
    private lazy var contentLabel: UILabel = UILabel(textColor: "HomePage.MessageCenterController.ShareMessage.ItemCell.contentLabel.textColor", font: "HomePage.MessageCenterController.ShareMessage.ItemCell.contentLabel.font", numberLines: 0)
    
    private lazy var statusLabel: UILabel = UILabel(textColor: "HomePage.MessageCenterController.ShareMessage.ItemCell.statusLabel.textColor", font: "HomePage.MessageCenterController.ShareMessage.ItemCell.statusLabel.font", alignment: .right)
    
    private lazy var statusButton: UIButton = {
        let btn = UIButton(backgroundColor: "HomePage.MessageCenterController.ShareMessage.ItemCell.statusLabel.waitProcessedBackgroundColor", cornerRadius: 8)
        btn.addTarget(self, action: #selector(statusButtonAction), for: .touchUpInside)
        return btn
    }()
    
    override func set(model: Any?) {
        guard let model = model as? SCNetResponseShareNotificaitonRecordModel else { return }
        self.item = model
        
//        self.nameLabel.text = model.name
        self.nameLabel.text = model.title
        var souce = model.username
        if model.isOwner {
            souce = tempLocalize("我")
        }
        var content: String = tempLocalize("来自：") + model.username
        if model.isOwner {
//            content = tempLocalize("共享给：") + model.to
            content = tempLocalize("来自：") + tempLocalize("我")
        }
        self.contentLabel.text = model.msg
        
        let imageUrl = URL(string: model.photoUrl)
        if model.shareType == .device {
            self.coverImageView.sd_setImage(with: imageUrl)
        }
        else if model.shareType == .family {
            self.coverImageView.sd_setImage(with: imageUrl, placeholderImage: SCThemes.image("Global.GeneralImage.defaultAvatarImage"))
        }
        
        self.statusLabel.text = model.shareStatus.name
        let width = model.shareStatus.name.textWidth(height: 20, font: self.statusLabel.font)
        self.statusLabel.snp.updateConstraints { make in
            make.width.equalTo(width)
        }
        if model.shareStatus == .normal {
            if model.isOwner {
                self.statusButton.isHidden = true
            }
            else {
                self.statusButton.isHidden = false
            }
            self.statusLabel.theme_textColor = "HomePage.MessageCenterController.ShareMessage.ItemCell.statusLabel.normalTextColor"
        }
        else {
            self.statusButton.isHidden = true
            self.statusLabel.theme_textColor = "HomePage.MessageCenterController.ShareMessage.ItemCell.statusLabel.textColor"
        }
    }
    
    override func set(delegate: Any?) {
        self.delegate = delegate as? SCMessageCenterShareCellDelegate
    }
}

extension SCMessageCenterShareCell {
    override func setupView() {
        self.contentView.addSubview(self.coverImageView)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.contentLabel)
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
            make.top.equalToSuperview().offset(24)
            make.right.lessThanOrEqualTo(self.statusLabel.snp.left).offset(-20)
        }
        self.contentLabel.snp.makeConstraints { make in
            make.left.equalTo(self.nameLabel)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(6)
            make.right.lessThanOrEqualTo(self.statusLabel.snp.left).offset(-20)
            make.bottom.equalToSuperview().offset(-23)
        }
        self.statusLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(32)
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
        }
        self.statusButton.snp.makeConstraints { make in
            make.left.equalTo(self.statusLabel).offset(-12)
            make.right.equalTo(self.statusLabel).offset(12)
            make.top.bottom.equalTo(self.statusLabel)
        }
    }
    
    @objc private func statusButtonAction() {
        guard let item = self.item else { return }
        self.delegate?.cell(self, didClickStatusWithModel: item)
    }
}

