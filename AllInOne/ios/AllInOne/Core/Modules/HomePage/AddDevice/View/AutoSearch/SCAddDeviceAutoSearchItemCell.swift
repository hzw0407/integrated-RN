//
//  SCAddDeviceAutoSearchItemCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/14.
//

import UIKit

class SCAddDeviceAutoSearchItemCell: SCBasicCollectionViewCell {
    private lazy var coverImageView: UIImageView = UIImageView(image: nil, contentMode: .scaleAspectFit, cornerRadius: nil)
    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.AddDeviceController.ProductItemCell.nameLabel.textColor", font: "HomePage.AddDeviceController.ProductItemCell.nameLabel.font", numberLines: 2, alignment: .center)
    
    override func set(model: Any?) {
        guard let model = model as? SCNetResponseProductModel else { return }
        self.model = model
        let path = SCSmartNetworking.sharedInstance.getHttpPath(forPath: model.photoUrl)
        let url = URL(string: path)
        self.coverImageView.sd_setImage(with: url, completed: nil)
        self.nameLabel.text = model.name
    }
}

extension SCAddDeviceAutoSearchItemCell {
    override func setupView() {
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        
        self.contentView.addSubview(self.coverImageView)
        self.contentView.addSubview(self.nameLabel)
    }
    
    override func setupLayout() {
        self.coverImageView.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(17)
        }
        self.nameLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.top.equalTo(self.coverImageView.snp.bottom).offset(12)
        }
    }
}
