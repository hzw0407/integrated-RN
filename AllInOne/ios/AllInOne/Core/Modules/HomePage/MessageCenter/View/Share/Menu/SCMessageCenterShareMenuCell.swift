//
//  SCMessageCenterShareMenuCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/24.
//

import UIKit

class SCMessageCenterShareMenuCell: SCBasicCollectionViewCell {
    
    private lazy var titleLabel: UILabel = UILabel(textColor: "HomePage.MessageCenterController.ShareMessage.MenuView.titleLabel.textColor", font: "HomePage.MessageCenterController.ShareMessage.MenuView.titleLabel.font")
    
    override func set(model: Any?) {
        guard let model = model as? SCMessageCenterShareMenuItemModel else { return }
        self.titleLabel.text = model.type.title
        if model.isSelected {
            self.titleLabel.theme_textColor = "HomePage.MessageCenterController.ShareMessage.MenuView.titleLabel.selectedTextColor"
            self.titleLabel.theme_font = "HomePage.MessageCenterController.ShareMessage.MenuView.titleLabel.selectedFont"
        }
        else {
            self.titleLabel.theme_textColor = "HomePage.MessageCenterController.ShareMessage.MenuView.titleLabel.textColor"
            self.titleLabel.theme_font = "HomePage.MessageCenterController.ShareMessage.MenuView.titleLabel.font"
        }
    }
}

extension SCMessageCenterShareMenuCell {
    override func setupView() {
        self.contentView.addSubview(self.titleLabel)
    }
    
    override func setupLayout() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(52)
        }
    }
}
