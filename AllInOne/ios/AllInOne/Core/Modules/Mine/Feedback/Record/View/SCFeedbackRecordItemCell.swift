//
//  SCFeedbackRecordItemCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/1/7.
//

import UIKit

class SCFeedbackRecordItemCell: SCBasicTableViewCell {

    private lazy var titleLabel: UILabel = UILabel(textColor: "Mine.Feedback.FeedbackRecordController.ItemCell.titleLabel.textColor", font: "Mine.Feedback.FeedbackRecordController.ItemCell.titleLabel.font", numberLines: 1)
    
    private lazy var contetnLabel: UILabel = UILabel(textColor: "Mine.Feedback.FeedbackRecordController.ItemCell.contentLabel.textColor", font: "Mine.Feedback.FeedbackRecordController.ItemCell.contentLabel.font", numberLines: 2)
    
    private lazy var nameAndTimeLabel: UILabel = UILabel(textColor: "Mine.Feedback.FeedbackRecordController.ItemCell.nameAndTimeLabel.textColor", font: "Mine.Feedback.FeedbackRecordController.ItemCell.nameAndTimeLabel.font")
    
    
    private lazy var arrowImageView: UIImageView = UIImageView(image: "Global.ItemCell.arrowImage")
    
    private lazy var selectImageView: UIImageView = UIImageView(image: "Mine.Feedback.FeedbackRecordController.ItemCell.normalImage")
    
    override func set(model: Any?) {
        guard let model = model as? SCNetResponseFeedbackRecordModel else { return }
        self.titleLabel.text = model.title
        self.contetnLabel.text = model.question
        let interval = TimeInterval(model.createTime) ?? 0
        let time = Date.dateString(timeInterval: interval, format: "yyyy-MM-dd")
        self.nameAndTimeLabel.text = model.questionType + " | " + time
        self.arrowImageView.isHidden = model.isEditing
        
        self.selectImageView.isHidden = !model.isEditing
        if model.isEditing {
            if model.isSelected {
                self.selectImageView.theme_image = "Mine.Feedback.FeedbackRecordController.ItemCell.selectImage"
            }
            else {
                self.selectImageView.theme_image = "Mine.Feedback.FeedbackRecordController.ItemCell.normalImage"
            }
            self.selectImageView.snp.updateConstraints { make in
                make.left.equalToSuperview().offset(20)
            }
        }
        else {
            self.selectImageView.snp.updateConstraints { make in
                make.left.equalToSuperview().offset(-20)
            }
        }
    }
}

extension SCFeedbackRecordItemCell {
    override func setupView() {
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.contetnLabel)
        self.contentView.addSubview(self.nameAndTimeLabel)
        self.contentView.addSubview(self.arrowImageView)
        self.contentView.addSubview(self.selectImageView)
    }
    
    override func setupLayout() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.selectImageView.snp.right).offset(20)
            make.right.equalTo(self.arrowImageView.snp.left).offset(-10)
            make.top.equalToSuperview().offset(14)
        }
        self.contetnLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.titleLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(2)
        }
        self.nameAndTimeLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.titleLabel)
            make.top.equalTo(self.contetnLabel.snp.bottom)
            make.bottom.equalToSuperview().offset(-14)
        }
        self.arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        self.selectImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-20)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
}
