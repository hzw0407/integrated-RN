//
//  SCAddDeviceProductItemCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/14.
//

import UIKit

class SCAddDeviceProductItemCell: SCBasicCollectionViewCell {
    private lazy var coverImageView: UIImageView = UIImageView(image: nil, contentMode: .scaleAspectFit, cornerRadius: nil)
    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.AddDeviceController.ProductItemCell.nameLabel.textColor", font: "HomePage.AddDeviceController.ProductItemCell.nameLabel.font", numberLines: 2, alignment: .center)
    private var cornerView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = "HomePage.AddDeviceController.ProductItemCell.backgroundColor"
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
//        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
        return view
    }()
    
    private var backView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = "HomePage.AddDeviceController.ProductItemCell.backgroundColor"
        return view
    }()
    
    private func bezierPath() -> UIBezierPath {
        let width = kSCScreenWidth - 116 - 20
        let columns: CGFloat = 3
        let itemWidth: CGFloat = CGFloat(floorf(Float(width / columns)))
        let itemHeight: CGFloat = 113
        
        let corner = (self.model as? SCNetResponseProductModel)?.corner ?? .topLeft
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: itemWidth, height: itemHeight), byRoundingCorners: corner, cornerRadii: CGSize(width: 12, height: 12))
        return path
    }

    override func set(model: Any?) {
        guard let model = model as? SCNetResponseProductModel else { return }
        self.model = model
        let path = SCSmartNetworking.sharedInstance.getHttpPath(forPath: model.photoUrl)
        let url = URL(string: path)
        self.coverImageView.sd_setImage(with: url, completed: nil)
        self.nameLabel.text = model.name
        
        if model.corner != nil {
            (self.cornerView.layer.mask as? CAShapeLayer)?.path = self.bezierPath().cgPath
            self.cornerView.isHidden = false
            self.backView.isHidden = true
        }
        else {
            self.cornerView.isHidden = true
            self.backView.isHidden = false
        }
    }
}

extension SCAddDeviceProductItemCell {
    override func setupView() {
        self.contentView.addSubview(self.backView)
        self.contentView.addSubview(self.cornerView)
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
        self.backView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
        self.cornerView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
}
