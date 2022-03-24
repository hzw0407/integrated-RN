//
//  SCFeedbackRecordDeleteButton.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/1/7.
//

import UIKit

class SCFeedbackRecordDeleteButton: SCBasicView {

    var isEnabled: Bool = false {
        didSet {
            if self.isEnabled {
                self.titleLabel.theme_textColor = "Mine.Feedback.FeedbackRecordController.deleteButton.textColor"
                self.theme_backgroundColor = "Mine.Feedback.FeedbackRecordController.deleteButton.backgroundColor"
            }
            else {
                self.titleLabel.theme_textColor = "Mine.Feedback.FeedbackRecordController.deleteButton.disabledTextColor"
                self.theme_backgroundColor = "Mine.Feedback.FeedbackRecordController.deleteButton.disabledBackgroundColor"
            }
            self.button.isEnabled = self.isEnabled
        }
    }
    
    private lazy var button = UIButton()
    
    private lazy var contentView = UIView()
    
    private lazy var coverImageView = UIImageView(image: "Mine.Feedback.FeedbackRecordController.deleteButton.image")
    
    private lazy var titleLabel: UILabel = UILabel(text: tempLocalize("删除"), textColor: "Mine.Feedback.FeedbackRecordController.deleteButton.textColor", font: "Mine.Feedback.FeedbackRecordController.deleteButton.font")
    
    convenience init(_ target: Any?, action: Selector) {
        self.init()
        self.button.addTarget(target, action: action, for: .touchUpInside)
    }
    
    override func setupView() {
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.coverImageView)
        self.contentView.addSubview(self.titleLabel)
        self.addSubview(self.button)
        
        self.theme_backgroundColor = "Mine.Feedback.FeedbackRecordController.deleteButton.disabledBackgroundColor"
    }

    override func setupLayout() {
        self.coverImageView.snp.makeConstraints { make in
            make.width.height.equalTo(18)
            make.centerY.equalTo(self.titleLabel)
            make.left.equalTo(self.contentView)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.coverImageView.snp.right).offset(2)
            make.top.equalToSuperview().offset(16)
            make.right.equalToSuperview()
        }
        self.contentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        self.button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
