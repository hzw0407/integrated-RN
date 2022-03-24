//
//  SCFamilyListAutoChangeCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/20.
//

import UIKit

fileprivate let cornerRadius: CGFloat = 16

class SCFamilyListAutoChangeCell: SCBasicTableViewCell {
    private lazy var topCornerView: UIView = UIView(corner: UIRectCorner(rawValue: UIRectCorner.topLeft.rawValue | UIRectCorner.topRight.rawValue), backgroundColor: "HomePage.FamilyListController.ItemCell.backgroundColor", cornerRadius: cornerRadius, size: CGSize(width: kSCScreenWidth - 2 * 20, height: cornerRadius))
    
    private lazy var bottomCornerView: UIView = UIView(corner: UIRectCorner(rawValue: UIRectCorner.bottomLeft.rawValue | UIRectCorner.bottomRight.rawValue), backgroundColor: "HomePage.FamilyListController.ItemCell.backgroundColor", cornerRadius: cornerRadius, size: CGSize(width: kSCScreenWidth - 2 * 20, height: cornerRadius))
    
    private lazy var topBackView: UIView = UIView(lineBackgroundColor: "HomePage.FamilyListController.ItemCell.backgroundColor")
    
    private lazy var bottomBackView: UIView = UIView(lineBackgroundColor: "HomePage.FamilyListController.ItemCell.backgroundColor")
    
    private var middleView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = "HomePage.FamilyListController.ItemCell.backgroundColor"
        return view
    }()
    
    private lazy var autoChangeLabel: UILabel = UILabel(text: tempLocalize("根据位置，自动切换家庭"), textColor: "HomePage.FamilyListController.ItemCell.autoChangeLabel.textColor", font: "HomePage.FamilyListController.ItemCell.autoChangeLabel.font", numberLines: 0)
    
    private lazy var autoChangeSwitch: UISwitch = SCBasicSwitch()
    
    private lazy var lineView: UIView = UIView(lineBackgroundColor: "HomePage.FamilyListController.ItemCell.lineBackgroundColor")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func set(model: Any?) {
        guard let model = model as? SCNetResponseFamilyModel else { return }
        self.autoChangeSwitch.isOn = model.isOnOfAutoChange
        if model.corner != nil {
            self.topBackView.isHidden = model.corner!.rawValue & UIRectCorner.topLeft.rawValue != 0
            self.bottomBackView.isHidden = model.corner!.rawValue & UIRectCorner.bottomLeft.rawValue != 0
        }
        else {
            self.topBackView.isHidden = false
            self.bottomBackView.isHidden = false
        }
    }
}

extension SCFamilyListAutoChangeCell {
    override func setupView() {
        self.contentView.addSubview(self.topCornerView)
        self.contentView.addSubview(self.middleView)
        self.contentView.addSubview(self.bottomCornerView)
        self.contentView.addSubview(self.topBackView)
        self.contentView.addSubview(self.bottomBackView)
        self.contentView.addSubview(self.autoChangeLabel)
        self.contentView.addSubview(self.autoChangeSwitch)
    }
    
    override func setupLayout() {
        self.topBackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(cornerRadius)
        }
        self.bottomBackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(cornerRadius)
        }
        self.topCornerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview()
            make.height.equalTo(cornerRadius)
        }
        self.bottomCornerView.snp.makeConstraints { make in
            make.left.right.height.equalTo(self.topCornerView)
            make.bottom.equalToSuperview()
        }
        self.middleView.snp.makeConstraints { make in
            make.left.right.equalTo(self.topCornerView)
            make.top.bottom.equalToSuperview().inset(cornerRadius)
        }
        self.autoChangeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20 * 2)
            make.right.equalTo(self.autoChangeSwitch.snp.left).offset(5)
            make.top.bottom.equalToSuperview().inset(18)
        }
        self.autoChangeSwitch.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20 * 2)
//            make.width.equalTo(36)
//            make.height.equalTo(20)
            make.width.equalTo(50)
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
    }
}
