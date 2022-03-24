//
//  SCScanNoneViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/15.
//

import UIKit
import SwiftTheme

class SCScanNoneViewController: SCBasicViewController {

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
}

extension SCScanNoneViewController {
    override func setupView() {
        self.title = tempLocalize("扫描不到设备")
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
        let titles = [tempLocalize("1.请确保设备处于工作状态。"), tempLocalize("2.解绑设备，重新连接。"), tempLocalize("3.部分产品暂不支持蓝牙。"), tempLocalize("4.手机蓝牙未开启")]
        let contents = [tempLocalize("你可以尝试更换电池、为设备充电、插上电源等方式。部分设备需要处于配网状态才可以搜索到蓝牙信号，请查看产品说明书并按照指示操作。"), tempLocalize("某些设备与手机有强绑定关系，可能需要接触之前的绑定之后才能重新连接，你可以参考产品附带的说明书。"), tempLocalize("部分产品暂不支持蓝牙连接，可以选择手动添加设备。"), tempLocalize("部分产品暂不支持蓝牙连接，可以选择手动添加设备。")]
        
        var titleRanges: [NSRange] = []
        var totalText = ""
        for (i, title) in titles.enumerated() {
            let content = contents[i]
            let titleRange = NSRange(location: totalText.count, length: title.count)
            titleRanges.append(titleRange)
            
            totalText += title + "\n" + content + "\n\n"
        }
        
        let titleColor = ThemeColorPicker(keyPath: "HomePage.AddDeviceController.ScanNoneController.titleColor").value() as! UIColor
        let titleFont = ThemeFontPicker(stringLiteral: "HomePage.AddDeviceController.ScanNoneController.titleFont").value() as! UIFont
        let contentColor = ThemeColorPicker(keyPath: "HomePage.AddDeviceController.ScanNoneController.contentColor").value() as! UIColor
        let contentFont = ThemeFontPicker(stringLiteral: "HomePage.AddDeviceController.ScanNoneController.contentFont").value() as! UIFont
        
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
