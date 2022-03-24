//
//  SCCountrySearchView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/25.
//

import UIKit

class SCCountrySearchView: UIView {
    private var textDidChangeBlock: ((String) -> Void)?
    
    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = tempLocalize("login_country_search_placeholder")
        bar.delegate = self
        bar.searchBarStyle = .minimal
        return bar
    }()
    
    private lazy var cancelButton: UIButton = UIButton(tempLocalize("global_cancel"), titleColor: "CountryList.SearchBar.textColor", font: "CountryList.SearchBar.font", target: self, action: #selector(cancelButtonAction))
    
    convenience init(textDidChangeHandle: ((String) -> Void)?) {
        self.init(frame: .zero)
        self.textDidChangeBlock = textDidChangeHandle
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.searchBar)
        self.addSubview(self.cancelButton)
        
        self.searchBar.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0)
            make.top.bottom.equalToSuperview().inset(5)
            make.right.equalTo(self.cancelButton.snp.left).offset(0)
        }
        self.cancelButton.snp.makeConstraints { make in
            make.left.equalTo(self.snp.right)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SCCountrySearchView {
    private func showCancelButton() {
        UIView.animate(withDuration: 0.3) {
            self.cancelButton.snp.remakeConstraints { make in
                make.right.equalTo(self.snp.right).offset(-10)
                make.centerY.equalToSuperview()
                make.height.equalToSuperview()
            }
            self.layoutIfNeeded()
        }
    }
    
    private func hideCancelButton() {
        UIView.animate(withDuration: 0.3) {
            self.cancelButton.snp.remakeConstraints { make in
                make.left.equalTo(self.snp.right)
                make.centerY.equalToSuperview()
                make.height.equalToSuperview()
            }
            self.layoutIfNeeded()
        }
    }
    
    @objc private func cancelButtonAction() {
        self.searchBar.text = nil
        self.searchBar.resignFirstResponder()
        self.textDidChangeBlock?("")
        self.hideCancelButton()
    }
}

extension SCCountrySearchView: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        self.hideCancelButton()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.showCancelButton()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.textDidChangeBlock?(searchText)
    }
}
