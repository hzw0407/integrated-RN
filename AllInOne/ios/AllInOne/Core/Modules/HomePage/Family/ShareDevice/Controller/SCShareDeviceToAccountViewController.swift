//
//  SCShareDeviceToAccountViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/25.
//

import UIKit

class SCShareDeviceToAccountViewController: SCBasicViewController {

    var deviceIds: [String] = []
    
    private let viewModel = SCShareDeviceToAccountViewModel()
    
    private lazy var textField = SCTextField { // 开始编辑
        
    } textDidChangeHandle: { [weak self] text in
        self?.refreshDoneButton()
    }
    
    private lazy var doneButton: UIButton = UIButton(tempLocalize("确定"), titleColor: "HomePage.ShareDeviceToAccountController.doneButton.textColor", font: "HomePage.ShareDeviceToAccountController.doneButton.font", target: self, action: #selector(doneButtonAction), disabledTitleColor: "HomePage.ShareDeviceToAccountController.doneButton.disabledTextColor", backgroundColor: "HomePage.ShareDeviceToAccountController.doneButton.backgroundColor", cornerRadius: 12)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension SCShareDeviceToAccountViewController {
    override func setupView() {
        self.title = tempLocalize("共享给艾加账号")
        self.view.addSubview(self.textField)
        self.view.addSubview(self.doneButton)
    }
    
    override func setupLayout() {
        self.textField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(self.view.snp.topMargin).offset(24)
            make.height.equalTo(56)
        }
        self.doneButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-36)
        }
    }
    
    override func setupData() {
        self.refreshDoneButton()
    }
    
    private func refreshDoneButton() {
        if let text = self.textField.text, text.count > 0 {
            self.doneButton.isSelected = true
            self.doneButton.theme_backgroundColor = "HomePage.ShareDeviceToAccountController.doneButton.backgroundColor"
        }
        else {
            self.doneButton.isSelected = false
            self.doneButton.theme_backgroundColor = "HomePage.ShareDeviceToAccountController.doneButton.disabledBackgroundColor"
        }
    }
}

extension SCShareDeviceToAccountViewController {
    @objc private func doneButtonAction() {
        guard let username = self.textField.text else { return }
        self.viewModel.shareDevices(deviceIds: self.deviceIds, toUsername: username) { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
}
