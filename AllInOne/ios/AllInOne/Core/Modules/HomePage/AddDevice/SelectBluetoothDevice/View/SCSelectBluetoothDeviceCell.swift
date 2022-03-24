//
//  SCSelectBluetoothDeviceCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/16.
//

import UIKit

class SCSelectBluetoothDeviceCell: SCBasicTableViewCell {

    private lazy var coverImageView: UIImageView = UIImageView(contentMode: .scaleAspectFit)
    
    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.AddDeviceController.SearchViewController.ItemCell.nameLabel.textColor", font: "HomePage.AddDeviceController.SearchViewController.ItemCell.nameLabel.font", numberLines: 2)
    
    private lazy var arrowImageView: UIImageView = UIImageView(image: "Global.ItemCell.arrowImage", contentMode: .scaleAspectFit)
    
    
    override func set(model: Any?) {
        guard let model = model as? SCSelectBluetoothDeviceModel, let product = model.product, let peripheral = model.peripheral else { return }
        let path = SCSmartNetworking.sharedInstance.getHttpPath(forPath: product.photoUrl)
        let url = URL(string: path)
        self.coverImageView.sd_setImage(with: url, completed: nil)
        var ext = ""
        if let mac = peripheral.mac, mac.count >= 6 {
            ext = (mac as NSString).substring(from: mac.count - 6)
            ext = "(" + ext + ")"
        }
        self.nameLabel.text = product.name + ext
    }
}

extension SCSelectBluetoothDeviceCell {
    override func setupView() {
        self.contentView.addSubview(self.coverImageView)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.arrowImageView)
    }
    
    override func setupLayout() {
        self.coverImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(44)
            make.centerY.equalToSuperview()
        }
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.coverImageView.snp.right).offset(12)
            make.right.equalTo(self.arrowImageView.snp.left).offset(-10)
            make.top.bottom.equalToSuperview().inset(26)
        }
        self.arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
}
