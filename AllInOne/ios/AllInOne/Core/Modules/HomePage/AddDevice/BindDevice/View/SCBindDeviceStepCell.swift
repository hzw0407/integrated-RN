//
//  SCBindDeviceStepCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/15.
//

import UIKit

protocol SCBindDeviceStepCellDelegate: AnyObject {
    func cell(didTapReason cell: SCBindDeviceStepCell)
}

class SCBindDeviceStepCell: SCBasicTableViewCell {
    
    weak var delegate: SCBindDeviceStepCellDelegate?
    
    private lazy var contentLabel: UILabel = UILabel(textColor: "HomePage.AddDeviceController.BindDeviceController.StepCell.contentLabel.textColor", font: "HomePage.AddDeviceController.BindDeviceController.StepCell.contentLabel.font", numberLines: 0)
    
    private lazy var successImageView: UIImageView = UIImageView(image: "HomePage.AddDeviceController.BindDeviceController.StepCell.successImage", contentMode: .scaleAspectFit)
    
    private lazy var loadingImageView: UIImageView = UIImageView(image: "HomePage.AddDeviceController.BindDeviceController.StepCell.loadingImage", contentMode: .scaleAspectFit)
    
    private lazy var reasonButton: UIButton = {
        let btn = UIButton(tempLocalize("可能失败的原因？"), titleColor: "HomePage.AddDeviceController.BindDeviceController.StepCell.reasonButton.textColor", font: "HomePage.AddDeviceController.BindDeviceController.StepCell.reasonButton.font", target: self, action: #selector(reasonButtonAction))
        btn.titleLabel?.numberOfLines = 0
        btn.isHidden = true
        return btn
    }()
    
    private lazy var rotationAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = CGFloat.pi * 2.0
        animation.duration = 1
        animation.isCumulative = true
        animation.repeatCount = 10000
        return animation
    }()
    
    override func set(model: Any?) {
        self.model = model
        guard let model = model as? SCBindDeviceStepModel else { return }
        
        self.contentLabel.text = model.content
        
        self.successImageView.isHidden = model.status != .success
        self.loadingImageView.isHidden = model.status != .loading
        
        if model.status == .loading {
            self.startAnimation()
        }
        else {
            self.stopAnimation()
        }
        
        if model.status == .fail {
            self.reasonButton.isHidden = false
            self.contentLabel.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(40)
                make.top.bottom.equalToSuperview().inset(8)
//                make.right.lessThanOrEqualTo(self.reasonButton.snp.left).offset(-10)
                make.right.lessThanOrEqualTo(self.contentView.snp.centerX).offset(20)
            }
        }
        else {
            self.reasonButton.isHidden = true
            self.contentLabel.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(40)
                make.top.bottom.equalToSuperview().inset(8)
                make.right.lessThanOrEqualTo(self.successImageView.snp.left).offset(-10)
            }
        }
    }
    
    override func set(delegate: Any?) {
        self.delegate = delegate as? SCBindDeviceStepCellDelegate
    }
}

extension SCBindDeviceStepCell {
    override func setupView() {
        self.contentView.addSubview(self.contentLabel)
        self.contentView.addSubview(self.loadingImageView)
        self.contentView.addSubview(self.successImageView)
        self.contentView.addSubview(self.reasonButton)
    }
    
    override func setupLayout() {
        self.contentLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(40)
            make.top.bottom.equalToSuperview().inset(8)
            make.right.lessThanOrEqualTo(self.successImageView.snp.left).offset(-10)
        }
        self.successImageView.snp.makeConstraints { make in
            make.width.height.equalTo(22)
            make.right.equalToSuperview().offset(-40)
            make.centerY.equalToSuperview()
        }
        self.loadingImageView.snp.makeConstraints { make in
            make.edges.equalTo(self.successImageView)
        }
        self.reasonButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-40)
            make.top.bottom.equalToSuperview()
            make.width.lessThanOrEqualTo(kSCScreenWidth / 2 - 20 - 10 - 40)
        }
    }
    
    private func startAnimation() {
        self.loadingImageView.layer.add(self.rotationAnimation, forKey: "rotationAnimation")
    }
    
    private func stopAnimation() {
        self.loadingImageView.layer.removeAllAnimations()
    }
    
    @objc private func reasonButtonAction() {
        self.delegate?.cell(didTapReason: self)
    }
}
