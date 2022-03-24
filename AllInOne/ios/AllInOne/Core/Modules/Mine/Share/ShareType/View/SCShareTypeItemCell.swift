//
//  SCShareTypeItemCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/29.
//

import UIKit

class SCShareTypeItemCell: SCBasicTableViewCell {

    private lazy var cornerView: UIView = UIView(backgroundColor: "Mine.ShareTypeController.ItemCell.backgroundColor", cornerRadius: 12)
    
    private lazy var coverImageView: UIImageView = UIImageView(contentMode: .scaleAspectFit)
    
    private lazy var titleLabel: UILabel = UILabel(textColor: "Mine.ShareTypeController.ItemCell.titleLabel.textColor", font: "Mine.ShareTypeController.ItemCell.titleLabel.font")
    
    private lazy var arrowImageView: UIImageView = UIImageView(image: "Gloabl.ItemCell.arrowImage")
    
    override func set(model: Any?) {
        guard let type = model as? SCShareInfoType else { return }
        self.coverImageView.theme_image = type.image
        self.titleLabel.text = type.title
    }
    
    override func setupView() {
        self.contentView.addSubview(self.cornerView)
        self.cornerView.addSubview(self.coverImageView)
        self.cornerView.addSubview(self.titleLabel)
        self.cornerView.addSubview(self.arrowImageView)
    }
    
    override func setupLayout() {
        self.cornerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(6)
        }
        self.coverImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(28)
            make.centerY.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.coverImageView.snp.right).offset(12)
            make.right.equalTo(self.arrowImageView.snp.left).offset(-10)
            make.centerY.equalToSuperview()
        }
        self.arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
}
