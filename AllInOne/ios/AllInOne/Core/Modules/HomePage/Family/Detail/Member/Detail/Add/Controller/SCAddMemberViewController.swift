//
//  SCAddMemberViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/23.
//

import UIKit

class SCAddMemberViewController: SCBasicViewController {

    var familyId: String = ""
    
    private let viewModel = SCAddMemberViewModel()
    
    private lazy var coverImageView: UIImageView = UIImageView(image: "Global.GeneralImage.logoImage")
    
    private lazy var textField: SCTextField = {
        let textField = SCTextField.init {
            
        } textDidChangeHandle: { [weak self] text in
            self?.refreshDoneButton()
        }
        textField.placeholder = tempLocalize("邮箱/手机号/用户ID")
        return textField
    }()

    private lazy var doneButton: UIButton = UIButton(tempLocalize("确定"), titleColor: "HomePage.FamilyListController.AddMemberController.doneButton.textColor", font: "HomePage.FamilyListController.AddMemberController.doneButton.font", target: self, action: #selector(doneButtonAction), disabledTitleColor: "HomePage.FamilyListController.AddMemberController.doneButton.disabledTextColor", backgroundColor: "HomePage.FamilyListController.AddMemberController.doneButton.backgroundColor", cornerRadius: 12)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension SCAddMemberViewController {
    override func setupView() {
        self.title = tempLocalize("共享给")
        
        self.view.addSubview(self.coverImageView)
        self.view.addSubview(self.textField)
        self.view.addSubview(self.doneButton)
        
        self.refreshDoneButton()
    }
    
    override func setupLayout() {
        self.coverImageView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin).offset(40)
        }
        self.textField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.top.equalTo(self.coverImageView.snp.bottom).offset(40)
        }
        self.doneButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-36)
        }
    }
    
    private func refreshDoneButton() {
        if textField.text != nil && textField.text!.count > 0 {
            self.doneButton.isEnabled = true
            self.doneButton.theme_backgroundColor = "HomePage.FamilyListController.AddMemberController.doneButton.backgroundColor"
        }
        else {
            self.doneButton.isEnabled = false
            self.doneButton.theme_backgroundColor = "HomePage.FamilyListController.AddMemberController.doneButton.disabledBackgroundColor"
        }
    }
    
    @objc private func doneButtonAction() {
        guard let text = self.textField.text else { return }
        self.viewModel.addMember(familyId: self.familyId, username: text) { [weak self] in
            let viewControlles = self?.navigationController?.viewControllers ?? []
            for vc in viewControlles {
                if vc is SCMemberListViewController {
                    self?.navigationController?.popToViewController(vc, animated: true)
                    break
                }
            }
        }
    }
}
