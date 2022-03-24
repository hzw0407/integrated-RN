//
//  SCAddDeviceAutoSearchAuthView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/15.
//

import UIKit

class SCAddDeviceAutoSearchAuthView: SCBasicView {
    private var buttonClickedBlock: (() -> Void)?
    
    private lazy var button: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var titleLabel: UILabel = UILabel(textColor: "HomePage.AddDeviceController.AutoSearchView.AuthView.titleLabel.textColor", font: "HomePage.AddDeviceController.AutoSearchView.AuthView.titleLabel.font")
    
    private lazy var typeImageView: UIImageView = UIImageView(image: "HomePage.AddDeviceController.AutoSearchView.AuthView.bluetoothImage")
    
    private lazy var askImageView: UIImageView = UIImageView(image: "HomePage.AddDeviceController.AutoSearchView.AuthView.askImage")
    
    convenience init(title: String, typeImage: ThemeImagePicker, didTapHandle: (() -> Void)?) {
        self.init(frame: .zero)
        
        self.titleLabel.text = title
        self.typeImageView.theme_image = typeImage
        self.buttonClickedBlock = didTapHandle
    }
}

extension SCAddDeviceAutoSearchAuthView {
    override func setupView() {
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.theme_backgroundColor = "HomePage.AddDeviceController.AutoSearchView.AuthView.backgroundColor"
        
        self.addSubview(self.button)
        self.button.addSubview(self.titleLabel)
        self.button.addSubview(self.typeImageView)
        self.button.addSubview(self.askImageView)
    }
    
    override func setupLayout() {
        self.button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.bottom.equalToSuperview()
        }
        self.typeImageView.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel.snp.right).offset(8)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        self.askImageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
    }
    
    @objc private func buttonAction() {
        self.buttonClickedBlock?()
    }
}
