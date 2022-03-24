//
//  SCMessageCeterDeviceMenuView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/24.
//

import UIKit

class SCMessageCeterDeviceMenuView: SCBasicView {
    
    var title: String? {
        didSet {
            self.nameLabel.text = self.title
        }
    }
    
    private var didClickMenuBlock: (() -> Void)?
    
    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.MessageCenterController.DeviceMessage.MenuView.textColor", font: "HomePage.MessageCenterController.DeviceMessage.MenuView.font")
    private lazy var imageView: UIImageView = UIImageView(image: "HomePage.MessageCenterController.DeviceMessage.MenuView.image")
    
    private lazy var button: UIButton = UIButton(target: self, action: #selector(buttonAction))

    convenience init(didClickMenuHandle: (() -> Void)?) {
        self.init(frame: .zero)
        self.didClickMenuBlock = didClickMenuHandle
    }
}

extension SCMessageCeterDeviceMenuView {
    override func setupView() {
        self.addSubview(self.nameLabel)
        self.addSubview(self.imageView)
        self.addSubview(self.button)
    }
    
    override func setupLayout() {
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.bottom.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        self.imageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
            make.left.equalTo(self.nameLabel.snp.right).offset(8)
            make.right.lessThanOrEqualTo(self).offset(-20)
        }
        self.button.snp.makeConstraints { make in
            make.left.equalTo(self.nameLabel)
            make.right.equalTo(self.imageView)
            make.top.bottom.equalToSuperview()
        }
    }
    
    @objc private func buttonAction() {
        self.didClickMenuBlock?()
    }
}
