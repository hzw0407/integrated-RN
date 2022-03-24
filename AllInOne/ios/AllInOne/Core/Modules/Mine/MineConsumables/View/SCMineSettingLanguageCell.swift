//
//  SCMineSettingLanguageCell.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/15.
//

import UIKit


protocol SCMineSettingLanguageCellDelegate: AnyObject {
    func cell(_ cell: SCMineSettingLanguageCell, didSelected model: SCMineInfoEditModel)
    func cell(_ cell: SCMineSettingLanguageCell, didSwicthAction model: SCMineInfoEditModel, isOpen: Bool)
}

class SCMineSettingLanguageCell: SCMineBaseCell {
    
    private weak var delegate: SCMineSettingLanguageCellDelegate?
    /// 标题
    private lazy var titleLabel: UILabel = UILabel(textColor: "Mine.SCMineBaseCell.titleLabel.textColor", font: "Mine.SCMineBaseCell.titleLabel.font", alignment: .left)
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
        guard let model = self.model as? SCMineSettingLanguageModel else { return }
        self.titleLabel.text = model.title
        self.selectBtn.isHidden = !model.isSelected
        self.cornerRadius(cornerRadius: 18, top: model.cornerRadiusTop, bottom: model.cornerRadiusBottom, cornerFrame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 40, height: 56))
    }
    
    override func set(delegate: Any?) {
        self.delegate = delegate as? SCMineSettingLanguageCellDelegate
    }
}

extension SCMineSettingLanguageCell {
    override func setupView() {
        super.setupView()
        self.colorBgView.addSubview(self.titleLabel)
        self.colorBgView.addSubview(self.selectBtn)
    }
    
    override func setupLayout() {
        super.setupLayout()
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
            make.width.equalTo((UIScreen.main.bounds.size.width - 40) / 2.0)
        }
        self.selectBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.width.equalTo(18)
            make.height.equalTo(18)
            make.centerY.equalToSuperview()
        }
    }
}

