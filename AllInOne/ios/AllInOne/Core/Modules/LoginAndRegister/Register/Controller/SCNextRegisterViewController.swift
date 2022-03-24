//
//  SCNextRegisterViewController.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/16.
//


import UIKit

class SCNextRegisterViewController: SCBasicViewController {

    private let viewModel: SCRegisterViewModel =  SCRegisterViewModel()
    
     var items: [SCLoginInputModel] = []
    
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCLoginInputCell.self, cellIdendify: SCLoginInputCell.identify, rowHeight: 70, cellDelegate: self)
 
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.clear
        return tableView
    }()
    
  
    private lazy var registerButton: UIButton = UIButton(tempLocalize("注册"), titleColor: "Register.registerButton.textColor", font: "Register.registerButton.font", target: self, action: #selector(registerButtonAction), backgroundColor: "Register.registerButton.backgroundColor", cornerRadius: 10)
    
    private lazy var agreeButton: UIButton = UIButton(image: "Login.agreeButton.unSelectAgreeBtn", target: self, action: #selector(agreeButtonClick), highlightedImage: "Login.agreeButton.unSelectAgreeBtn", backgroundColor: "", imageEdgeInsets:UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))

  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension SCNextRegisterViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("register_title")
    }
    
    override func setupView() {
     
        self.view.addSubview(self.tableView)
    

        self.view.addSubview(self.registerButton)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin).offset(20)
            make.height.equalTo(70 * 2)
        }
     
        
  
      
     
        
        self.registerButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(62)
            make.top.equalTo(self.tableView.snp.bottom).offset(40)
        }
    }
    
    override func setupData() {
        let types: [SCLoginInputType] = [.password, .password]
        var items = [SCLoginInputModel]()
        var myItems = self.items
        for (i, type) in types.enumerated() {
            let item = SCLoginInputModel()
            item.type = type
            item.hasTopLine = i == 0
            items.append(item)
            myItems .append(item)
        }
        self.items = myItems
        
        self.tableView.set(list: [items])
    }
}

extension SCNextRegisterViewController {
    @objc private func registerButtonAction() {
        self.view.endEditing(true)
        
        
         let passWordmodel = self.items[3]
         let comfPassWordmodel = self.items[4]
      
         
//         if addressModel.content == "" {
//             SCProgressHUD.showHUD(tempLocalize("请选择地址"))
//             return
//         }
         
         if passWordmodel.content == "" {
             SCProgressHUD.showHUD(tempLocalize("请输入密码"))
             return
         }
         
         if comfPassWordmodel.content == "" {
             SCProgressHUD.showHUD(tempLocalize("请输入确认密码"))
             return
         }
         
      
        
        self.viewModel.items = self.items
        self.viewModel.register {
            
        //跳转到登录页
            self.navigationController?.popToRootViewController(animated: true)
                   guard let delegate = UIApplication.shared.delegate as? AppDelegate,let tabBarController = delegate.window?.rootViewController as? UITabBarController, let viewControllers = tabBarController.viewControllers  else {
                       return
                   }
                   
                   for item in viewControllers {
                       guard let navController = item as? UINavigationController, let rootViewController = navController.viewControllers.first else { continue }
                       if rootViewController is SCLoginViewController {
                           tabBarController.selectedViewController = navController
                           break
                       }
                   }
            
        }
    }
    
    @objc private func agreeButtonClick(){
        NSLog("ssssssss")
        self.agreeButton.isSelected = !self.agreeButton.isSelected
    }
    
}

extension SCNextRegisterViewController: SCLoginInputCellDelegate {
    func cell(_ cell: SCLoginInputCell, didTapedSelectButton model: SCLoginInputModel) {
        self.view.endEditing(true)
        let vc = SCCountryListViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func cell(_ cell: SCLoginInputCell, didTapedGetCodeButton model: SCLoginInputModel) {
        self.view.endEditing(true)
        
        let userNameModel = self.items[1]
        if userNameModel.content == "" {
            SCProgressHUD.showHUD(tempLocalize("请输入手机号或者邮箱"))
            return
        }
        self.viewModel.items = self.items
        self.viewModel.getAuthCode {
            
            var countDownNum = 60
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if countDownNum < 0 {
                  
                    timer.invalidate()
                } else {
                   
                    model.countDown = countDownNum
                    cell.model = model
                    cell.reloadCountDown()
                    countDownNum -= 1
                    
             
                }
            }
            
            
        
        }
    }
}

