//
//  SCMineInfoEditTextCell.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/15.
//

import UIKit

protocol SCMineInfoEditTextCellDelegate: AnyObject {
    func cell(_ cell: SCMineInfoEditTextCell, didSelected model: SCMineInfoEditModel)
    func cell(_ cell: SCMineInfoEditTextCell, didSwicthAction model: SCMineInfoEditModel, isOpen: Bool)
}

class SCMineInfoEditTextCell: SCMineBaseCell {
    
    private weak var delegate: SCMineInfoEditTextCellDelegate?
    /// 标题
    private lazy var titleLabel: UILabel = UILabel(textColor: "Mine.SCMineBaseCell.titleLabel.textColor", font: "Mine.SCMineBaseCell.titleLabel.font", alignment: .left)
    /// 子标题
    private lazy var subTitleLabel: UILabel = UILabel(textColor: "Mine.SCMineInfoEditController.SCMineInfoEditTextCell.subTitleLabel.textColor", font: "Mine.SCMineInfoEditController.SCMineInfoEditTextCell.subTitleLabel.font", alignment: .right)
    /// 右边箭头
    private lazy var arrowImageView: UIImageView = UIImageView(image: "Mine.SCMineBaseCell.arrowImage")
    /// 开关按钮
    private lazy var noticeSwitch: UIButton = {
        let noticeSwitch = UIButton.init(type: .custom)
        noticeSwitch.theme_setImage("Mine.SCMineSettingVC.SCMineInfoTextAndSwitchCell.noticeSwitch.normalImage", forState: .normal)
        noticeSwitch.theme_setImage("Mine.SCMineSettingVC.SCMineInfoTextAndSwitchCell.noticeSwitch.selectImage", forState: .selected)
        noticeSwitch.addTarget(self, action: #selector(noticeSwitch(btn:)), for: .touchUpInside)
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
        guard let model = self.model as? SCMineInfoEditModel else { return }
        self.titleLabel.text = model.title
        self.subTitleLabel.text = model.subTitle
        self.noticeSwitch.isSelected = model.isSwitchOn
        switch model.cellType {
        case .noArrow:
            self.subTitleLabel.snp.updateConstraints { make in
                make.right.equalTo(-20)
            }
            self.arrowImageView.isHidden = true
            self.noticeSwitch.isHidden = true
        case .textAndArrow:
            self.subTitleLabel.snp.updateConstraints { make in
                make.right.equalTo(-52)
            }
            self.arrowImageView.isHidden = false
            self.noticeSwitch.isHidden = true
        case .arrow:
            self.subTitleLabel.snp.updateConstraints { make in
                make.right.equalTo(-52)
            }
            self.arrowImageView.isHidden = false
            self.noticeSwitch.isHidden = true
        case .switchAction:
            self.arrowImageView.isHidden = true
            self.noticeSwitch.isHidden = false
        }
        if model.isEnable == true {
            self.titleLabel.theme_textColor = "Mine.SCMineBaseCell.titleLabel.textColor"
            self.subTitleLabel.theme_textColor = "Mine.SCMineInfoEditController.SCMineInfoEditTextCell.subTitleLabel.textColor"
            self.arrowImageView.theme_image = "Mine.SCMineBaseCell.arrowImage"
        } else {
            self.titleLabel.theme_textColor = "Mine.SCMineBaseCell.titleLabel.disableTextColor"
            self.subTitleLabel.theme_textColor = "Mine.SCMineBaseCell.titleLabel.disableTextColor"
            self.arrowImageView.theme_image = "Mine.SCMineBaseCell.disableArrowImage"
        }
        
        self.isUserInteractionEnabled = model.isEnable
        self.cornerRadius(cornerRadius: 18, top: model.cornerRadiusTop, bottom: model.cornerRadiusBottom, cornerFrame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 40, height: 56))
    }
    
    override func set(delegate: Any?) {
        self.delegate = delegate as? SCMineInfoEditTextCellDelegate
    }
}

extension SCMineInfoEditTextCell {
    override func setupView() {
        super.setupView()
        self.colorBgView.addSubview(self.titleLabel)
        self.colorBgView.addSubview(self.subTitleLabel)
        self.colorBgView.addSubview(self.arrowImageView)
        self.colorBgView.addSubview(self.noticeSwitch)
        self.subTitleLabel.alpha = 0.6
    }
    
    override func setupLayout() {
        super.setupLayout()
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
            make.width.equalTo((UIScreen.main.bounds.size.width - 40) / 2.0)
        }
        self.subTitleLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo((UIScreen.main.bounds.size.width - 40) / 2.0)
        }
        self.arrowImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(20)
            make.right.equalTo(-20)
            make.centerY.equalToSuperview()
        }
        self.noticeSwitch.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.width.equalTo(36)
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: - Actions
extension SCMineInfoEditTextCell {
    @objc private func noticeSwitch(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        
        guard let model = self.model as? SCMineInfoEditModel else { return }
        model.isSwitchOn = btn.isSelected
        self.delegate?.cell(self, didSwicthAction: self.model as! SCMineInfoEditModel, isOpen: btn.isSelected)
    }
}

