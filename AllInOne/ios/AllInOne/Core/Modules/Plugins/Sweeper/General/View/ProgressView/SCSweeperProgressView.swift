//
//  SCSweeperProgressView.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/2/16.
//

import UIKit
import SwiftTheme

class SCSweeperProgressView: UIView {

    var progress: CGFloat = 0 {
        didSet {
            self.progressView.snp.remakeConstraints { make in
                make.left.top.bottom.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(self.progress)
            }
        }
    }
    
    private lazy var trackView: UIView = UIView()
    
    private lazy var progressView: UIView = UIView()
    
    convenience init(progressFromColor: ThemeColorPicker, progressToColor: ThemeColorPicker, trackColor: ThemeColorPicker, size: CGSize, cornerRadius: CGFloat) {
        self.init(frame: .zero)
        
        self.progressView = UIView(gradientDirection: .leftToRight, backgroundFromColor: progressFromColor, backgroundToColor: progressToColor, size: size, cornerRadius: cornerRadius)
        self.trackView = UIView(backgroundColor: trackColor, cornerRadius: cornerRadius)
        
        self.addSubview(self.trackView)
        self.addSubview(self.progressView)
        
        self.trackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.progressView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
//        self.progress = 0.5
    }
}
