//
//  SCMineConsumableCell.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/15.
//

import UIKit

class SCMineConsumableCell: SCMineBaseCell {
    /// 标题
    private lazy var titleLabel: UILabel = UILabel(textColor: "Mine.SCMineConsumablesVC.SCMineConsumableCell.titleLabel.textColor", font: "Mine.SCMineConsumablesVC.SCMineConsumableCell.titleLabel.font", alignment: .left)
    /// 副标题
    private lazy var subTitleLabel: UILabel = UILabel(textColor: "Mine.SCMineConsumablesVC.SCMineConsumableCell.subTitleLabel.textColor", font: "Mine.SCMineConsumablesVC.SCMineConsumableCell.subTitleLabel.font", alignment: .left)
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func set(model: Any?) {
        self.model = model
        guard let model = self.model as? SCMineConsumableModel else { return }
        self.titleLabel.text = model.title
        self.subTitleLabel.text = model.subTitle
        self.cornerRadius(cornerRadius: 18, top: model.cornerRadiusTop, bottom: model.cornerRadiusBottom, cornerFrame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 40, height: 56))
    }
}

extension SCMineConsumableCell {
    override func setupView() {
        super.setupView()
        self.colorBgView.addSubview(self.titleLabel)
        self.colorBgView.addSubview(self.subTitleLabel)
    }
    
    override func setupLayout() {
        super.setupLayout()
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(44)
        }
        self.subTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.titleLabel.snp.right).offset(19)
            make.centerY.equalToSuperview()
        }
    }
}

