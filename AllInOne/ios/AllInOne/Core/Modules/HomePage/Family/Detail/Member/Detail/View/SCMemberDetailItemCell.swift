//
//  SCMemberDetailItemCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/22.
//

import UIKit

class SCMemberDetailItemModel {
    var title: String = ""
    var content: String = ""
}

class SCMemberDetailItemCell: SCBasicTableViewCell {
    
    private lazy var backView: UIView = UIView(backgroundColor: "HomePage.FamilyListController.MemberDetailController.ItemCell.backgroundColor", cornerRadius: 12)

    private lazy var titleLabel: UILabel = UILabel(textColor: "HomePage.FamilyListController.MemberDetailController.ItemCell.titleLabel.textColor", font: "HomePage.FamilyListController.MemberDetailController.ItemCell.titleLabel.font", numberLines: 2)
    
    private lazy var contentLabel: UILabel = UILabel(textColor: "HomePage.FamilyListController.MemberDetailController.ItemCell.contentLabel.textColor", font: "HomePage.FamilyListController.MemberDetailController.ItemCell.contentLabel.font", numberLines: 2, alignment: .right)
    
    override func set(model: Any?) {
        guard let model = model as? SCMemberDetailItemModel else { return }
        self.titleLabel.text = model.title
        self.contentLabel.text = model.content
    }
}

extension SCMemberDetailItemCell {
    override func setupView() {
        self.contentView.addSubview(self.backView)
        self.backView.addSubview(self.titleLabel)
        self.backView.addSubview(self.contentLabel)
    }
    
    override func setupLayout() {
        self.backView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(6)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(self.contentLabel.snp.left).offset(-10)
        }
        self.contentLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.top.bottom.equalToSuperview()
            make.left.lessThanOrEqualTo(self.contentView.snp.centerX)
        }
    }
}
