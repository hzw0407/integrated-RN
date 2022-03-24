//
//  SCFeedbackViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/1/6.
//

import UIKit
import Photos
import sqlcipher

class SCFeedbackViewController: SCBasicViewController {
    
    var model: SCFeedbackTypeModel?
    
    private var items: [SCFeedbackContetnImageModel] = []
    
    private var images: [UIImage] = []
    private var assets: [PHAsset] = []
    
    private let viewModel = SCFeedbackViewModel()
    
    private lazy var scrollView: UIScrollView = UIScrollView()

    private lazy var nameLabel: UILabel = UILabel(textColor: "Mine.Feedback.FeedbackController.nameLabel.textColor", font: "Mine.Feedback.FeedbackController.nameLabel.font")
    
    private lazy var titleTextField: SCTextField = SCTextField(placeholder: tempLocalize("输入问题标题，方便快速解决问题（选填）"), textDidChangeHandle: { text in
        
    })

    private lazy var contentView: SCFeedbackContentView = SCFeedbackContentView { [weak self] index in
        guard let `self` = self else { return }
        self.pushPhotoLibrary(index: index)
    } addImageHandle: { [weak self] in
        guard let `self` = self else { return }
        self.pushPhotoLibrary(index: nil)
        
    } deleteImageHandle: { [weak self] index in
        guard let `self` = self else { return }
        self.images.remove(at: index)
        self.assets.remove(at: index)
        self.reloadImageData()
    }
    
    private lazy var contactTextField: SCTextField = SCTextField(placeholder: tempLocalize("联系方式（必填）"), textDidChangeHandle: { text in
        
    })
    
    private lazy var routeTextField: SCTextField = SCTextField(placeholder: tempLocalize("路由器型号（选填）"), textDidChangeHandle: { text in
        
    })

    private lazy var uploadButton: UIButton = UIButton(tempLocalize("发送问题日志并提交"), titleColor: "Mine.Feedback.FeedbackController.uploadButton.textColor", font: "Mine.Feedback.FeedbackController.uploadButton.font", target: self, action: #selector(uploadButtonAction), backgroundColor: "Mine.Feedback.FeedbackController.uploadButton.backgroundColor", cornerRadius: 12)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension SCFeedbackViewController {
    override func setupView() {
        self.title = tempLocalize("反馈问题")
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.nameLabel)
        self.scrollView.addSubview(self.titleTextField)
        self.scrollView.addSubview(self.contentView)
        self.scrollView.addSubview(self.contactTextField)
        self.scrollView.addSubview(self.routeTextField)
        self.view.addSubview(self.uploadButton)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            guard let `self` = self else { return }
            let contentHeight = self.routeTextField.frame.maxY
            self.scrollView.contentSize = CGSize(width: kSCScreenWidth, height: contentHeight)
        }
    }
    
    override func setupLayout() {
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(kSCScreenWidth - 20 * 2)
            make.top.equalToSuperview().offset(20)
        }
        self.titleTextField.snp.makeConstraints { make in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(12)
            make.left.right.equalTo(self.nameLabel)
            make.height.equalTo(56)
        }
        self.contentView.snp.makeConstraints { make in
            make.top.equalTo(self.titleTextField.snp.bottom).offset(12)
            make.left.right.equalTo(self.nameLabel)
            make.height.equalTo(300)
        }
        self.contactTextField.snp.makeConstraints { make in
            make.left.right.height.equalTo(self.titleTextField)
            make.top.equalTo(self.contentView.snp.bottom).offset(12)
        }
        self.routeTextField.snp.makeConstraints { make in
            make.left.right.height.equalTo(self.titleTextField)
            make.top.equalTo(self.contactTextField.snp.bottom).offset(12)
        }
        self.scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
            make.bottom.equalTo(self.uploadButton.snp.top).offset(-40)
        }
        self.uploadButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-36)
        }
    }
    
    override func setupData() {
        let item = SCFeedbackContetnImageModel()
        item.type = 1
        self.items = [item]
        self.contentView.list = self.items
        
        self.nameLabel.text = self.model?.title
    }
    
    private func pushPhotoLibrary(index: Int?) {
        if let index = index {
            SCPhotoBrowser.previewAssets(sender: self, assets: self.assets, index: index) { [weak self] images, assets, isOriginal in
                if images.count != assets.count { return }
                self?.images = images
                self?.assets = assets
                self?.reloadImageData()
            }
        }
        else {
            SCPhotoBrowser.pushPhotoLibrary(allowSelectVideo: true, maxSelectCount: 3 - self.images.count, selectedAssets: []) { [weak self] images, assets, isOriginal in
                guard let `self` = self else { return }
                if images.count != assets.count { return }
                var tempAssets: [PHAsset] = []
                var tempImages: [UIImage] = []
                for (i, asset) in assets.enumerated() {
                    if let _ = self.assets.first(where: { $0.localIdentifier == asset.localIdentifier }) {
                        continue
                    }
                    tempAssets.append(asset)
                    tempImages.append(images[i])
                }
                self.images.append(contentsOf: tempImages)
                self.assets.append(contentsOf: tempAssets)
                self.reloadImageData()
            }
        }
    }
    
    private func reloadImageData() {
        var tempItems: [SCFeedbackContetnImageModel] = []
        for image in self.images {
            let item = SCFeedbackContetnImageModel()
            item.image = image
            item.type = 0
            tempItems.append(item)
        }
        if tempItems.count < 3 {
            let item = SCFeedbackContetnImageModel()
            item.type = 1
            tempItems.append(item)
        }
        self.items = tempItems
        self.contentView.list = self.items
    }
    
    @objc private func uploadButtonAction() {
        guard let model = self.model else { return }
        #if DEBUG
        model.productId = "1468870837200224256"
        #endif
        self.viewModel.uploadFeedback(productId: model.productId, title: self.titleTextField.text, phone: self.contactTextField.text ?? "", question: self.contentView.text ?? "", type: model.type.rawValue, questionType: model.title, routerModel: self.routeTextField.text, images: self.images, assets: self.assets) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
