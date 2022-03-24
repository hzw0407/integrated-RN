//
//  SCFeedbackTypeItemCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/30.
//

import UIKit

class SCFeedbackTypeItemCell: SCBasicCollectionViewCell {
    private lazy var coverImageView: UIImageView = UIImageView(contentMode: .scaleAspectFit)
    
    private lazy var titleLabel: UILabel = UILabel(textColor: "Mine.Feedback.FeedbackTypeController.ItemCell.titleLabel.textColor", font: "Mine.Feedback.FeedbackTypeController.ItemCell.titleLabel.font", numberLines: 2, alignment: .center)
    
    override func set(model: Any?) {
        guard let model = model as? SCFeedbackTypeModel else { return }
        self.titleLabel.text = model.title
        if let image = model.image {
            self.coverImageView.theme_image = image
        }
        else {
            self.coverImageView.sd_setImage(with: URL(string: model.imageUrl), completed: nil)
        }
    }
    
    override func setupView() {
        self.contentView.addSubview(self.coverImageView)
        self.contentView.addSubview(self.titleLabel)
    }
    
    override func setupLayout() {
        self.coverImageView.snp.makeConstraints { make in
            make.width.height.equalTo(52)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(0)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.coverImageView.snp.bottom).offset(12)
//            make.bottom.equalToSuperview().offset(-20)
        }
    }
}
