//
//  SCAddFamilyItemCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/21.
//

import UIKit

class SCAddFamilyItemCell: SCBasicTableViewCell {

    private lazy var coverImageView: UIImageView = UIImageView(contentMode: .scaleAspectFit)
    
    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.FamilyListController.AddFamilyController.ItemCell.nameLabel.textColor", font: "HomePage.FamilyListController.AddFamilyController.ItemCell.nameLabel.font", numberLines: 0)
    
    private lazy var contentLabel: UILabel = UILabel(textColor: "HomePage.FamilyListController.AddFamilyController.ItemCell.contentLabel.textColor", font: "HomePage.FamilyListController.AddFamilyController.ItemCell.contentLabel.font", numberLines: 0)
    
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
        guard let model = model as? SCAddFamilyItemModel else { return }
        self.coverImageView.theme_image = model.image
        self.nameLabel.text = model.name
        var content = model.placeholder
        if model.content.count > 0 {
            content = model.content
        }
        self.contentLabel.text = content
        self.arrowImageView.isHidden = !model.hasNext
    }
}

extension SCAddFamilyItemCell {
    override func setupView() {
        self.contentView.addSubview(self.coverImageView)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.contentLabel)
        self.contentView.addSubview(self.arrowImageView)
    }
    
    override func setupLayout() {
        let margin: CGFloat = 24
        self.coverImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.coverImageView.snp.right).offset(11)
            make.right.equalTo(self.arrowImageView.snp.left).offset(-5)
            make.top.equalToSuperview().offset(16)
        }
        self.contentLabel.snp.makeConstraints { make in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(3)
            make.left.right.equalTo(self.nameLabel)
            make.bottom.equalToSuperview().offset(-16)
        }
        self.arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-margin)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
}
