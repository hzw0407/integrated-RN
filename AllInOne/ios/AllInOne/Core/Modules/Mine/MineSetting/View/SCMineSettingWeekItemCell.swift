//
//  SCMineSettingWeekItemCell.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/23.
//

import UIKit

class SCMineSettingWeekItemModel: SCBasicModel {
    var week: String = ""
    var isSelected: Bool = false
}

protocol SCMineSettingWeekItemCellDelegate: AnyObject {
    func cell(_ cell: SCMineSettingWeekItemCell, didSelectedAction model: SCMineSettingWeekItemModel, isSelected: Bool)
}

class SCMineSettingWeekItemCell: SCBasicTableViewCell {

    private weak var delegate: SCMineSettingWeekItemCellDelegate?
    /// 标题
    private lazy var titleLabel: UILabel = UILabel(textColor: "Mine.SCMineBaseCell.titleLabel.textColor", font: "Mine.SCMineBaseCell.titleLabel.font", alignment: .left)
    /// 开关按钮
    public lazy var selectBtn: UIButton = {
        let noticeSwitch = UIButton.init(type: .custom)
        noticeSwitch.theme_setImage("Mine.SCMineSettingVC.SCMineSettingWeekItemCell.selectBtn.normalImage", forState: .normal)
        noticeSwitch.theme_setImage("Mine.SCMineSettingVC.SCMineSettingWeekItemCell.selectBtn.selectImage", forState: .selected)
        noticeSwitch.addTarget(self, action: #selector(selectBtn(btn:)), for: .touchUpInside)
        return noticeSwitch
    }()
    
    var cellType = SCMineInfoEditTextCellType.noArrow
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
        guard let model = self.model as? SCMineSettingWeekItemModel else { return }
        self.titleLabel.text = model.week
        self.selectBtn.isSelected = model.isSelected
    }
    
    override func set(delegate: Any?) {
        self.delegate = delegate as? SCMineSettingWeekItemCellDelegate
    }

}

extension SCMineSettingWeekItemCell {
    override func setupView() {
        super.setupView()
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.selectBtn)
    }
    
    override func setupLayout() {
        super.setupLayout()
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
            make.width.equalTo((UIScreen.main.bounds.size.width - 40) / 2.0)
        }
        self.selectBtn.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.width.equalTo(60)
            make.top.bottom.equalTo(0)
        }
    }
}

// MARK: - Actions
extension SCMineSettingWeekItemCell {
    @objc private func selectBtn(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        if let model = self.model as? SCMineSettingWeekItemModel {
            model.isSelected = btn.isSelected
        }
        self.delegate?.cell(self, didSelectedAction: self.model as! SCMineSettingWeekItemModel, isSelected: btn.isSelected)
    }
}
