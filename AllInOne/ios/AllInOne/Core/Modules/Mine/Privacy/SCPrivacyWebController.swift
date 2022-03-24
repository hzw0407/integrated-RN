//
//  SCPrivacyWebController.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/27.
//

import UIKit
import WebKit

class SCPrivacyWebController: SCBasicViewController {
    
    private var webView: WKWebView = {
        let webView = WKWebView.init()
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "隐私协议"
        self.view.addSubview(self.webView)
        self.webView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(kSCNavAndStatusBarHeight)
        }
        self.loadWebView()
    }
    
    func loadWebView() {
        guard let url = URL.init(string: "https://www.baidu.com/") else { return }
        let request = URLRequest.init(url: url)
        webView.load(request)
    }

}
