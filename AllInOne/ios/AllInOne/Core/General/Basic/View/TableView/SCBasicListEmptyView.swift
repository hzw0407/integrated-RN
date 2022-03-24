//
//  SCBasicListEmptyView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/30.
//

import UIKit
import SwiftTheme

class SCBasicListEmptyView: SCBasicView {

    var title: String = "" {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    var image: ThemeImagePicker = "" {
        didSet {
            self.coverImageView.theme_image = self.image
        }
    }
    
    private lazy var coverImageView: UIImageView = UIImageView(image: "Global.EmptyView.coverImage", contentMode: .scaleToFill)
    
    private lazy var titleLabel: UILabel = UILabel(text: tempLocalize("暂无数据"), textColor: "Global.EmptyView.titleLabel.textColor", font: "Global.EmptyView.titleLabel.font", numberLines: 0, alignment: .center)

    override func setupView() {
        self.addSubview(self.coverImageView)
        self.addSubview(self.titleLabel)
    }
    
    override func setupLayout() {
        self.coverImageView.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(124)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(self.coverImageView.snp.bottom).offset(12)
        }
    }
}
