//
//  SCMessageCenterMenuItemCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/24.
//

import UIKit

class SCMessageCenterMenuItemCell: SCBasicCollectionViewCell {
    private lazy var titleLabel: UILabel = UILabel(textColor: "HomePage.MessageCenterController.MenuView.titleLabel.textColor", font: "HomePage.MessageCenterController.MenuView.titleLabel.font")
    
    private lazy var badgeView: UIView = UIView(backgroundColor: "HomePage.MessageCenterController.MenuView.titleLabel.badgeBackground", cornerRadius: 4)
    
    private lazy var backView: UIView = UIView(backgroundColor: "HomePage.MessageCenterController.MenuView.titleLabel.backgroundColor", cornerRadius: 8)
    
    override func set(model: Any?) {
        guard let model = model as? SCMessageCenterMenuItemModel else { return }
        self.titleLabel.text = model.type.title
        self.badgeView.isHidden = !model.hasNewMessage
        if model.isSelected {
            self.titleLabel.theme_textColor = "HomePage.MessageCenterController.MenuView.titleLabel.selectedTextColor"
            self.titleLabel.theme_font = "HomePage.MessageCenterController.MenuView.titleLabel.selectedFont"
            self.backView.theme_backgroundColor = "HomePage.MessageCenterController.MenuView.titleLabel.selectedBackgroundColor"
        }
        else {
            self.titleLabel.theme_textColor = "HomePage.MessageCenterController.MenuView.titleLabel.textColor"
            self.titleLabel.theme_font = "HomePage.MessageCenterController.MenuView.titleLabel.font"
            self.backView.theme_backgroundColor = "HomePage.MessageCenterController.MenuView.titleLabel.backgroundColor"
        }
    }
}

extension SCMessageCenterMenuItemCell {
    override func setupView() {
        self.contentView.addSubview(self.backView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.badgeView)
    }
    
    override func setupLayout() {
        self.backView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(6)
            make.top.bottom.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12 + 6)
            make.top.bottom.equalToSuperview().inset(6 + 6)
        }
        self.badgeView.snp.makeConstraints { make in
            make.centerX.equalTo(self.backView.snp.right)
            make.centerY.equalTo(self.backView.snp.top)
            make.width.height.equalTo(8)
        }
    }
}
