//
//  SCFeedbackContetnImageCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/1/6.
//

import UIKit

class SCFeedbackContetnImageModel {
    var image: UIImage?
    // 0 为图片，1为增加图片
    var type: Int = 0
}

protocol SCFeedbackContetnImageCellDelegate: AnyObject {
    func cell(_ cell: SCFeedbackContetnImageCell, deleteImageWithItem item: SCFeedbackContetnImageModel)
}

class SCFeedbackContetnImageCell: SCBasicCollectionViewCell {
    weak var delegate: SCFeedbackContetnImageCellDelegate?
    
    private lazy var coverImageView: UIImageView = UIImageView(contentMode: .scaleAspectFill)
    private lazy var deleteButton: UIButton = UIButton(image: "Mine.Feedback.FeedbackController.ContentView.deleteImageImage", target: self, action: #selector(deleteButtonAction))
    
    override func set(model: Any?) {
        self.model = model
        guard let model = model as? SCFeedbackContetnImageModel else { return }
        if model.type == 1 {
            self.coverImageView.theme_image = "Mine.Feedback.FeedbackController.ContentView.addImageImage"
            self.deleteButton.isHidden = true
        }
        else {
            self.coverImageView.image = model.image
            self.deleteButton.isHidden = false
        }
    }
    
    override func set(delegate: Any?) {
        self.delegate = delegate as? SCFeedbackContetnImageCellDelegate
    }
}

extension SCFeedbackContetnImageCell {
    override func setupView() {
        self.contentView.addSubview(self.coverImageView)
        self.contentView.addSubview(self.deleteButton)
    }
    
    override func setupLayout() {
        self.coverImageView.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }
        self.deleteButton.snp.makeConstraints { make in
            make.centerX.equalTo(self.coverImageView.snp.right)
            make.centerY.equalTo(self.coverImageView.snp.top)
            make.width.height.equalTo(20)
        }
    }
    
    @objc private func deleteButtonAction() {
        guard let model = self.model as? SCFeedbackContetnImageModel else { return }
        self.delegate?.cell(self, deleteImageWithItem: model)
    }
}
