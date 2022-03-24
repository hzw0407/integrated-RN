//
//  SCFeedbackTypeViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/30.
//

import UIKit

class SCFeedbackTypeViewController: SCBasicViewController {

    private lazy var sections: [[SCFeedbackTypeModel]] = []
    private lazy var titles: [String] = []
    
    private let viewModel = SCFeedbackTypeViewModel()
    
    private lazy var collectionView: SCBasicCollectionView = {
        let layout = UICollectionViewFlowLayout()
        let horizontalMargin: CGFloat = 24
        let verticalMargin: CGFloat = 20
        let spacing: CGFloat = 20
        let itemWidth = CGFloat(floorf(Float(kSCScreenWidth - horizontalMargin * 2 - spacing * 2) / 3))
        let itemHeight: CGFloat = 100
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: verticalMargin, left: horizontalMargin, bottom: verticalMargin, right: horizontalMargin)
        
        let collectionView = SCBasicCollectionView(cellClass: SCFeedbackTypeItemCell.self, cellIdendify: SCFeedbackTypeItemCell.identify, layout: layout) { [weak self] indexPath in
            guard let `self` = self else { return }
            let vc = SCFeedbackQuestionListViewController()
            vc.model = self.sections[indexPath.section][indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        collectionView.register(header: SCFeedbackTypeSectionHeaderView.self, idendify: SCFeedbackTypeSectionHeaderView.identify, size: CGSize(width: kSCScreenWidth, height: 52))
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension SCFeedbackTypeViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("帮助与反馈")
        self.addRightBarButtonItem(image: "Mine.Feedback.FeedbackTypeController.recordImage", action: #selector(recordAction))
    }
    
    override func setupView() {
        self.view.addSubview(self.collectionView)
    }
    
    override func setupLayout() {
        self.collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
        }
    }
    
    override func setupData() {
        let moreTypes:[SCFeedbackType] = [.smartScene, .account]
//        let moreTitles = [tempLocalize("智能场景"), tempLocalize("账号")]
        var moreItems: [SCFeedbackTypeModel] = []
        for type in moreTypes {
            let item = SCFeedbackTypeModel()
            item.title = type.name
            item.type = type
            item.image = nil
            moreItems.append(item)
        }
        self.sections = [[], moreItems]
        
        self.titles = [tempLocalize("我的设备"), tempLocalize("更多")]
        self.collectionView.set(list: self.sections, headerList: self.titles)
        self.loadDeviceData()
    }
    
    private func loadDeviceData() {
        self.viewModel.loadData { [weak self] in
            guard let `self` = self else { return }
            self.sections[0] = self.viewModel.devicItems
            self.collectionView.set(list: self.sections, headerList: self.titles)
        }
    }
    
    @objc private func recordAction() {
        let vc = SCFeedbackRecordViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
