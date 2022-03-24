//
//  SCHomePageBottomView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/18.
//

import UIKit

enum SCHomePageBottomItemType: Int {
    case addToUsed = 0
    case moveTop
    case moveOutUsed
    case move
    case share
    case delete
    case rename
    
    var name: String {
        switch self {
        case .addToUsed:
            return tempLocalize("添加常用")
        case .moveTop:
            return tempLocalize("移到顶部")
        case .moveOutUsed:
            return tempLocalize("移除常用")
        case .move:
            return tempLocalize("移动")
        case .share:
            return tempLocalize("共享")
        case .delete:
            return tempLocalize("删除")
        case .rename:
            return tempLocalize("重命名")
        }
    }
    
    var image: ThemeImagePicker? {
        switch self {
        case .addToUsed:
            return "HomePage.HomePageController.BottomView.addToUsed"
        case .moveTop:
            return "HomePage.HomePageController.BottomView.moveTopImage"
        case .moveOutUsed:
            return "HomePage.HomePageController.BottomView.moveOutUsedImage"
        case .move:
            return "HomePage.HomePageController.BottomView.moveImage"
        case .share:
            return "HomePage.HomePageController.BottomView.shareImage"
        case .delete:
            return "HomePage.HomePageController.BottomView.deleteImage"
        case .rename:
            return "HomePage.HomePageController.BottomView.renameImage"
        }
    }
}

class SCHomePageBottomView: SCBasicView {

    var list: [SCHomePageBottomItemType] = [] {
        didSet {
            self.collectionView.set(list: [self.list])
        }
    }
    
    private var didSelectBlock: ((SCHomePageBottomItemType) -> Void)?

    private lazy var collectionView: SCBasicCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 60)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        let view = SCBasicCollectionView.init(cellClass: SCHomePageBottomCell.self, cellIdendify: SCHomePageBottomCell.identify, layout: layout) { [weak self] indexPath in
            guard let `self` = self else { return }
            let type = self.list[indexPath.row]
            self.didSelectBlock?(type)
        }
        return view
    }()
    
    convenience init(didSelectHandle: ((SCHomePageBottomItemType) -> Void)?) {
        self.init(frame: .zero)
        self.didSelectBlock = didSelectHandle
    }
    
    override func setupView() {
        self.theme_backgroundColor = "HomePage.HomePageController.BottomView.backgroundColor"
        self.addSubview(self.collectionView)
        
        let fromColor: UIColor = ThemeColorPicker(keyPath: "Global.ViewController.backgroundColor.fromColor").value() as! UIColor
        let toColor: UIColor = ThemeColorPicker(keyPath: "Global.ViewController.backgroundColor.toColor").value() as! UIColor
        
        if let fromComponents = fromColor.cgColor.components, let toComponents = toColor.cgColor.components, fromComponents.count >= 3, toComponents.count >= 3 {
            let height = kSCStatusBarHeight + 72
            let r = ((kSCScreenHeight - height)) * (toComponents[0] - fromComponents[0]) / kSCScreenHeight + fromComponents[0]
            let g = ((kSCScreenHeight - height)) * (toComponents[1] - fromComponents[1]) / kSCScreenHeight + fromComponents[1]
            let b = ((kSCScreenHeight - height)) * (toComponents[2] - fromComponents[2]) / kSCScreenHeight + fromComponents[2]
            let bgColor = UIColor(red: r, green: g, blue: b, alpha: 1)
            self.backgroundColor = bgColor
        }
    }
    
    override func setupLayout() {
        self.collectionView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(60)
        }
    }
}

class SCHomePageBottomCell: SCBasicCollectionViewCell {
    private lazy var coverImageView = UIImageView(contentMode: .scaleAspectFit)
    
    private lazy var titleLabel: UILabel = UILabel(textColor: "HomePage.HomePageController.BottomView.textColor", font: "HomePage.HomePageController.BottomView.font", alignment: .center)
    
    override func set(model: Any?) {
        guard let type = model as? SCHomePageBottomItemType else { return }
        self.coverImageView.theme_image = type.image
        self.titleLabel.text = type.name
    }
    
    override func setupView() {
        self.contentView.addSubview(self.coverImageView)
        self.contentView.addSubview(self.titleLabel)
    }
    
    override func setupLayout() {
        self.coverImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.top.equalToSuperview().offset(7)
            make.centerX.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(2)
            make.top.equalTo(self.coverImageView.snp.bottom).offset(2)
            make.height.equalTo(20)
        }
    }
}
