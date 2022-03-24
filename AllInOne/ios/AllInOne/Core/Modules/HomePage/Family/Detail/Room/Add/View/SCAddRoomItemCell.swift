//
//  SCAddRoomItemCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/22.
//

import UIKit

class SCAddRoomItemModel {
    var name: String = "" {
        didSet {
            let font = ThemeFontPicker(stringLiteral: "HomePage.FamilyListController.RoomListController.AddRoomController.ItemCell.nameLabel.font").value() as! UIFont
            self.nameWidth = self.name.textWidth(height: 30, font: font) + 12 * 2
        }
    }
    var isSelected: Bool = false {
        didSet {
            var font = ThemeFontPicker(stringLiteral: "HomePage.FamilyListController.RoomListController.AddRoomController.ItemCell.nameLabel.font").value() as! UIFont
            if self.isSelected {
                font = ThemeFontPicker(stringLiteral: "HomePage.FamilyListController.RoomListController.AddRoomController.ItemCell.nameLabel.selectedFont").value() as! UIFont
            }
            self.nameWidth = self.name.textWidth(height: 30, font: font) + 12 * 2
        }
    }
    var nameWidth: CGFloat = 0
}

class SCAddRoomItemCell: SCBasicCollectionViewCell {
    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.FamilyListController.RoomListController.AddRoomController.ItemCell.nameLabel.textColor", font: "HomePage.FamilyListController.RoomListController.AddRoomController.ItemCell.nameLabel.font", alignment: .center)
    
    override func set(model: Any?) {
        guard let model = model as? SCAddRoomItemModel else { return }
        self.nameLabel.text = model.name
        
        if model.isSelected {
            self.nameLabel.theme_textColor = "HomePage.FamilyListController.RoomListController.AddRoomController.ItemCell.nameLabel.selectedTextColor"
            self.nameLabel.theme_font = "HomePage.FamilyListController.RoomListController.AddRoomController.ItemCell.nameLabel.selectedFont"
            self.theme_backgroundColor = "HomePage.FamilyListController.RoomListController.AddRoomController.ItemCell.selectedBackgroundColor"
        }
        else {
            self.nameLabel.theme_textColor = "HomePage.FamilyListController.RoomListController.AddRoomController.ItemCell.nameLabel.textColor"
            self.nameLabel.theme_font = "HomePage.FamilyListController.RoomListController.AddRoomController.ItemCell.nameLabel.font"
            self.theme_backgroundColor = "HomePage.FamilyListController.RoomListController.AddRoomController.ItemCell.backgroundColor"
        }
    }
    
    override func setupView() {
        self.contentView.addSubview(self.nameLabel)
        
        self.theme_backgroundColor = "HomePage.FamilyListController.RoomListController.AddRoomController.ItemCell.backgroundColor"
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    
    override func setupLayout() {
        self.nameLabel.snp.makeConstraints { make in
//            make.top.bottom.equalToSuperview().inset(6)
//            make.left.right.equalToSuperview().inset(12)
            make.center.equalToSuperview()
            make.width.height.equalToSuperview()
        }
    }
}
