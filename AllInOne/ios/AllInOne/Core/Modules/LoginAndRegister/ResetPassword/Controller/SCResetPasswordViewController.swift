//
//  SCResetPasswordViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/7.
//

import UIKit

class SCResetPasswordViewController: SCBasicViewController {

    private let viewModel: SCResetPasswordViewModel =  SCResetPasswordViewModel()
    
    private var items: [SCLoginInputModel] = []
    
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCLoginInputCell.self, cellIdendify: SCLoginInputCell.identify, rowHeight: 50, cellDelegate: self)
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var resetButton: UIButton = UIButton(tempLocalize("重置密码"), titleColor: "Register.registerButton.textColor", font: "Register.registerButton.font", target: self, action: #selector(resetButtonAction), backgroundColor: "Register.registerButton.backgroundColor", cornerRadius: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension SCResetPasswordViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("重置密码")
    }
    
    override func setupView() {
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.resetButton)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin).offset(20)
            make.height.equalTo(50 * 5)
        }
        self.resetButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(40)
            make.top.equalTo(self.tableView.snp.bottom).offset(40)
        }
    }
    
    override func setupData() {
        let types: [SCLoginInputType] = [.username, .password, .confirmPassword, .authCode]
        var items = [SCLoginInputModel]()
        for (i, type) in types.enumerated() {
            let item = SCLoginInputModel()
            item.type = type
            item.hasTopLine = i == 0
            items.append(item)
        }
        self.items = items
        
        self.tableView.set(list: [items])
    }
}

extension SCResetPasswordViewController {
    @objc private func resetButtonAction() {
        self.view.endEditing(true)
        self.viewModel.items = self.items
        self.viewModel.resetPassword {
            
        }
    }
}

extension SCResetPasswordViewController: SCLoginInputCellDelegate {
    func cell(_ cell: SCLoginInputCell, didTapedGetCodeButton model: SCLoginInputModel) {
        self.view.endEditing(true)
        self.viewModel.items = self.items
        self.viewModel.getAuthCode {
            
        }
    }
}
