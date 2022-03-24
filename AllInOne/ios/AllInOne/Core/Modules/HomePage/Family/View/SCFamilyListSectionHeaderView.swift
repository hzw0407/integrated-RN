//
//  SCFamilyListSectionHeaderView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/20.
//

import UIKit

class SCFamilyListSectionHeaderView: SCBasicTableViewHeaderFooterView {

    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.FamilyListController.SectionHeader.nameLabel.textColor", font: "HomePage.FamilyListController.SectionHeader.nameLabel.font", numberLines: 0)

    override func setupView() {
        self.contentView.addSubview(self.nameLabel)
    }
    
    override func setupLayout() {
        self.nameLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.bottom.equalToSuperview().inset(12)
        }
    }
    
    override func set(model: Any?) {
        let name = model as? String 
        self.nameLabel.text = name
    }
}
