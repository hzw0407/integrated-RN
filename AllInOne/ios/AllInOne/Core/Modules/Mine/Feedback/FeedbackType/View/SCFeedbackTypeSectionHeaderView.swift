//
//  SCFeedbackTypeSectionHeaderView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/30.
//

import UIKit

class SCFeedbackTypeSectionHeaderView: SCBasicCollectionReusableView {

    private lazy var titleLabel: UILabel = UILabel(textColor: "Mine.Feedback.FeedbackTypeController.HeaderView.titleLabel.textColor", font: "Mine.Feedback.FeedbackTypeController.HeaderView.titleLabel.font")
    
    private lazy var lineView: UIView = UIView(lineBackgroundColor: "Mine.Feedback.FeedbackTypeController.HeaderView.lineBackgroundColor")
    
    override func set(model: Any?) {
        guard let title = model as? String else { return }
        self.titleLabel.text = title
        self.lineView.isHidden = title != tempLocalize("更多")
    }
    
    override func setupView() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.lineView)
        
        self.lineView.isHidden = true
    }
    
    override func setupLayout() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalToSuperview().offset(20)
        }
        self.lineView.snp.makeConstraints { make in
            make.left.right.equalTo(self.titleLabel)
            make.height.equalTo(0.5)
            make.top.equalToSuperview()
        }
    }
}
