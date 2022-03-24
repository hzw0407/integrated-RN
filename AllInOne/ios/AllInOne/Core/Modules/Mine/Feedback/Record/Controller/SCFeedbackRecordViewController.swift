//
//  SCFeedbackRecordViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/1/7.
//

import UIKit

class SCFeedbackRecordViewController: SCBasicViewController {

    private var isEdit: Bool = false {
        didSet {
            self.tableView.canDeleteEdit = !self.isEdit
            self.reloadEditingData()
            if self.viewModel.hasMoreData && !self.isEdit {
                self.tableView.mj_footer?.isHidden = false
            }
            else {
                self.tableView.mj_footer?.isHidden = true
            }
            self.tableView.mj_header?.isHidden = self.isEdit
        }
    }
    
    private let viewModel = SCFeedbackRecordViewModel()
    
    private lazy var tableView: SCBasicTableView = {
        let tableView = SCBasicTableView(cellClass: SCFeedbackRecordItemCell.self, cellIdendify: SCFeedbackRecordItemCell.identify, rowHeight: nil, hasEmptyView: true) { [weak self] indexPath in
            guard let `self` = self, self.viewModel.items.count > indexPath.row else { return }
            let item = self.viewModel.items[indexPath.row]
            if self.isEdit {
                item.isSelected = !item.isSelected
                self.tableView.reloadData()
                self.refreshDeleteButton()
            }
            else {
                
            }
        }
        tableView.canDeleteEdit = true
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.refreshData()
        })
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?.loadMoreData()
        })
        tableView.set { [weak self] indexPath in
            guard let `self` = self else { return }
            let item = self.viewModel.items[indexPath.row]
            self.viewModel.deleteFeedbackRecord(ids: [item.id]) { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.items.remove(at: indexPath.row)
                self.tableView.set(list: [self.viewModel.items])
                self.isEdit = false
            }
        }
        
        return tableView
    }()
    
    private lazy var deleteButton: SCFeedbackRecordDeleteButton = SCFeedbackRecordDeleteButton(self, action: #selector(deleteButtonAction))
    
    private lazy var editButton: UIButton = UIButton(image: "Mine.Feedback.FeedbackRecordController.editImage", target: self, action: #selector(editButtonAction))
    
    private lazy var selectAllButton: UIButton = UIButton(image: "Mine.Feedback.FeedbackRecordController.selectAllImage", target: self, action: #selector(selectAllButtonAction))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}


extension SCFeedbackRecordViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("帮助与反馈")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.editButton)
    }
    
    override func setupView() {
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.deleteButton)
    }
    
    override func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
            make.bottom.equalTo(self.deleteButton.snp.top)
        }
        self.deleteButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(78)
            make.bottom.equalToSuperview().offset(78)
        }
    }
    
    override func setupData() {
        self.refreshData()
    }
    
    override func backBarButtonAction() {
        if self.isEdit {
            self.isEdit = false
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func refreshData() {
        self.viewModel.refreshData { [weak self] hasMoreData in
            guard let `self` = self else { return }
            self.tableView.mj_footer?.isHidden = !hasMoreData
            self.tableView.mj_header?.endRefreshing()
            self.tableView.set(list: [self.viewModel.items])
        } failure: { [weak self] in
            self?.tableView.mj_header?.endRefreshing()
        }
    }
    
    private func loadMoreData() {
        self.viewModel.loadMoreData { [weak self] hasMoreData in
            guard let `self` = self else { return }
            self.tableView.mj_footer?.isHidden = !hasMoreData
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.set(list: [self.viewModel.items])
        } failure: { [weak self] in
            self?.tableView.mj_footer?.endRefreshing()
        }
    }
    
    private func refreshDeleteButton() {
        let selectedCount = self.viewModel.items.filter({ $0.isSelected }).count
        if self.isEdit && selectedCount > 0 {
            self.deleteButton.isEnabled = true
        }
        else {
            self.deleteButton.isEnabled = false
        }
    }
    
    private func reloadEditingData() {
        for item in self.viewModel.items {
            item.isEditing = self.isEdit
            if !item.isEditing {
                item.isSelected = false
            }
        }
        self.tableView.reloadData()
        
        var offset: CGFloat = 78
        if self.isEdit {
            offset = 0
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.deleteButton.snp.updateConstraints({ make in
                make.bottom.equalToSuperview().offset(offset)
            })
            self?.deleteButton.layoutIfNeeded()
        }
        
        if self.isEdit {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.selectAllButton)
        }
        else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.editButton)
        }
        
        self.refreshDeleteButton()
    }
    
    @objc private func editButtonAction() {
        self.isEdit = true
    }
    
    @objc private func selectAllButtonAction() {
        var isSelected: Bool = true
        let selectedCount = self.viewModel.items.filter({ $0.isSelected }).count
        if selectedCount == self.viewModel.items.count {
            isSelected = false
        }
        for item in self.viewModel.items {
            item.isSelected = isSelected
        }
        self.tableView.reloadData()
        self.refreshDeleteButton()
    }
    
    @objc private func deleteButtonAction() {
        var ids: [String] = []
        var tempItems: [SCNetResponseFeedbackRecordModel] = []
        for item in self.viewModel.items {
            if item.isSelected {
                ids.append(item.id)
            }
            else {
                tempItems.append(item)
            }
        }
        self.viewModel.deleteFeedbackRecord(ids: ids) { [weak self] in
            guard let `self` = self else { return }
            self.viewModel.items = tempItems
            self.tableView.set(list: [self.viewModel.items])
            self.isEdit = false
        }
    }
}
