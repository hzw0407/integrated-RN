//
//  SCRegisterViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/3.
//

import UIKit

class SCRegisterViewController: SCBasicViewController {

    private let viewModel: SCRegisterViewModel =  SCRegisterViewModel()
    
    private var items: [SCLoginInputModel] = []
    
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCLoginInputCell.self, cellIdendify: SCLoginInputCell.identify, rowHeight: 70, cellDelegate: self)
 
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.clear
        return tableView
    }()
    
    private lazy var remoteLabel: UILabel = UILabel(text: tempLocalize("*仅支持中国大陆手机号，非中国大陆地区请使用邮箱登录"), textColor: "Login.remoteLabel.textColor", font: "Login.remoteLabel.font", backgroundColor: "", numberLines: 0, alignment: .center )
    
    private lazy var registerButton: UIButton = UIButton(tempLocalize("下一步"), titleColor: "Register.registerButton.textColor", font: "Register.registerButton.font", target: self, action: #selector(registerButtonAction), backgroundColor: "Register.registerButton.backgroundColor", cornerRadius: 10)
    
    private lazy var agreeButton: UIButton = UIButton(image: "Login.agreeButton.unSelectAgreeBtn", target: self, action: #selector(agreeButtonClick), highlightedImage: "Login.agreeButton.unSelectAgreeBtn", backgroundColor: "", imageEdgeInsets:UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))

    private lazy var agreeLabel: UILabel = UILabel(text: tempLocalize("同意 用户协议 及 隐私条款"), textColor: "Login.agreeLabel.textColor", font: "Login.agreeLabel.font", backgroundColor: "", numberLines: 0, alignment: .center )
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
      //  self.reloadCountryData()
    }
}

extension SCRegisterViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("register_title")
    }
    
    override func setupView() {
     
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.remoteLabel)
        
        self.agreeButton.theme_setImage("Login.agreeButton.SelectAgreeBtn", forState: .selected)
        
        self.view.addSubview(self.agreeButton)
               //富文本变色
               let strg = "同意 用户协议 及 隐私条款"
               let ranStr = "用户协议"
               let ranStrs = "隐私条款"
               //所有文字变为富文本
               let attrstring:NSMutableAttributedString = NSMutableAttributedString(string:strg)
               //颜色处理的范围
               let str = NSString(string: strg)
               let theRange = str.range(of: ranStr)
               let theRanges = str.range(of: ranStrs)
               //颜色处理
                attrstring.addAttribute(NSAttributedString.Key.foregroundColor, value:RGBColor(r: 96, g: 174, b: 198, a: 1), range: theRange)
                attrstring.addAttribute(NSAttributedString.Key.foregroundColor, value:RGBColor(r: 96, g: 174, b: 198, a: 1), range: theRanges)
               //行间距
               let paragraphStye = NSMutableParagraphStyle()
               paragraphStye.lineSpacing = 5
               //行间距的范围
        let distanceRange = NSMakeRange(0, CFStringGetLength(strg as CFString?))
        attrstring .addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStye, range: distanceRange)
        self.agreeLabel.attributedText = attrstring//赋值方法
        
        self.view.addSubview(self.agreeLabel)
        
        self.view.addSubview(self.registerButton)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin).offset(20)
            make.height.equalTo(70 * 3)
        }
        self.remoteLabel.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(self.tableView.snp.bottom).offset(5)
        }
        
        self.agreeButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(30)
            make.width.equalTo(30)
            make.top.equalTo(self.remoteLabel.snp.bottom).offset(10)
        }
      
        self.agreeLabel.snp.makeConstraints { make in
            make.left.equalTo(self.agreeButton.snp_rightMargin).offset(5)
            make.right.equalTo(self.view.snp_rightMargin).offset(-20)
            make.top.equalTo(self.remoteLabel.snp.bottom).offset(16)
        }
        
        self.registerButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(62)
            make.top.equalTo(self.agreeLabel.snp.bottom).offset(40)
        }
    }
    
    override func setupData() {
        let types: [SCLoginInputType] = [.country, .username,.authCode]
        var items = [SCLoginInputModel]()
        for (i, type) in types.enumerated() {
            let item = SCLoginInputModel()
            item.type = type
            if type == .country {
                item.content = "中国"
            }
        
            item.hasTopLine = i == 0
            items.append(item)
        }
        self.items = items
        
        self.tableView.set(list: [items])
    }
    
    private func reloadCountryData() {
        let item = self.items.first { return $0.type == .country }
        item?.content = SCUserCenter.sharedInstance.country?.name ?? ""
        self.tableView.reloadData()
    }
}

extension SCRegisterViewController {
    @objc private func registerButtonAction() {
        self.view.endEditing(true)
        

        
         let addressModel = self.items[0]
         let userNameModel = self.items[1]
         let passWordmodel = self.items[2]
         
         if addressModel.content == "" {
             SCProgressHUD.showHUD(tempLocalize("请选择地址"))
             return
         }
         
         if userNameModel.content == "" {
             SCProgressHUD.showHUD(tempLocalize("请输入手机号或者邮箱"))
             return
         }
         
         if passWordmodel.content == "" {
             SCProgressHUD.showHUD(tempLocalize("请输入验证码"))
             return
         }
         
         if !self.agreeButton.isSelected {
             SCProgressHUD.showHUD(tempLocalize("请勾选同意用户协议及隐私条款"))
             return
         }
        
        let vc = SCNextRegisterViewController()
        vc.items = self.items
        self.navigationController?.pushViewController(vc, animated: true)
   
    }
    
    @objc private func agreeButtonClick(){
        NSLog("ssssssss")
        self.agreeButton.isSelected = !self.agreeButton.isSelected
    }
    
}

extension SCRegisterViewController: SCLoginInputCellDelegate {
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
