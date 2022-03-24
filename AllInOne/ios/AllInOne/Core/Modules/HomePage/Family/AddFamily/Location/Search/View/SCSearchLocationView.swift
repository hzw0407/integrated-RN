//
//  SCSearchLocationView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/21.
//

import UIKit

class SCSearchLocationView: SCBasicView {
    
    var text: String? {
        didSet {
            self.searchBar.text = self.text
        }
    }

    private var textDidChangeBlock: ((String) -> Void)?
    
    private lazy var searchBar: UITextField = {
        let textField = UITextField()
        textField.placeholder = tempLocalize("搜索位置")
        let placeholderColor = ThemeColorPicker(keyPath: "HomePage.FamilyListController.FamilyLocationController.SearchLocationController.SearchView.placeholderColor").value() as! UIColor
        let placeholderFont = ThemeFontPicker(stringLiteral: "HomePage.FamilyListController.FamilyLocationController.SearchLocationController.SearchView.placeholderFont").value() as! UIFont
        let placeholderAttributes = [NSAttributedString.Key.foregroundColor: placeholderColor, NSAttributedString.Key.font: placeholderFont]
        textField.theme_placeholderAttributes = ThemeStringAttributesPicker.pickerWithAttributes([placeholderAttributes])
        textField.theme_textColor = "HomePage.FamilyListController.FamilyLocationController.SearchLocationController.SearchView.textColor"
        textField.theme_font = "HomePage.FamilyListController.FamilyLocationController.SearchLocationController.SearchView.font"
//        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        return textField
    }()
    
    private lazy var backgorundView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = "HomePage.FamilyListController.FamilyLocationController.SearchLocationController.SearchView.backgroundColor"
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var searchImageView = UIImageView(image: "HomePage.FamilyListController.FamilyLocationController.SearchLocationController.SearchView.searchImage")
    
    private lazy var searchClearButton = UIButton(image: "HomePage.FamilyListController.FamilyLocationController.SearchLocationController.SearchView.clearImage", target: self, action: #selector(searchClearButtonAction), imageEdgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    
    private lazy var cancelButton: UIButton = UIButton(tempLocalize("global_cancel"), titleColor: "HomePage.FamilyListController.FamilyLocationController.SearchLocationController.SearchView.cancelButton.textColor", font: "HomePage.FamilyListController.FamilyLocationController.SearchLocationController.SearchView.cancelButton.font", target: self, action: #selector(cancelButtonAction))
    
    convenience init(textDidChangeHandle: ((String) -> Void)?) {
        self.init(frame: .zero)
        self.textDidChangeBlock = textDidChangeHandle
    }

    override func setupView() {
        self.searchClearButton.isHidden = true
        self.addSubview(self.backgorundView)
        self.addSubview(self.searchBar)
        self.addSubview(self.searchImageView)
        self.addSubview(self.searchClearButton)
//        self.addSubview(self.cancelButton)
        
        self.layer.masksToBounds = true
    }
    
    override func setupLayout() {
        self.backgorundView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalToSuperview()
//            make.right.equalTo(self.cancelButton.snp.left).offset(-10)
        }
        self.searchImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        self.searchBar.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(0)
            make.left.equalTo(self.searchImageView.snp.right).offset(12)
            make.top.bottom.equalToSuperview().inset(5)
            make.right.equalTo(self.searchClearButton.snp.left).offset(-5)
        }
        self.searchClearButton.snp.makeConstraints { make in
            make.right.equalTo(self.backgorundView).offset(0)
            make.height.width.equalTo(36)
            make.centerY.equalToSuperview()
        }
//        self.cancelButton.snp.makeConstraints { make in
//            make.left.equalTo(self.snp.right)
//            make.centerY.equalToSuperview()
//            make.height.equalToSuperview()
//        }
    }

}

extension SCSearchLocationView {
    private func showCancelButton() {
//        UIView.animate(withDuration: 0.3) {
//            self.cancelButton.snp.remakeConstraints { make in
//                make.right.equalTo(self.snp.right).offset(-10)
//                make.centerY.equalToSuperview()
//                make.height.equalToSuperview()
//            }
//            self.layoutIfNeeded()
//        }
    }
    
    private func hideCancelButton() {
//        UIView.animate(withDuration: 0.3) {
//            self.cancelButton.snp.remakeConstraints { make in
//                make.left.equalTo(self.snp.right)
//                make.centerY.equalToSuperview()
//                make.height.equalToSuperview()
//            }
//            self.layoutIfNeeded()
//        }
    }
    
    @objc private func cancelButtonAction() {
        self.searchBar.text = nil
        self.searchBar.resignFirstResponder()
        self.textDidChangeBlock?("")
        self.hideCancelButton()
    }
    
    @objc private func searchClearButtonAction() {
        self.searchBar.text = nil
    }
}

extension SCSearchLocationView: UISearchBarDelegate {
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

extension SCSearchLocationView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text ?? "").count == 0 {
            self.hideCancelButton()
        }
        self.searchClearButton.isHidden = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.showCancelButton()
        self.searchClearButton.isHidden = false
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.textDidChangeBlock?(textField.text ?? "")
    }
}
