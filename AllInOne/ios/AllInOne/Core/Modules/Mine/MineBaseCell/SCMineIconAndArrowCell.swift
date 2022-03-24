//
//  SCMineIconAndArrowCell.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/15.
//

import UIKit

class SCMineIconAndArrowCell: SCMineBaseCell {
    
    /// 图片icon
    private lazy var leftIconImageView: UIImageView = UIImageView(image: "")
    /// 右边箭头
    private lazy var arrowImageView: UIImageView = UIImageView(image: "Mine.SCMineBaseCell.arrowImage")
    /// 标题
    private lazy var titleLabel: UILabel = UILabel(textColor: "Mine.SCMineBaseCell.titleLabel.textColor", font: "Mine.SCMineBaseCell.titleLabel.font")

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func set(model: Any?) {
        self.model = model
        guard let model = self.model as? SCMineItemModel else { return }
        self.titleLabel.text = model.title
        self.leftIconImageView.image = UIImage.init(named: model.leftIcon)
        self.cornerRadius(cornerRadius: 18, top: model.cornerRadiusTop, bottom: model.cornerRadiusBottom, cornerFrame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 40, height: model.cellHeight))
    }

}

extension SCMineIconAndArrowCell {
    override func setupView() {
        super.setupView()
        self.colorBgView.addSubview(self.leftIconImageView)
        self.colorBgView.addSubview(self.titleLabel)
        self.colorBgView.addSubview(self.arrowImageView)
    }
    
    override func setupLayout() {
        super.setupLayout()
        self.leftIconImageView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.height.width.equalTo(28)
            make.centerY.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.leftIconImageView.snp.right).offset(12)
            make.right.equalTo(-50)
            make.centerY.equalToSuperview()
        }
        self.arrowImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(20)
            make.right.equalTo(-20)
            make.centerY.equalToSuperview()
        }
    }
}
