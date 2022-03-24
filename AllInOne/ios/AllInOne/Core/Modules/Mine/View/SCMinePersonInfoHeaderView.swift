//
//  SCMinePersonInfoHeaderView.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/14.
//

import UIKit

class SCMinePersonInfoHeaderView: SCBasicView {
    /// 用户名
    private lazy var accountLabel: UILabel = UILabel(textColor: "Mine.MineController.SCMinePersonInfoHeaderView.accountLabel.textColor", font: "Mine.MineController.SCMinePersonInfoHeaderView.accountLabel.font")
    /// 头像
    private lazy var avatarImageView: UIImageView = UIImageView(image: "Global.GeneralImage.defaultAvatarImage", contentMode: .scaleAspectFill, cornerRadius: 40)
    /// 手机
    private lazy var telephoneLabel: UILabel = UILabel(textColor: "Mine.MineController.SCMinePersonInfoHeaderView.telephoneLabel.textColor", font: "Mine.MineController.SCMinePersonInfoHeaderView.telephoneLabel.font")
    /// 设备数量
    private lazy var deviceCountLabel: UILabel = UILabel(textColor: "Mine.MineController.SCMinePersonInfoHeaderView.deviceCountLabel.textColor", font: "Mine.MineController.SCMinePersonInfoHeaderView.deviceCountLabel.font")
    /// 编辑按钮
    private lazy var editButton: UIButton = {
        let btn = UIButton(tempLocalize("编辑"), titleColor: "Mine.MineController.SCMinePersonInfoHeaderView.editButton.textColor", font: "Mine.MineController.SCMinePersonInfoHeaderView.editButton.font", target: self, action: #selector(editButtonAction), backgroundColor: nil, cornerRadius: 10)
        btn.setTitle(tempLocalize("编辑"), for: .selected)
        return btn
    }()
    /// 点击编辑回调
    public var editClickBlock: (() -> Void)?
}

extension SCMinePersonInfoHeaderView {
    override func setupView() {
        self.addSubview(self.avatarImageView)
        self.addSubview(self.accountLabel)
        self.addSubview(self.telephoneLabel)
        self.addSubview(self.deviceCountLabel)
        self.addSubview(self.editButton)
    }
    func setDataModel(model:SCNetResponseUserProfileModel){
        self.avatarImageView.sd_setImage(with: URL(string: model.avatarUrl), placeholderImage: SCThemes.image("Global.GeneralImage.defaultAvatarImage"))
  
        self.deviceCountLabel.text = String(model.device) + "个设备"
        
        var username = model.email
        if username.count == 0 {
            username = model.phone
        }
        var nickname = model.nickname
        if nickname.count == 0 {
            nickname = username
        }
        
        self.accountLabel.text = nickname
        self.telephoneLabel.text = username
    }
    override func setupLayout() {
        self.avatarImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(80)
            make.centerY.equalToSuperview()
        }
        self.accountLabel.snp.makeConstraints { make in
            make.left.equalTo(self.avatarImageView.snp.right).offset(20)
            make.top.equalTo(self.avatarImageView.snp.top)
            make.height.equalTo(31)
        }
        self.telephoneLabel.snp.makeConstraints { make in
            make.left.equalTo(self.accountLabel)
            make.top.equalTo(self.accountLabel.snp.bottom).offset(8)
            make.height.equalTo(22)
        }
        self.deviceCountLabel.snp.makeConstraints { make in
            make.left.equalTo(self.accountLabel)
            make.top.equalTo(self.telephoneLabel.snp.bottom).offset(0)
            make.height.equalTo(17)
        }
        self.editButton.snp.makeConstraints { make in
            make.right.equalTo(0)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
    }
    
    @objc private func editButtonAction() {
        self.editClickBlock?()
    }
}
