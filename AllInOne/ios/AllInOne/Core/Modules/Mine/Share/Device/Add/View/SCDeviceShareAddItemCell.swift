//
//  SCDeviceShareAddItemCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/29.
//

import UIKit

class SCDeviceShareAddItemCell: SCBasicCollectionViewCell {
    private lazy var coverImageView: UIImageView = UIImageView(contentMode: .scaleAspectFit)
    
    override func set(model: Any?) {
        guard let model = model as? String else { return }
        self.coverImageView.sd_setImage(with: URL(string: model))
    }
    
    override func setupView() {
        self.contentView.addSubview(self.coverImageView)
    }
    
    override func setupLayout() {
        self.coverImageView.snp.makeConstraints { make in
            make.width.height.equalTo(68)
            make.center.equalToSuperview()
        }
    }
}
