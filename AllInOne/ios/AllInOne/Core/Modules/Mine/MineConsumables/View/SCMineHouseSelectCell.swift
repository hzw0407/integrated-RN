//
//  SCMineHouseSelectCell.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/15.
//

import UIKit

class SCMineHouseSelectCell: SCBasicTableViewCell {
    /// 标题
    private lazy var titleLabel: UILabel = UILabel(textColor: "Mine.SCMineConsumablesVC.SCMineHouseSelectCell.titleLabel.textColor", font: "Mine.SCMineConsumablesVC.SCMineHouseSelectCell.titleLabel.font", alignment: .left)
    /// 开关按钮
    private lazy var selectBtn: UIButton = {
        let selectBtn = UIButton.init(type: .custom)
        selectBtn.theme_setImage("Mine.SCMineSettingVC.SCMineSettingLanguageCell.selectBtn.selectImage", forState: .normal)
        return selectBtn
    }()
    
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
        guard let model = self.model as? SCNetResponseFamilyModel else { return }
        self.titleLabel.text = model.name
        self.selectBtn.isHidden = !model.isSelected
        if model.isSelected == true {
            self.titleLabel.theme_textColor = "Mine.SCMineConsumablesVC.SCMineHouseSelectCell.titleLabel.selectedTextColor"
        } else {
            self.titleLabel.theme_textColor = "Mine.SCMineConsumablesVC.SCMineHouseSelectCell.titleLabel.textColor"
        }
    }
}

extension SCMineHouseSelectCell {
    override func setupView() {
        super.setupView()
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.selectBtn)
    }
    
    override func setupLayout() {
        super.setupLayout()
        self.selectBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
            make.right.equalTo(self.selectBtn.snp.left).offset(-2)
        }
        
    }
}

