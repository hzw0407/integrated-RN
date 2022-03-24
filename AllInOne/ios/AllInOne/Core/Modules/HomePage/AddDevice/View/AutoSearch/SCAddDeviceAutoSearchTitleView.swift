//
//  SCAddDeviceAutoSearchTitleView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/14.
//

import UIKit

class SCAddDeviceAutoSearchTitleView: SCBasicView {

    var count: Int = 0 {
        didSet {
            if count == 0 {
                self.titleLabel.text = tempLocalize("正在扫描附近的设备...")
            }
            else {
                self.titleLabel.text = tempLocalize("扫描到附近\(self.count)个设备")
            }
        }
    }
    
    private lazy var coverImageView = UIImageView(image: "HomePage.AddDeviceController.AutoSearchView.TitleView.image")
    private lazy var titleLabel: UILabel = UILabel(text: tempLocalize("正在扫描附近的设备..."), textColor: "HomePage.AddDeviceController.AutoSearchView.TitleView.textColor", font: "HomePage.AddDeviceController.AutoSearchView.TitleView.font")

    private lazy var rotationAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = CGFloat.pi * 2.0
        animation.duration = 1
        animation.isCumulative = true
        animation.repeatCount = 10000
        return animation
    }()
    
    override func setupView() {
        self.addSubview(self.coverImageView)
        self.addSubview(self.titleLabel)
        
        self.startAnimation()
    }
    
    override func setupLayout() {
        self.coverImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.coverImageView.snp.right).offset(12)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    func startAnimation() {
        self.coverImageView.layer.add(self.rotationAnimation, forKey: "rotationAnimation")
    }
    
    func stopAnimation() {
        self.coverImageView.layer.removeAllAnimations()
    }
    
    deinit {
        self.stopAnimation()
    }
}
