//
//  SCFeedbackQuestionDetailView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/30.
//

import UIKit

class SCFeedbackQuestionDetailView: SCBasicView {

    private lazy var scrollView: UIScrollView = UIScrollView()
    
    private lazy var titleLabel: UILabel = UILabel(textColor: "Mine.Feedback.FeedbackQuestionListController.DetailView.titleLabel.textColor", font: "Mine.Feedback.FeedbackQuestionListController.DetailView.titleLabel.font", numberLines: 0)
    
    private lazy var lineView: UIView = UIView(lineBackgroundColor: "Mine.Feedback.FeedbackQuestionListController.DetailView.lineBackgroundColor")
    
    private lazy var contentLabel: UILabel = UILabel(textColor: "Mine.Feedback.FeedbackQuestionListController.DetailView.contentLabel.textColor", font: "Mine.Feedback.FeedbackQuestionListController.DetailView.contentLabel.font", numberLines: 0)
    
    func set(title: String, content: String) {
        self.titleLabel.text = title
        self.contentLabel.text = content
    }
    
    override func setupView() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.titleLabel)
        self.scrollView.addSubview(self.contentLabel)
        self.scrollView.addSubview(self.lineView)
    }
    
    override func setupLayout() {
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(kSCScreenWidth - 20 * 2)
            make.top.equalToSuperview().offset(20)
        }
        self.lineView.snp.makeConstraints { make in
            make.left.right.equalTo(self.titleLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            make.height.equalTo(0.5)
        }
        self.contentLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.titleLabel)
            make.top.equalTo(self.lineView.snp.bottom).offset(20)
        }
    }
}
