//
//  SCDeviceMessageDetailSectionFooterView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/25.
//

import UIKit

class SCDeviceMessageDetailSectionFooterView: SCBasicTableViewHeaderFooterView {

    private lazy var bottomCornerView: UIView = UIView(corner: UIRectCorner(rawValue: UIRectCorner.topLeft.rawValue | UIRectCorner.topRight.rawValue), backgroundColor: "HomePage.MessageCenterController.DeviceMessageDetailController.SectionHeader.cornerBackgroundColor", cornerRadius: 8, size: CGSize(width: kSCScreenWidth - 2 * 20, height: 8))

}

extension SCDeviceMessageDetailSectionFooterView {
    override func setupView() {
        self.contentView.addSubview(self.bottomCornerView)
    }
    
    override func setupLayout() {
        self.bottomCornerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview()
            make.height.equalTo(8)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
}
