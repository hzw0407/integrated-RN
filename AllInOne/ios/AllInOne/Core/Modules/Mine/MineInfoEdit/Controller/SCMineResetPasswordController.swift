//
//  SCMineResetPasswordController.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/15.
//

import UIKit

enum SCMineChangePasswordType: Int {
    case modifyPwd
    case resetPwd
}

class SCMineResetPasswordController: SCBasicViewController {
    
    public var type: SCMineChangePasswordType = .modifyPwd
    private let viewModel = SCMineViewModel()
    private let netModel: SCMineResetModel =  SCMineResetModel()
    /// 列表
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCMineTextFieldCell.self, cellIdendify: SCMineIconAndArrowCell.identify, rowHeight: 56, cellDelegate: self, style: .grouped)
        tableView.backgroundColor = UIColor.clear
        tableView.register(header: UITableViewHeaderFooterView.self, idendify: "SCMineSectionHeader", height: 12)
        tableView.register(footer: UITableViewHeaderFooterView.self, idendify: "SCMineSectionFooter", height: 0.1)
        return tableView
    }()
    /// 保存按钮
    private lazy var saveBtn: UIButton = {
        let saveBtn = UIButton.init(type: .custom)
        saveBtn.theme_setImage("Mine.SCMineResetPasswordController.saveBtn.image", forState: .normal)
        saveBtn.theme_setImage("Mine.SCMineResetPasswordController.saveBtn.disabledImage", forState: .disabled)
        saveBtn.addTarget(self, action: #selector(saveBtnAction), for: .touchUpInside)
        return saveBtn
    }()
    /// 数据
    var dataArray: NSArray = NSArray()
    
    //旧密码修改
    var oldPwd = ""
    var newPwd1 = ""
    var newPwd2 = ""

    //手机或者邮箱验证码修改
    var username = ""
    var authcode = ""
    var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func saveBtnStatus() {
        if self.type == .modifyPwd {
            self.saveBtn.isEnabled = (self.oldPwd.count > 0 && self.newPwd1 == self.newPwd2 && self.newPwd1.count > 0)
        } else if self.type == .resetPwd {
            self.saveBtn.isEnabled = (self.newPwd1 == self.newPwd2 && self.newPwd1.count > 0)
        }
    }
}

extension SCMineResetPasswordController {
    override func setupNavigationBar() {
        self.title = "修改密码"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.saveBtn)
        self.saveBtn.isEnabled = false
    }
    
    override func setupView() {
        self.view.addSubview(self.tableView)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.topOffset)
            make.left.right.bottom.equalTo(0)
        }
    }

    override func setupData() {
        if self.type == .modifyPwd {
            self.dataArray = self.viewModel.initModifyPasswordData()
        } else if self.type == .resetPwd {
            self.dataArray = self.viewModel.initResetPasswordData()
        }
        self.tableView.set(list: self.dataArray as! [[Any]])
    }
}

extension SCMineResetPasswordController {
    @objc private func saveBtnAction() {
   
        if self.type == .modifyPwd {
            self.netModel.oldPwd = self.oldPwd
            self.netModel.newPwd1 = self.newPwd1
            self.netModel.changePasswordRequest(success: {
                self.navigationController?.popViewController(animated: true)
            })
        }
        
        //邮箱或者手机号验证码修改
        if self.type == .resetPwd {
            self.netModel.username = self.username
            self.netModel.authCode = self.authcode
            self.netModel.password = self.newPwd1
            self.netModel.resetPassword(success: {
                
//                let vc = SCMineInfoEditController()
//                self.jmmpToVC(vc: vc)
//
                let viewControllers = self.navigationController?.viewControllers ?? []
                if let vc = viewControllers.first(where: { return $0 is SCMineInfoEditController }) {
                    self.navigationController?.popToViewController(vc, animated: true)
                }
                else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            })
        }
        
        
    
        
        
        
    }
}

extension SCMineResetPasswordController: SCMineTextFieldCellDelegate {
    func cell(_ cell: SCMineTextFieldCell, textFieldEditDidChange model: SCMineTextFieldModel, textField: UITextField) {
        switch model.placeTitle {
        case "请输入原密码":
            self.oldPwd = textField.text ?? ""
        case "请输入新密码":
            self.newPwd1 = textField.text ?? ""
        case "请再次输入新密码":
            self.newPwd2 = textField.text ?? ""
        default:
            break
        }
        self.saveBtnStatus()
    }
}
