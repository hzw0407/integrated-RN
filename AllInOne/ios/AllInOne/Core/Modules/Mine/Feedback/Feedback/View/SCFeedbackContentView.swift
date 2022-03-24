//
//  SCFeedbackContentView.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/1/6.
//

import UIKit
import WCDBSwift

class SCFeedbackContentView: SCBasicView {
    
    var list: [SCFeedbackContetnImageModel] = [] {
        didSet {
            self.collectionView.set(list: [self.list])
            let width = CGFloat(self.list.count) * 60 + 5 * CGFloat(self.list.count - 1)
            self.collectionView.snp.updateConstraints { make in
                make.width.equalTo(width)
            }
        }
    }
    
    var text: String? {
        set {
            self.textView.text = newValue
        }
        get {
            return self.textView.text
        }
    }
    
    private var deleteImageBlock: ((_ index: Int) -> Void)?
    
    private var addImageBlock: (() -> Void)?
    
    private var didSelectImageBlock: ((_ index: Int) -> Void)?

    private lazy var textView: SCTextView = SCTextView(placeholder: tempLocalize("输入问题内容（必填）"))
    
    private lazy var collectionView: SCBasicCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = .zero
        let collectionView = SCBasicCollectionView(cellClass: SCFeedbackContetnImageCell.self, cellIdendify: SCFeedbackContetnImageCell.identify, layout: layout, cellDelegate: self) { [weak self] indexPath in
            guard let `self` = self else { return }
            let item = self.list[indexPath.row]
            if item.type == 1 {
                self.addImageBlock?()
            }
            else {
                self.didSelectImageBlock?(indexPath.row)
            }
        }
        return collectionView
    }()
    
    private lazy var addLabel: UILabel = UILabel(text: tempLocalize("添加图片"), textColor: "Mine.Feedback.FeedbackController.ContentView.addLabel.textColor", font: "Mine.Feedback.FeedbackController.ContentView.addLabel.font", numberLines: 2)
    
    convenience init(didSelectImageHandle: ((_ index: Int) -> Void)?, addImageHandle: (() -> Void)?, deleteImageHandle: ((_ index: Int) -> Void)?) {
        self.init()
        self.didSelectImageBlock = didSelectImageHandle
        self.addImageBlock = addImageHandle
        self.deleteImageBlock = deleteImageHandle
    }
}

extension SCFeedbackContentView {
    override func setupView() {
        self.theme_backgroundColor = "Mine.Feedback.FeedbackController.ContentView.backgroundColor"
        self.layer.cornerRadius = 12
        
        self.addSubview(self.textView)
        self.addSubview(self.collectionView)
        self.addSubview(self.addLabel)
    }
    
    override func setupLayout() {
        self.textView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(200)
        }
        self.collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(self.textView.snp.bottom).offset(10)
            make.height.equalTo(60)
            make.width.equalTo(60)
        }
        self.addLabel.snp.makeConstraints { make in
            make.left.equalTo(self.collectionView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(50)
            make.bottom.equalTo(self.collectionView)
        }
    }
}

extension SCFeedbackContentView: SCFeedbackContetnImageCellDelegate {
    func cell(_ cell: SCFeedbackContetnImageCell, deleteImageWithItem item: SCFeedbackContetnImageModel) {
        let indexPath = self.collectionView.indexPath(for: cell)
        self.deleteImageBlock?(indexPath?.row ?? 0)
    }
}
