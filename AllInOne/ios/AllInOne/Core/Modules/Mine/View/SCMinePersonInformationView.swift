//
//  SCMinePersonInformationView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/26.
//

import UIKit

class SCMinePersonInformationView: SCBasicView {
    private var didTapViewBlock: (() -> Void)?
    
    private lazy var accountLabel: UILabel = UILabel(textColor: "Mine.MineController.PersonInformation.accountLabel.textColor", font: "Mine.MineController.PersonInformation.accountLabel.font")
    private lazy var avatarImageView: UIImageView = UIImageView(image: "Global.GeneralImage.defaultAvatarImage", contentMode: .scaleAspectFill, cornerRadius: 25)
    
    func add(didTapViewHandler: (() -> Void)?) {
        self.didTapViewBlock = didTapViewHandler
    }
    
    func set(model: SCNetResponseUserProfileModel) {
        self.accountLabel.text = model.email
        
        let avatarPath = SCSmartNetworking.sharedInstance.getHttpPath(forPath: model.avatarUrl)
        if let url = URL(string: avatarPath) {
            self.avatarImageView.sd_setImage(with: url, placeholderImage: SCThemes.image("Global.GeneralImage.defaultAvatarImage"))
        }
    }
}

extension SCMinePersonInformationView {
    override func setupView() {
        self.addSubview(self.avatarImageView)
        self.addSubview(self.accountLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapGestureAction))
        self.addGestureRecognizer(tap)
    }
    
    override func setupLayout() {
        self.avatarImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(50)
            make.centerY.equalToSuperview()
        }
        self.accountLabel.snp.makeConstraints { make in
            make.left.equalTo(self.avatarImageView.snp.right).offset(20)
            make.right.equalToSuperview().offset(-20)
        }
    }
    
    @objc private func backgroundTapGestureAction() {
        self.didTapViewBlock?()
    }
}
