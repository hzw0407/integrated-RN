//
//  SCSearchLoactionItemCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/21.
//

import UIKit

class SCSearchLoactionItemCell: SCBasicTableViewCell {

    private lazy var titleLabel: UILabel = UILabel(textColor: "HomePage.FamilyListController.FamilyLocationController.SearchLocationController.ItemCell.titleLabel.textColor", font: "HomePage.FamilyListController.FamilyLocationController.SearchLocationController.ItemCell.titleLabel.font")
    
    private lazy var contentLabel: UILabel = UILabel(textColor: "HomePage.FamilyListController.FamilyLocationController.SearchLocationController.ItemCell.contentLabel.textColor", font: "HomePage.FamilyListController.FamilyLocationController.SearchLocationController.ItemCell.contentLabel.font")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func set(model: Any?) {
        guard let model = model as? SCSearchLocationItemModel else { return }
        self.titleLabel.text = model.title
        self.contentLabel.text = model.content
    }
}

extension SCSearchLoactionItemCell {
    override func setupView() {
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.contentLabel)
    }
    
    override func setupLayout() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalToSuperview().offset(16)
        }
        self.contentLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.titleLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(3)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
}
