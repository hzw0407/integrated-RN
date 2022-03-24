//
//  SCFamilyLocationSearchButton.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/21.
//

import UIKit

class SCFamilyLocationSearchButton: SCBasicView {
    
    var text: String? {
        didSet {
            self.textLabel.text = self.text
        }
    }
    
    private var didTapBlock: (() -> Void)?

    private lazy var button: UIButton = UIButton(nil, titleColor: nil, font: nil, target: self, action: #selector(buttonAction), backgroundColor: "HomePage.FamilyListController.FamilyLocationController.SearchButton.backgroundColor", cornerRadius: 12)
    
    private lazy var searchImageView: UIImageView = UIImageView(image: "HomePage.FamilyListController.FamilyLocationController.SearchButton.image")
    
    private lazy var textLabel: UILabel = UILabel(textColor: "HomePage.FamilyListController.FamilyLocationController.SearchButton.textColor", font: "HomePage.FamilyListController.FamilyLocationController.SearchButton.font")

    convenience init(didTapHandle: (() -> Void)?) {
        self.init()
        self.didTapBlock = didTapHandle
    }
}

extension SCFamilyLocationSearchButton {
    override func setupView() {
        self.addSubview(self.button)
        self.button.addSubview(self.searchImageView)
        self.button.addSubview(self.textLabel)
    }
    
    override func setupLayout() {
        self.button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.searchImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.height.width.equalTo(20)
            make.centerY.equalToSuperview()
        }
        self.textLabel.snp.makeConstraints { make in
            make.left.equalTo(self.searchImageView.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
    }
    
    @objc private func buttonAction() {
        self.didTapBlock?()
    }
}
