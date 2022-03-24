//
//  SCCountryListCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/24.
//

import UIKit

class SCCountryListCell: SCBasicTableViewCell {

    private lazy var titleLabel: UILabel = UILabel(textColor: "CountryList.ItemCell.titleLabel.textColor", font: "CountryList.ItemCell.titleLabel.font")
    
    private lazy var selectedImageView: UIImageView = UIImageView(image: "Global.GeneralImage.saveImage")
    
    override func set(model: Any?) {
        guard let model = model as? SCCountryModel else { return }
        self.titleLabel.text = model.name
        self.selectedImageView.isHidden = !model.isSelected
    }
}

extension SCCountryListCell {
    override func setupView() {
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.selectedImageView)
    }
    
    override func setupLayout() {
        let margin: CGFloat = 24
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.right.equalTo(self.selectedImageView.snp.left).offset(-10)
            make.top.bottom.equalToSuperview().inset(12)
        }
        self.selectedImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-36)
            make.width.height.equalTo(18)
            make.centerY.equalToSuperview()
        }
    }
}
