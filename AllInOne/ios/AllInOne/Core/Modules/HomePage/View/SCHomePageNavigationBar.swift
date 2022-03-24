//
//  SCHomePageNavigationBar.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/18.
//

import UIKit

class SCHomePageNavigationBar: SCBasicView {

    var selectCount: Int = 0 {
        didSet {
            if self.selectCount == 0 {
                self.titleLabel.text = tempLocalize("请选择设备")
            }
            else {
                self.titleLabel.text = tempLocalize("已选中\(self.selectCount)个设备")
            }
        }
    }
    
    private lazy var saveButton: UIButton = UIButton(image: "HomePage.HomePageController.EditingNavigationBar.saveImage", target: self, action: #selector(saveButtonAction))
    private lazy var titleLabel: UILabel = UILabel(textColor: "HomePage.HomePageController.EditingNavigationBar.titleLabel.textColor", font: "HomePage.HomePageController.EditingNavigationBar.titleLabel.font", numberLines: 2, alignment: .center)
    private lazy var selectAllButton: UIButton = UIButton(image: "HomePage.HomePageController.EditingNavigationBar.selectAllImage", target: self, action: #selector(selectAllButtonAction))

    private var saveBlock: (() -> Void)?
    private var selectAllBlock: (() -> Void)?
    
    convenience init(saveHandle: (() -> Void)?, selectAllHandle: (() -> Void)?) {
        self.init(frame: .zero)
        self.saveBlock = saveHandle
        self.selectAllBlock = selectAllHandle
    }
}

extension SCHomePageNavigationBar {
    override func setupView() {
        self.addSubview(self.saveButton)
        self.addSubview(self.selectAllButton)
        self.addSubview(self.titleLabel)
        
        self.theme_backgroundColor = "HomePage.HomePageController.EditingNavigationBar.backgroundColor"
        
        let fromColor: UIColor = ThemeColorPicker(keyPath: "Global.ViewController.backgroundColor.fromColor").value() as! UIColor
        let toColor: UIColor = ThemeColorPicker(keyPath: "Global.ViewController.backgroundColor.toColor").value() as! UIColor
        
        if let fromComponents = fromColor.cgColor.components, let toComponents = toColor.cgColor.components, fromComponents.count >= 3, toComponents.count >= 3 {
            let height = kSCStatusBarHeight + 72
            let r = (height) * (toComponents[0] - fromComponents[0]) / kSCScreenHeight + fromComponents[0]
            let g = (height) * (toComponents[1] - fromComponents[1]) / kSCScreenHeight + fromComponents[1]
            let b = (height) * (toComponents[2] - fromComponents[2]) / kSCScreenHeight + fromComponents[2]
            let bgColor = UIColor(red: r, green: g, blue: b, alpha: 1)
            self.backgroundColor = bgColor
        }
    }
    
    override func setupLayout() {
        self.saveButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-16)
        }
        self.selectAllButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.width.height.bottom.equalTo(self.saveButton)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.saveButton)
            make.left.equalTo(self.saveButton.snp.right).offset(5)
            make.right.equalTo(self.selectAllButton.snp.left).offset(-5)
        }
    }
}

extension SCHomePageNavigationBar {
    @objc private func saveButtonAction() {
        self.saveBlock?()
    }
    
    @objc private func selectAllButtonAction() {
        self.selectAllBlock?()
    }
}
