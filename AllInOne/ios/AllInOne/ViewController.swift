//
//  ViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/10/19.
//

import UIKit

class ViewController: UIViewController {
    lazy var button: UIButton = {
        let button = UIButton.init(frame: CGRect(x: 100, y: 300, width: 200, height: 100))
        button.setTitle("跳转RN界面", for: .normal)
        button.setTitleColor(UIColor.orange, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.backgroundColor = UIColor.blue
        button.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        return button
    }()
    
    @objc func btnClick() {
        print("点击了按钮")
//        let bridge = ReactNativeManager.deaultManager().bridge!
//        let rootView = RCTRootView.init(bridge: bridge, moduleName: "RNView", initialProperties:nil)
        // 下面这种方法也可以跳转至RN界面
        let url = URL.init(string: "http://192.168.31.161:8081/index.bundle?platform=ios")
        let rootView = RCTRootView.init(bundleURL: url!, moduleName: "RNView", initialProperties: nil, launchOptions: nil)
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(self.button)
        
        NotificationCenter.default.addObserver(self, selector: #selector(navagateBack), name: Notification.Name(rawValue: "ModuleNavigateBack"), object: nil)
    }
    
    @objc func navagateBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

