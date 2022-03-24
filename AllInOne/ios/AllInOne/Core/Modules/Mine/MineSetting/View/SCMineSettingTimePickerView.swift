//
//  SCMineSettingTimePickerView.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/23.
//

import UIKit

class SCMineSettingTimePickerView: UIView {
    
    public var timeDidSelectRow: ((String, String) -> Void)?
    var currentHour = "0"
    var currentMinu = "0"
    var time: (String, String) = ("0", "0")
    let hours: [String] = {
        var hours = [String]()
        for index in 0...24 {
            hours.append(String(index))
        }
        return hours
    }()
    let minus: [String] = {
        var minus = [String]()
        for index in 0...59 {
            minus.append(String(index))
        }
        return minus
    }()
    var hoursPicker: PickerView = {
        let hoursPicker = PickerView.init()
        hoursPicker.backgroundColor = UIColor.clear
        hoursPicker.scrollingStyle = .default
        hoursPicker.selectionStyle = .none
        hoursPicker.currentSelectedRow = 0
        return hoursPicker
    }()
    var minusPicker: PickerView = {
        let minusPicker = PickerView.init()
        minusPicker.backgroundColor = UIColor.clear
        minusPicker.scrollingStyle = .default
        minusPicker.selectionStyle = .none
        minusPicker.currentSelectedRow = 0
        return minusPicker
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    func initUI() {
        self.addSubview(self.hoursPicker)
        self.addSubview(self.minusPicker)
        self.hoursPicker.snp.makeConstraints { make in
            make.top.left.bottom.equalTo(0)
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        self.minusPicker.snp.makeConstraints { make in
            make.top.right.bottom.equalTo(0)
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        hoursPicker.dataSource = self
        hoursPicker.delegate = self
        minusPicker.dataSource = self
        minusPicker.delegate = self
        // 横线
        let topLineView = UIImageView.init()
        topLineView.theme_image = "Mine.SCMineSettingVC.SCMineSettingTimePickerView.lineImage"
        self.addSubview(topLineView)
        topLineView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.height.equalTo(1)
            make.bottom.equalTo(self.snp.centerY).offset(-22)
        }
        let bottomLineView = UIImageView.init()
        bottomLineView.theme_image = "Mine.SCMineSettingVC.SCMineSettingTimePickerView.lineImage"
        self.addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.height.equalTo(1)
            make.top.equalTo(self.snp.centerY).offset(22)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SCMineSettingTimePickerView: PickerViewDataSource {
    // MARK: - PickerViewDataSource
    func pickerViewNumberOfRows(_ pickerView: PickerView) -> Int {
        if pickerView == self.hoursPicker {
            return self.hours.count
        } else {
            return self.minus.count
        }
    }
    func pickerView(_ pickerView: PickerView, titleForRow row: Int) -> String {
        if pickerView == self.hoursPicker {
            return self.hours[row]
        } else {
            return self.minus[row]
        }
    }
}

extension SCMineSettingTimePickerView: PickerViewDelegate {
    
    // MARK: - PickerViewDelegate
    
    func pickerViewHeightForRows(_ pickerView: PickerView) -> CGFloat {
        return 44.0
    }

    func pickerView(_ pickerView: PickerView, didSelectRow row: Int) {
        if pickerView == self.hoursPicker {
            self.currentHour = self.hours[row]
            self.time.0 = self.currentHour
        } else {
            self.currentMinu = self.minus[row]
            self.time.1 = self.currentMinu
        }
        self.timeDidSelectRow?(self.time.0, self.time.1)
    }
    
    func pickerView(_ pickerView: PickerView, styleForLabel label: UILabel, highlighted: Bool) {
        label.textAlignment = .center
        if highlighted == true {
            label.theme_textColor = "Mine.SCMineSettingVC.SCMineSettingTimePickerView.titleLabel.selectedTextColor"
            label.theme_font = "Mine.SCMineSettingVC.SCMineSettingTimePickerView.titleLabel.selectedFont"
        } else {
            label.theme_textColor = "Mine.SCMineSettingVC.SCMineSettingTimePickerView.titleLabel.normalTextColor"
            label.theme_font = "Mine.SCMineSettingVC.SCMineSettingTimePickerView.titleLabel.normalFont"
        }
    }
    
    func pickerView(_ pickerView: PickerView, viewForRow row: Int, highlighted: Bool, reusingView view: UIView?) -> UIView? {
        return nil
    }
    
}
