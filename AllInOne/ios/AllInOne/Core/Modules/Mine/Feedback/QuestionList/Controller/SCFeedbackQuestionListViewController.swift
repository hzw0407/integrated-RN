//
//  SCFeedbackQuestionListViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/30.
//

import UIKit

class SCFeedbackQuestionListViewController: SCBasicViewController {

    var model: SCFeedbackTypeModel?
    
    private var list: [SCNetResponseFaqItemModel] = []
        
    private let viewModel = SCFeedbackQuestionListViewModel()
    
    private var isShowDetail: Bool = false {
        didSet {
            self.tableView.isHidden = self.isShowDetail
            self.detailView.isHidden = !self.isShowDetail
        }
    }
    
    private lazy var tableView: SCBasicTableView = SCBasicTableView(cellClass: SCFeedbackQuestionListItemCell.self, cellIdendify: SCFeedbackQuestionListItemCell.identify, rowHeight: nil, hasEmptyView: true) { [weak self] indexPath in
        guard let `self` = self else { return }
        self.isShowDetail = true
        let item = self.list[indexPath.row]
        self.detailView.set(title: item.question, content: item.result)
    }
    
    private lazy var detailView: SCFeedbackQuestionDetailView = SCFeedbackQuestionDetailView()
    
    private lazy var feedbackButton: UIButton = UIButton(tempLocalize("反馈问题"), titleColor: "Mine.Feedback.FeedbackQuestionListController.feedbackButton.textColor", font: "Mine.Feedback.FeedbackQuestionListController.feedbackButton.font", target: self, action: #selector(feedbackButtonAction), backgroundColor: "Mine.Feedback.FeedbackQuestionListController.feedbackButton.backgroundColor", cornerRadius: 12)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
}

extension SCFeedbackQuestionListViewController {
    override func backBarButtonAction() {
        if self.isShowDetail {
            self.isShowDetail = false
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func setupView() {
        self.title = tempLocalize("帮助与反馈")
        
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.detailView)
        self.view.addSubview(self.feedbackButton)
        
        self.detailView.isHidden = true
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
            make.bottom.equalTo(self.feedbackButton.snp.top).offset(-20)
        }
        self.feedbackButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-36)
            make.height.equalTo(56)
        }
        self.detailView.snp.makeConstraints { make in
            make.edges.equalTo(self.tableView)
        }
    }
    
    override func setupData() {
        #if DEBUG
        self.model?.productId = "1470932677103190016"
        #endif
        self.viewModel.loadData(productId: self.model?.productId ?? "0") { [weak self] list in
            self?.list = list
            self?.tableView.set(list: [list])
        }
    }
    
    @objc private func feedbackButtonAction() {
        let vc = SCFeedbackViewController()
        vc.model = self.model
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
