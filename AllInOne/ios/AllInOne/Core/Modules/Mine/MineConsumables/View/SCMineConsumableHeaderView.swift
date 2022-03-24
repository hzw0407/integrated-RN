//
//  SCMineConsumableHeaderView.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/24.
//

import UIKit

class SCMineConsumableHeaderView: SCBasicTableViewHeaderFooterView {
    /// 标题
    private lazy var titleLabel: UILabel = UILabel(textColor: "Mine.SCMineConsumablesVC.sectionHeaderView.titleLabel.textColor", font: "Mine.SCMineConsumablesVC.sectionHeaderView.titleLabel.font", alignment: .left)
    /// 副标题
    private lazy var subTitleLabel: UILabel = UILabel(textColor: "Mine.SCMineConsumablesVC.sectionHeaderView.subTitleLabel.textColor", font: "Mine.SCMineConsumablesVC.sectionHeaderView.subTitleLabel.font", alignment: .left)

    override func set(model: Any?) {
        guard let model = model as? SCMineConsumableHeaderModel else { return }
        self.titleLabel.text = model.name
        self.subTitleLabel.text = model.location
    }
}

extension SCMineConsumableHeaderView {
    override func setupView() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.subTitleLabel)
        self.backgroundColor = .clear
    }
    
    override func setupLayout() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.centerY.equalToSuperview()
        }
        self.subTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
    }
}
