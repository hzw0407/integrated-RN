//
//  SCMineAboutController.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/24.
//

import UIKit

class SCMineAboutController: SCBasicViewController {
    /// 标题
    private lazy var logoLb: UILabel = {
        let logoLb = UILabel(textColor: "Mine.SCMineAboutController.logoLb.textColor", font: "Mine.SCMineAboutController.logoLb.font", alignment: .center)
        logoLb.text = "ALL IN ONE"
        return logoLb
    }()
    /// 版本
    private lazy var versionLb: UILabel = {
        let versionLb = UILabel(textColor: "Mine.SCMineAboutController.versionLb.textColor", font: "Mine.SCMineAboutController.versionLb.font", alignment: .center)
        let infoDictionary = Bundle.main.infoDictionary
        let app_Version = infoDictionary?["CFBundleShortVersionString"]
        versionLb.text = "App版本：V" + (app_Version as! String)
        return versionLb
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SCMineAboutController {
    override func setupView() {
        self.title = "关于我们"
        self.view.addSubview(self.logoLb)
        self.view.addSubview(self.versionLb)
    }
    
    override func setupLayout() {
        self.logoLb.snp.makeConstraints { make in
            make.top.equalTo(kSCNavAndStatusBarHeight + 77)
            make.left.right.equalTo(0)
            make.height.equalTo(36)
        }
        self.versionLb.snp.makeConstraints { make in
            make.top.equalTo(self.logoLb.snp.bottom).offset(57)
            make.left.right.equalTo(0)
            make.height.equalTo(20)
        }
    }

    override func setupData() {
        
    }
}
