//
//  SCFeedbackQuestionListItemCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/30.
//

import UIKit

class SCFeedbackQuestionListItemCell: SCBasicTableViewCell {

    private lazy var titleLabel = UILabel(textColor: "Mine.Feedback.FeedbackQuestionListController.ItemCell.titleLabel.textColor", font: "Mine.Feedback.FeedbackQuestionListController.ItemCell.titleLabel.font")
    
    private lazy var arrowImageView: UIImageView = UIImageView(image: "Global.ItemCell.arrowImage")
    
    override func set(model: Any?) {
        guard let model = model as? SCNetResponseFaqTypeModel else { return }
        self.titleLabel.text = model.label
    }

    override func setupView() {
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.arrowImageView)
    }
    
    override func setupLayout() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.bottom.equalToSuperview().inset(26)
        }
        self.arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
}
