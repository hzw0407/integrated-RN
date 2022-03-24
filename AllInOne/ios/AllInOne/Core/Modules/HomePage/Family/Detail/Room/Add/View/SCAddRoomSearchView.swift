//
//  SCAddRoomSearchView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/22.
//

import UIKit

class SCAddRoomSearchView: SCBasicView {

    var text: String? {
        set {
            self.searchBar.text = newValue
        }
        get {
            return self.searchBar.text
        }
    }
    
    private lazy var searchBar: UITextField = {
        let textField = UITextField()
        textField.placeholder = tempLocalize("自定义房间，请输入名称")
        let placeholderColor = ThemeColorPicker(keyPath: "HomePage.FamilyListController.RoomListController.AddRoomController.SearchView.placeholderColor").value() as! UIColor
        let placeholderFont = ThemeFontPicker(stringLiteral: "HomePage.FamilyListController.RoomListController.AddRoomController.SearchView.placeholderFont").value() as! UIFont
        let placeholderAttributes = [NSAttributedString.Key.foregroundColor: placeholderColor, NSAttributedString.Key.font: placeholderFont]
        textField.theme_placeholderAttributes = ThemeStringAttributesPicker.pickerWithAttributes([placeholderAttributes])
        textField.theme_textColor = "HomePage.FamilyListController.RoomListController.AddRoomController.SearchView.textColor"
        textField.theme_font = "HomePage.FamilyListController.RoomListController.AddRoomController.SearchView.font"
//        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        return textField
    }()
    
    private var textDidChangeBlock: ((String) -> Void)?
    private var beginEditingBlock: (() -> Void)?
    
    private lazy var backgorundView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = "HomePage.FamilyListController.RoomListController.AddRoomController.SearchView.backgroundColor"
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var searchClearButton = UIButton(image: "HomePage.AddDeviceController.SearchViewController.SearchView.clearImage", target: self, action: #selector(searchClearButtonAction), imageEdgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    
    convenience init(beginEditingHandle: (() -> Void)?, textDidChangeHandle: ((String) -> Void)? = nil) {
        self.init(frame: .zero)
        self.beginEditingBlock = beginEditingHandle
        self.textDidChangeBlock = textDidChangeHandle
    }

}

extension SCAddRoomSearchView {
    override func setupView() {
        self.searchClearButton.isHidden = true
        self.addSubview(self.backgorundView)
        self.addSubview(self.searchBar)
        self.addSubview(self.searchClearButton)
    }
    
    override func setupLayout() {
        self.backgorundView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
//            make.right.equalToSuperview()
            make.right.equalToSuperview()
        }
        self.searchBar.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(0)
            make.left.equalTo(self).offset(20)
            make.top.bottom.equalToSuperview().inset(5)
            make.right.equalTo(self.searchClearButton.snp.left).offset(-5)
        }
        self.searchClearButton.snp.makeConstraints { make in
            make.right.equalTo(self.backgorundView).offset(0)
            make.height.width.equalTo(36)
            make.centerY.equalToSuperview()
        }
    }
}

extension SCAddRoomSearchView {
    private func showCancelButton() {
        
    }
    
    private func hideCancelButton() {
       
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

extension SCAddRoomSearchView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text ?? "").count == 0 {
            self.hideCancelButton()
        }
        self.searchClearButton.isHidden = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.showCancelButton()
        self.searchClearButton.isHidden = false
        self.beginEditingBlock?()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.textDidChangeBlock?(textField.text ?? "")
    }
}
