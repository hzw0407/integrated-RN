//
//  SCBindDeviceFailReasonViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/16.
//

import UIKit

class SCBindDeviceFailReasonViewController: SCBasicViewController {

    var product: SCNetResponseProductModel?
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension SCBindDeviceFailReasonViewController {
    override func setupView() {
        self.title = tempLocalize("连接失败")
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.messageLabel)
    }
    
    override func setupLayout() {
        self.scrollView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
        }
        self.messageLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(24)
            make.width.equalTo(kSCScreenWidth - 24 * 2)
            make.top.equalToSuperview().offset(40)
        }
    }
    
    override func setupData() {
        let titles = [tempLocalize("可能失败的原因")]
        let contents = [[tempLocalize("1.当前Wi-Fi密码输入正确"), tempLocalize("2.路由器正常连接外网，且网络连接情况良好"), tempLocalize("3.路由器正常连接外网，且网络连接情况良好")]]
        
        var titleRanges: [NSRange] = []
        var totalText = ""
        for (i, title) in titles.enumerated() {
            let titleRange = NSRange(location: totalText.count, length: title.count)
            titleRanges.append(titleRange)
            
            let content = contents[i].joined(separator: "\n")
            totalText += title + "\n" + content + "\n\n"
        }
        
        let titleColor = ThemeColorPicker(keyPath: "HomePage.AddDeviceController.BindDeviceController.BindDeviceFailReasonController.titleColor").value() as! UIColor
        let titleFont = ThemeFontPicker(stringLiteral: "HomePage.AddDeviceController.BindDeviceController.BindDeviceFailReasonController.titleFont").value() as! UIFont
        let contentColor = ThemeColorPicker(keyPath: "HomePage.AddDeviceController.BindDeviceController.BindDeviceFailReasonController.contentColor").value() as! UIColor
        let contentFont = ThemeFontPicker(stringLiteral: "HomePage.AddDeviceController.BindDeviceController.BindDeviceFailReasonController.contentFont").value() as! UIFont
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 12
        let attributedText = NSMutableAttributedString(string: totalText, attributes: [NSAttributedString.Key.font : contentFont, NSAttributedString.Key.foregroundColor: contentColor, NSAttributedString.Key.paragraphStyle: paragraphStyle])
        
        for range in titleRanges {
            attributedText.addAttributes([NSAttributedString.Key.font : titleFont, NSAttributedString.Key.foregroundColor: titleColor], range: range)
        }
        
        self.messageLabel.attributedText = attributedText
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            guard let `self` = self else { return }
            self.scrollView.contentSize = CGSize(width: kSCScreenWidth, height: self.messageLabel.bounds.height + 40 * 2)
        }
    }
}
