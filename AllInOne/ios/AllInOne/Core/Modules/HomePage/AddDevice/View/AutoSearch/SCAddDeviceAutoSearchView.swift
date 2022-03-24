//
//  SCAddDeviceAutoSearchView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/14.
//

import UIKit
import CoreBluetooth

class SCAddDeviceAutoSearchView: SCBasicView {
    
    var state: CBManagerState = .unknown {
        didSet {
            if self.state == .poweredOn {
                self.bluetoothAuthView.snp.updateConstraints { make in
                    make.top.equalToSuperview().offset(-56)
                }
                self.height = self.contentHeight
            }
            else {
                self.bluetoothAuthView.snp.updateConstraints { make in
                    make.top.equalToSuperview().offset(10)
                }
                self.height = self.contentHeight + 56 + 10
            }
            
        }
    }

    private (set) var height: CGFloat = 100 {
        didSet {
            self.snp.updateConstraints { make in
                make.height.equalTo(self.height)
            }
        }
    }
    
    private var contentHeight: CGFloat = 100
    
    private var didSelectItemBlock: ((SCNetResponseProductModel) -> Void)?
    private var reasonBlock: (() -> Void)?
    
    private var items: [SCNetResponseProductModel] = []

    private lazy var noneTitleLabel: UILabel = UILabel(text: tempLocalize("若持续扫描不到设备，建议手动添加"), textColor: "HomePage.AddDeviceController.AutoSearchView.ContentView.noneTitleLabel.textColor", font: "HomePage.AddDeviceController.AutoSearchView.ContentView.noneTitleLabel.font", numberLines: 2)
    private lazy var noneReasonButton: UIButton = UIButton(tempLocalize("扫描不到的可能原因？"), titleColor: "HomePage.AddDeviceController.AutoSearchView.ContentView.noneReasonButton.textColor", font: "HomePage.AddDeviceController.AutoSearchView.ContentView.noneReasonButton.font", target: self, action: #selector(noneReasonButtonAction))
    
    private lazy var bluetoothAuthView: SCAddDeviceAutoSearchAuthView = SCAddDeviceAutoSearchAuthView(title: tempLocalize("请先开启手机蓝牙"), typeImage: "HomePage.AddDeviceController.AutoSearchView.AuthView.bluetoothImage") {
        SCAddDeviceAutoSearchBluetoothGuideView.show(hasAuth: self.state != .unauthorized) {
            let url = URL(string: UIApplication.openSettingsURLString)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    private lazy var lineView: UIView = UIView(lineBackgroundColor: "HomePage.AddDeviceController.AutoSearchView.ContentView.lineBackgroundColor")
    
    private lazy var listCollectionView: SCBasicCollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = kSCScreenWidth
        let columns: CGFloat = 3
        let itemWidth: CGFloat = 80
        let itemHeight: CGFloat = 113
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 20, right: 20)
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.scrollDirection = .horizontal
        
        let collectionView = SCBasicCollectionView(cellClass: SCAddDeviceAutoSearchItemCell.self, cellIdendify: SCAddDeviceAutoSearchItemCell.identify, layout: layout) { [weak self] indexPath in
            guard let `self` = self, indexPath.row < self.items.count else { return }
            let item = self.items[indexPath.row]
            self.didSelectItemBlock?(item)
        }
        
        return collectionView
    }()
    
    private lazy var contentView = UIView()
    
    init(reasonHandle: (() -> Void)?, didSelectItemHandle: ((SCNetResponseProductModel) -> Void)?) {
        super.init(frame: .zero)
        self.reasonBlock = reasonHandle
        self.didSelectItemBlock = didSelectItemHandle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reload(items: [SCNetResponseProductModel]) {
        self.items = items
        if items.count == 0 {
            self.noneTitleLabel.isHidden = false
            self.noneReasonButton.isHidden = false
            self.listCollectionView.isHidden = true
            self.contentHeight = 100
        }
        else {
            self.noneTitleLabel.isHidden = true
            self.noneReasonButton.isHidden = true
            self.listCollectionView.isHidden = false
            self.contentHeight = 113 + 10 + 20
        }
        if self.state != .unknown && self.state != .poweredOn {
            self.height = self.contentHeight + 56 + 10
        }
        else {
            self.height = self.contentHeight
        }
        
        self.listCollectionView.set(list: [items])
    }
}

extension SCAddDeviceAutoSearchView {
    override func setupView() {
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.noneTitleLabel)
        self.contentView.addSubview(self.noneReasonButton)
        self.contentView.addSubview(self.listCollectionView)
        self.addSubview(self.lineView)
        self.addSubview(self.bluetoothAuthView)
        
        self.layer.masksToBounds = true
    }
    
    override func setupLayout() {
        self.contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.bluetoothAuthView.snp.bottom).offset(10)
        }
        self.noneTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(10)
        }
        self.noneReasonButton.snp.makeConstraints { make in
            make.left.equalTo(self.noneTitleLabel)
            make.top.equalTo(self.noneTitleLabel.snp.bottom).offset(0)
            make.height.equalTo(30)
        }
        self.listCollectionView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        self.lineView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        self.bluetoothAuthView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
//            make.top.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(-56)
            make.height.equalTo(56)
        }
    }
}

extension SCAddDeviceAutoSearchView {
    @objc private func noneReasonButtonAction() {
        self.reasonBlock?()
    }
}
