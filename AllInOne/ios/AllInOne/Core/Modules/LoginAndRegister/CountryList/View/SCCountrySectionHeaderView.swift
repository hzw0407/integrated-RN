//
//  SCCountrySectionHeaderView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/25.
//

import UIKit

class SCCountrySectionHeaderView: SCBasicTableViewHeaderFooterView {

    private lazy var titleLabel: UILabel = UILabel(textColor: "CountryList.SectionHeader.titleLabel.textColor", font: "CountryList.SectionHeader.titleLabel.font")

    override func set(model: Any?) {
        guard let model = model as? SCCountrySectionModel else { return }
        self.titleLabel.text = model.title
    }
}

extension SCCountrySectionHeaderView {
    override func setupView() {
        self.contentView.addSubview(self.titleLabel)
        
//        self.tintColor = .white
    }
    
    override func setupLayout() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.bottom.equalToSuperview().inset(12)
        }
    }
}
