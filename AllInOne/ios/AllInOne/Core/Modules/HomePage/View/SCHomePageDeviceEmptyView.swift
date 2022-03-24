//
//  SCHomePageDeviceEmptyView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/25.
//

import UIKit

class SCHomePageDeviceEmptyView: SCBasicView {

    private lazy var coverImageView: UIImageView = UIImageView(image: "HomePage.HomePageController.EmptyView.coverImage", contentMode: .scaleToFill)
    
    private lazy var titleLabel: UILabel = UILabel(text: tempLocalize("暂无设备"), textColor: "HomePage.HomePageController.EmptyView.titleLabel.textColor", font: "HomePage.HomePageController.EmptyView.titleLabel.font", numberLines: 0, alignment: .center)
    
    override func setupView() {
        self.addSubview(self.coverImageView)
        self.addSubview(self.titleLabel)
    }
    
    override func setupLayout() {
        let imageSize = self.coverImageView.image?.size ?? .zero
        let height = (kSCScreenWidth - 20 * 2) * (imageSize.height / imageSize.width)
        self.coverImageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(height)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.coverImageView).inset(20)
            make.bottom.equalTo(self.coverImageView).offset(-12)
        }
    }

}
