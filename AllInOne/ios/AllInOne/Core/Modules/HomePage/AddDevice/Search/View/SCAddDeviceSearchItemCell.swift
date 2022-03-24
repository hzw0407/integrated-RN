//
//  SCAddDeviceSearchItemCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/14.
//

import UIKit

class SCAddDeviceSearchItemCell: SCBasicTableViewCell {

    private lazy var coverImageView: UIImageView = UIImageView(contentMode: .scaleAspectFit)
    
    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.AddDeviceController.SearchViewController.ItemCell.nameLabel.textColor", font: "HomePage.AddDeviceController.SearchViewController.ItemCell.nameLabel.font", numberLines: 2)
    
    private lazy var arrowImageView: UIImageView = UIImageView(image: "Global.ItemCell.arrowImage", contentMode: .scaleAspectFit)
   
    override func set(model: Any?) {
        guard let model = model as? SCNetResponseProductModel else { return }
        let path = SCSmartNetworking.sharedInstance.getHttpPath(forPath: model.photoUrl)
        let url = URL(string: path)
        self.coverImageView.sd_setImage(with: url, completed: nil)
        self.nameLabel.text = model.name
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension SCAddDeviceSearchItemCell {
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
            make.centerY.equalToSuperview()
        }
        self.arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
}
