//
//  SCBasicTableViewCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/24.
//

import UIKit

class SCBasicTableViewCell: UITableViewCell {
    
    var model: Any?
    
    static var identify: String {
        let name = NSStringFromClass(self)
        return name
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.setupView()
        self.setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}

extension SCBasicTableViewCell {
    @objc func setupView() { }
    @objc func setupLayout() { }
}

extension UITableViewCell {
    @objc func set(model: Any?) { }
    @objc func set(delegate: Any?) { }
}
