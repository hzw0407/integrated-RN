//
//  SCAddDeviceProductChildHeaderView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/14.
//

import UIKit

class SCAddDeviceProductChildHeaderView: SCBasicCollectionReusableView {
    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.AddDeviceController.ProductChildHeader.nameLabel.textColor", font: "HomePage.AddDeviceController.ProductChildHeader.nameLabel.font", numberLines: 2)
    
    override func set(model: Any?) {
        guard let model = model as? SCNetResponseProductTypeMiddleModel else { return }
        self.nameLabel.text = model.name
    }
}

extension SCAddDeviceProductChildHeaderView {
    override func setupView() {
        self.addSubview(self.nameLabel)
    }
    
    override func setupLayout() {
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
    }
}
