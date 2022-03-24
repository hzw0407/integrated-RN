//
//  SCAccountTypeCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/25.
//

import UIKit


class SCAccountTypeCell: SCBasicTableViewCell {
    private lazy var coverImageView: UIImageView = UIImageView(contentMode: .scaleAspectFit)
    
    private lazy var titleLabel: UILabel = UILabel(textColor: "HomePage.AccountTypeController.ItemCell.titleLabel.textColor", font: "HomePage.AccountTypeController.ItemCell.titleLabel.font")
    
    private lazy var backView: UIView = UIView(backgroundColor: "HomePage.AccountTypeController.ItemCell.backgroundColor", cornerRadius: 12)
    
    private lazy var arrowImageView: UIImageView = UIImageView(image: "Global.ItemCell.arrowImage")
   
    override func set(model: Any?) {
        guard let type = model as? SCAccountType else { return }
        self.coverImageView.theme_image = type.image
        self.titleLabel.text = type.name
    }
    
    override func setupView() {
        self.contentView.addSubview(backView)
        self.backView.addSubview(self.coverImageView)
        self.backView.addSubview(self.titleLabel)
        self.backView.addSubview(self.arrowImageView)
    }
    
    override func setupLayout() {
        self.backView.snp.makeConstraints { make in
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
            make.top.bottom.equalToSuperview().inset(17)
            make.right.equalTo(self.arrowImageView.snp.left).offset(-10)
        }
        self.arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
}
