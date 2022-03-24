//
//  SCAddDeviceProductParentCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/14.
//

import UIKit

class SCAddDeviceProductParentCell: SCBasicTableViewCell {

    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.AddDeviceController.ProductParentCell.nameLabel.normalTextColor", font: "HomePage.AddDeviceController.ProductParentCell.nameLabel.normalFont", numberLines: 2)
    
    override func set(model: Any?) {
        guard let model = model as? SCNetResponseProductTypeParentModel else { return }
        self.nameLabel.text = model.name
        var textColor = ThemeColorPicker(keyPath: "HomePage.AddDeviceController.ProductParentCell.nameLabel.normalTextColor").value() as! UIColor
        var font = ThemeFontPicker(stringLiteral: "HomePage.AddDeviceController.ProductParentCell.nameLabel.normalFont").value() as! UIFont
        if model.isSelected {
            textColor = ThemeColorPicker(keyPath: "HomePage.AddDeviceController.ProductParentCell.nameLabel.selectTextColor").value() as! UIColor
            font = ThemeFontPicker(stringLiteral: "HomePage.AddDeviceController.ProductParentCell.nameLabel.selectFont").value() as! UIFont
        }
        
        self.nameLabel.textColor = textColor
        self.nameLabel.font = font
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

extension SCAddDeviceProductParentCell {
    override func setupView() {
        self.contentView.addSubview(self.nameLabel)
    }
    
    override func setupLayout() {
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.bottom.equalToSuperview().inset(10)
            make.height.greaterThanOrEqualTo(36)
        }
    }
}
