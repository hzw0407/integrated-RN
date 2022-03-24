//
//  SCBasicCollectionReusableView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/14.
//

import UIKit

class SCBasicCollectionReusableView: UICollectionReusableView {
    var model: Any?
    
    static var identify: String {
        let name = NSStringFromClass(self)
        return name
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.tintColor = .clear
        self.setupView()
        self.setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SCBasicCollectionReusableView {
    @objc func setupView() { }
    @objc func setupLayout() { }
}

extension UICollectionReusableView {
    @objc func set(model: Any?) { }
}
