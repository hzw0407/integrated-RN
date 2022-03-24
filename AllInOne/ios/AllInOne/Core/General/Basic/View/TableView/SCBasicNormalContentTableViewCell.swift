//
//  SCBasicNormalContentTableViewCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/7.
//

import UIKit

class SCBasicNormalContentTableViewCell: SCBasicTableViewCell {

    /// 标题
    private lazy var titleLabel: UILabel = UILabel(textColor: "Login.InputCell.titleLabel.textColor", font: "Login.InputCell.titleLabel.font")
    
    /// 内容
    private lazy var contentLabel: UILabel = UILabel(textColor: "Login.InputCell.titleLabel.textColor", font: "Login.InputCell.titleLabel.font", alignment: .right)
    
    private lazy var arrowImageView: UIImageView = UIImageView(image: "", contentMode: .scaleAspectFit)
    
    /// 线
    private lazy var topLineView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = "Login.InputCell.lineView.backgroundColor"
        return view
    }()
    
    /// 线
    private lazy var bottomLineView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = "Login.InputCell.lineView.backgroundColor"
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func set(model: Any?) {
        guard let model = model as? SCBasicNormalContentModel else { return }
        self.model = model
        
        self.titleLabel.text = model.title
        self.contentLabel.text = model.content
        
        var arrowMargin: CGFloat = -(20 + 20)
        if !model.hasArrow {
            arrowMargin = 20 - 10
        }
        self.arrowImageView.snp.updateConstraints { make in
            make.left.equalTo(self.contentView.snp.right).offset(arrowMargin)
        }
        
        self.topLineView.isHidden = !model.hasTopLine
        self.bottomLineView.isHidden = !model.hasBottomLine
    }
}

extension SCBasicNormalContentTableViewCell {
    override func setupView() {
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.contentLabel)
        self.contentView.addSubview(self.arrowImageView)
        self.contentView.addSubview(self.topLineView)
        self.contentView.addSubview(self.bottomLineView)
    }
    
    override func setupLayout() {
        let horizontalMargin: CGFloat = 20
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(horizontalMargin)
            make.top.equalToSuperview().offset(10)
            make.bottom.greaterThanOrEqualTo(self.contentView).offset(-10)
        }
        self.contentLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(self.contentView).offset(10)
            make.right.equalTo(self.arrowImageView.snp.left).offset(-10)
            make.bottom.greaterThanOrEqualTo(self.contentView).offset(-10)
            make.centerY.equalToSuperview()
            make.left.equalTo(self.titleLabel.snp.right).offset(10)
        }
        self.arrowImageView.snp.makeConstraints { make in
            make.left.equalTo(self.contentView.snp.right).offset(-(20 + horizontalMargin))
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        self.bottomLineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(horizontalMargin)
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview().offset(-0.5)
        }
        self.topLineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(horizontalMargin)
            make.height.equalTo(0.5)
            make.top.equalToSuperview()
        }
    }
}
