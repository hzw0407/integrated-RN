//
//  SCMineBaseCell.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/14.
//

import UIKit
import sqlcipher

class SCMineBaseCell: SCBasicTableViewCell {
    /// 背景颜色
    public lazy var colorBgView: UIView = {
        let colorBgView = UIView()
        colorBgView.theme_backgroundColor = "Mine.SCMineBaseCell.colorBgView.backgroundColor"
        return colorBgView
    }()
    
    /// 底部横线
    public lazy var bottomLineView: UIView = {
        let bottomLineView = UIView()
        bottomLineView.theme_backgroundColor = "Mine.SCMineBaseCell.bottomLineView.backgroundColor"
        bottomLineView.isHidden = true
        return bottomLineView
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func cornerRadius(cornerRadius: CGFloat, top: Bool, bottom: Bool, cornerFrame: CGRect) {
        var corners: UIRectCorner
        if top == true, bottom == true {
            corners = [.topLeft, .topRight, .bottomLeft, .bottomRight]
            self.bottomLineView.isHidden = true
        } else if top == true, bottom == false {
            corners = [.topLeft, .topRight]
            self.bottomLineView.isHidden = false
        } else if top == false, bottom == true {
            corners = [.bottomLeft, .bottomRight]
            self.bottomLineView.isHidden = true
        } else {
            corners = []
            self.bottomLineView.isHidden = false
        }
        // 切圆角
        let maskPath = UIBezierPath.init(roundedRect: cornerFrame, byRoundingCorners: corners, cornerRadii: CGSize.init(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame         = cornerFrame;
        maskLayer.path          = maskPath.cgPath;
        self.colorBgView.layer.mask = maskLayer;
    }

}

extension SCMineBaseCell {
    override func setupView() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.addSubview(self.colorBgView)
        self.colorBgView.addSubview(self.bottomLineView)
    }
    
    override func setupLayout() {
        self.colorBgView.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.bottom.equalTo(0)
        }
        self.bottomLineView.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.bottom.equalTo(0)
            make.height.equalTo(0.5)
        }
    }
}
