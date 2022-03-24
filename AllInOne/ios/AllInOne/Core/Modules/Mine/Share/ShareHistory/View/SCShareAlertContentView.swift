//
//  SCShareAlertContentView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/28.
//

import UIKit

class SCShareDeviceAlertContentView: SCBasicView {
    private lazy var coverImageView: UIImageView = UIImageView(contentMode: .scaleAspectFit)
    private lazy var sourceLabel: UILabel = UILabel(textColor: "Global.ShareAlertContentView.Device.sourceLabel.textColor", font: "Global.ShareAlertContentView.Device.sourceLabel.font", alignment: .center)
    private lazy var contentLabel: UILabel = UILabel(text: tempLocalize("向你共享了一个设备"), textColor: "Global.ShareAlertContentView.Device.contentLabel.textColor", font: "Global.ShareAlertContentView.Device.contentLabel.font", alignment: .center)
    
    convenience init(imageUrl: String, source: String) {
        self.init()
        self.bounds = CGRect(x: 0, y: 0, width: kSCScreenWidth, height: 160)
        self.coverImageView.sd_setImage(with: URL(string: imageUrl), completed: nil)
        self.sourceLabel.text = source
    }
    
    override func setupView() {
        self.addSubview(self.coverImageView)
        self.addSubview(self.sourceLabel)
        self.addSubview(self.contentLabel)
    }
    
    override func setupLayout() {
        self.coverImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.height.equalTo(80)
            make.centerX.equalToSuperview()
        }
        self.sourceLabel.snp.makeConstraints { make in
            make.top.equalTo(self.coverImageView.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(40)
            make.height.equalTo(22)
        }
        self.contentLabel.snp.makeConstraints { make in
            make.top.equalTo(self.sourceLabel.snp.bottom).offset(8)
            make.left.right.equalTo(self.sourceLabel)
            make.height.equalTo(20)
        }
    }
}

class SCShareFamilyAlertContentView: SCBasicView {

    private lazy var coverImageView: UIImageView = UIImageView(contentMode: .scaleAspectFit)
    private lazy var nameLabel: UILabel = UILabel(textColor: "Global.ShareAlertContentView.Family.nameLabel.textColor", font: "Global.ShareAlertContentView.Family.nameLabel.font", alignment: .center)
    private lazy var sourceLabel: UILabel = UILabel(textColor: "Global.ShareAlertContentView.Family.sourceLabel.textColor", font: "Global.ShareAlertContentView.Family.sourceLabel.font", alignment: .center)
   
    
    convenience init(imageUrl: String, name: String, source: String) {
        self.init()
        self.bounds = CGRect(x: 0, y: 0, width: kSCScreenWidth, height: 160)
        self.coverImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: SCThemes.image("Global.GeneralImage.defaultAvatarImage"))
        self.nameLabel.text = name
        self.sourceLabel.text = tempLocalize("来自：") + source
    }
    
    override func setupView() {
        self.addSubview(self.coverImageView)
        self.addSubview(self.nameLabel)
        self.addSubview(self.sourceLabel)
    }
    
    override func setupLayout() {
        self.coverImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.height.equalTo(80)
            make.centerX.equalToSuperview()
        }
        self.nameLabel.snp.makeConstraints { make in
            make.top.equalTo(self.coverImageView.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(40)
            make.height.equalTo(22)
        }
        self.sourceLabel.snp.makeConstraints { make in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(8)
            make.left.right.equalTo(self.nameLabel)
            make.height.equalTo(20)
        }
    }
}
