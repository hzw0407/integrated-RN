//
//  SCBasicTableViewHeaderFooterView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/25.
//

import UIKit

class SCBasicTableViewHeaderFooterView: UITableViewHeaderFooterView {

    var model: Any?
    
    static var identify: String {
        let name = NSStringFromClass(self)
        return name
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.tintColor = .clear
        self.setupView()
        self.setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SCBasicTableViewHeaderFooterView {
    @objc func setupView() { }
    @objc func setupLayout() { }
}

extension UITableViewHeaderFooterView {
    @objc func set(model: Any?) { }
}
