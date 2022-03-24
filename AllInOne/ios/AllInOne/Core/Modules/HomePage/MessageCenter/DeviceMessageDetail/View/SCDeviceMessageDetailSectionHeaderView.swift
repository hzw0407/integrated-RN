//
//  SCDeviceMessageDetailSectionHeaderView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/25.
//

import UIKit

class SCDeviceMessageDetailSectionHeaderView: SCBasicTableViewHeaderFooterView {

    private lazy var titleLabel: UILabel = UILabel(textColor: "HomePage.MessageCenterController.DeviceMessageDetailController.SectionHeader.titleLabel.textColor", font: "HomePage.MessageCenterController.DeviceMessageDetailController.SectionHeader.titleLabel.font")

    private lazy var bottomCornerView: UIView = UIView(corner: UIRectCorner(rawValue: UIRectCorner.topLeft.rawValue | UIRectCorner.topRight.rawValue), backgroundColor: "HomePage.MessageCenterController.DeviceMessageDetailController.SectionHeader.cornerBackgroundColor", cornerRadius: 8, size: CGSize(width: kSCScreenWidth - 2 * 20, height: 8))
    
    override func set(model: Any?) {
        guard let text = model as? String else { return }
        self.titleLabel.text = text
    }
}

extension SCDeviceMessageDetailSectionHeaderView {
    override func setupView() {
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.bottomCornerView)
    }
    
    override func setupLayout() {
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.bottom.equalTo(self.bottomCornerView.snp.top).offset(-12)
            make.left.right.equalToSuperview().inset(24)
        }
        self.bottomCornerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
            make.height.equalTo(8)
        }
    }
}
