//
//  SCMineAccountCancellationVC.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/16.
//

import UIKit

class SCMineAccountCancellationVC: SCBasicViewController {
    private let netModel: SCMineResetModel =  SCMineResetModel()
    /// 警告标识
    private lazy var worningIconView: UIImageView = UIImageView(image: "Mine.SCMineAccountCancellationVC.worningIconView.image")
    /// 标题
    private lazy var titleLabel: UILabel = UILabel(text:"确定提交“注销账号”申请吗？", textColor: "Mine.SCMineAccountCancellationVC.titleLabel.textColor", font: "Mine.SCMineAccountCancellationVC.titleLabel.font", alignment: .center)
    private lazy var contentLable: UILabel = {
        let contentLable = UILabel.init()
        contentLable.textAlignment = .center
        contentLable.numberOfLines = 0
        let contentStr = "确认后，账号将注销于:\n\n2021/11/24 00:00:00\n\n鉴于此，我们将删除您账户中的所有个人数据。 注销后，当前账号绑定的所有设备（被分享的设备除外）会解除绑定。请重新注册账号并绑定设备。\n\n感谢您的使用。"
        let attrStr = NSMutableAttributedString.init(string: contentStr)
        attrStr.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)], range: NSRange.init(location: 0, length: contentStr.count))
        
        if contentStr.contains("2021/11/24 00:00:00") {
            let position = contentStr.positionOf(sub: "2021/11/24 00:00:00")
            attrStr.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)], range: NSRange.init(location: position, length: "2021/11/24 00:00:00".count))
        }
        if contentStr.contains("删除您账户中的所有个人数据。") {
            let position = contentStr.positionOf(sub: "删除您账户中的所有个人数据。")
            attrStr.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)], range: NSRange.init(location: position, length: "删除您账户中的所有个人数据。".count))
        }
        if contentStr.contains("会解除绑定。请重新注册账号并绑定设备。") {
            let position = contentStr.positionOf(sub: "会解除绑定。请重新注册账号并绑定设备。")
            attrStr.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)], range: NSRange.init(location: position, length: "会解除绑定。请重新注册账号并绑定设备。".count))
        }
        contentLable.attributedText = attrStr
        return contentLable
    }()
    
    /// 确认按钮
    private lazy var confirmButton: UIButton = {
        let btn = UIButton("确定注销", titleColor: "Mine.SCMineAccountCancellationVC.confirmButton.textColor", font: "Mine.SCMineAccountCancellationVC.confirmButton.font", target: self, action: #selector(confirmButtonAction))
        btn.backgroundColor = UIColor.init(red: 255.0/255.0, green: 87.0/255.0, blue: 75.0/255.0, alpha: 0.3)
        btn.layer.cornerRadius = 18
        btn.layer.masksToBounds = true
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension String {
    //返回第一次出现的指定子字符串在此字符串中的索引
    //（如果backwards参数设置为true，则返回最后出现的位置）
    func positionOf(sub:String, backwards:Bool = false)->Int {
        var pos = -1
        if let range = range(of:sub, options: backwards ? .backwards : .literal ) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
}

extension SCMineAccountCancellationVC {
    override func setupView() {
        self.title = "注销账号"
        self.view.addSubview(self.worningIconView)
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.contentLable)
        self.view.addSubview(self.confirmButton)
        self.titleLabel.textAlignment = .center
    }
    
    override func setupLayout() {
        self.worningIconView.snp.makeConstraints { make in
            make.size.equalTo(CGSize.init(width: 40, height: 40))
            make.centerX.equalToSuperview()
            make.top.equalTo(self.topOffset + 100)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.height.equalTo(27)
            make.top.equalTo(self.worningIconView.snp.bottom).offset(27)
        }
        self.contentLable.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(100)
            make.left.right.equalTo(0)
        }
        self.confirmButton.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(56)
            make.bottom.equalTo(-kSCBottomSafeHeight)
        }
    }

    override func setupData() {
        
    }
}

extension SCMineAccountCancellationVC {
    @objc private func sendCodeButtonAction() {

    }
    @objc private func confirmButtonAction() {
        
        netModel.deleteAccount {
            SCUserCenter.sharedInstance.pushToLogin()
        }
       
    }
}

