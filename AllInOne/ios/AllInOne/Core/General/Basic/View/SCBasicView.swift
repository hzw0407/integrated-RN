//
//  SCBasicView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/26.
//

import UIKit

class SCBasicView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
        self.setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SCBasicView {
    @objc func setupView() { }
    @objc func setupLayout() { }
    
    @objc func set(model: Any?) { }
}
