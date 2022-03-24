//
//  SCMemberListItemCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/22.
//

import UIKit

enum SCMemberIdentityType: Int {
    /// 管理员
    case admin = 0
    /// 普通成员
    case normal
    /// 共享成员
    case share
    /// 待确认
    case notConfirm
    
    var name: String {
        switch self {
        case .admin:
            return tempLocalize("管理员")
        case .normal:
            return tempLocalize("普通成员")
        case .share:
            return tempLocalize("共享成员")
        case .notConfirm:
            return tempLocalize("待确认")
        }
    }
}

class SCMemberListItemCell: SCBasicTableViewCell {
    
    private lazy var avatarImageView: UIImageView = UIImageView(image: "Global.GeneralImage.defaultAvatarImage", contentMode: .scaleAspectFit, cornerRadius: 44 / 2)
    
    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.FamilyListController.MemberListController.ItemCell.nameLabel.textColor", font: "HomePage.FamilyListController.MemberListController.ItemCell.nameLabel.font", numberLines: 2)
    
    private lazy var identityLabel: UILabel = UILabel(textColor: "HomePage.FamilyListController.MemberListController.ItemCell.identityLabel.textColor", font: "HomePage.FamilyListController.MemberListController.ItemCell.identityLabel.font", numberLines: 2, alignment: .right)
    
    private lazy var arrowImageView = UIImageView(image: "Global.ItemCell.arrowImage")

    override func set(model: Any?) {
        guard let model = model as? SCNetResponseFamilyMemberModel else { return }
        self.avatarImageView.sd_setImage(with: URL(string: model.headUrl), placeholderImage: SCThemes.image("Global.GeneralImage.defaultAvatarImage"))
        var name = model.nickname
        self.nameLabel.text = name
        
        let type = SCMemberIdentityType(rawValue: model.identity) ?? .admin
        self.identityLabel.text = type.name
        if type == .notConfirm {
            self.identityLabel.theme_textColor = "HomePage.FamilyListController.MemberListController.ItemCell.identityLabel.notConfirmTextColor"
        }
        else {
            self.identityLabel.theme_textColor = "HomePage.FamilyListController.MemberListController.ItemCell.identityLabel.textColor"
        }
    }
}

extension SCMemberListItemCell {
    override func setupView() {
        self.contentView.addSubview(self.avatarImageView)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.identityLabel)
        self.contentView.addSubview(self.arrowImageView)
    }
    
    override func setupLayout() {
        self.avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.avatarImageView.snp.right).offset(20)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(self.identityLabel.snp.left).offset(-10)
//            make.centerY.equalToSuperview()
        }
        self.identityLabel.snp.makeConstraints { make in
            make.right.equalTo(self.arrowImageView.snp.left).offset(-12)
            make.top.bottom.equalToSuperview()
            make.left.lessThanOrEqualTo(self.contentView.snp.centerX).offset(40)
        }
        self.arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
}
