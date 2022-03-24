//
//  SCSweeperCleaningCustomPlanCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/2/21.
//

import UIKit

protocol SCSweeperCleaningCustomPlanCellDelegate: AnyObject {
    func cell(_ cell: SCSweeperCleaningCustomPlanCell, didClickedSelectButtonWithRoom room: SCSweeperCleaningCustomPlanRoomModel)
}

class SCSweeperCleaningCustomPlanCell: SCBasicTableViewCell {

    private weak var delegate: SCSweeperCleaningCustomPlanCellDelegate?
    
    private var item: SCSweeperCleaningCustomPlanRoomModel?
    
    private lazy var selectButton: UIButton = UIButton(image: "", target: self, action: #selector(selectButtonAction), selectedImage: "", imageEdgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    
    private lazy var nameLabel: UILabel = UILabel(textColor: "", font: "")
    
    
    private lazy var arrowImageView: UIImageView = UIImageView(image: "")
    
    override func set(model: Any?) {
        guard let model = model as? SCSweeperCleaningCustomPlanRoomModel else { return }
        self.item = model
        self.selectButton.isSelected = model.isSelected
        self.nameLabel.text = model.roomName
    }
    
    override func set(delegate: Any?) {
        self.delegate = delegate as? SCSweeperCleaningCustomPlanCellDelegate
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension SCSweeperCleaningCustomPlanCell {
    override func setupView() {
        self.contentView.addSubview(self.selectButton)
        self.contentView.addSubview(self.nameLabel)
        
        self.contentView.addSubview(self.arrowImageView)
    }
    
    override func setupLayout() {
        self.selectButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.selectButton.snp.right)
            make.top.bottom.equalToSuperview()
        }
        self.arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
    
    @objc private func selectButtonAction() {
        guard let item = self.item else { return }
        item.isSelected = !item.isSelected
        self.selectButton.isSelected = item.isSelected
        self.delegate?.cell(self, didClickedSelectButtonWithRoom: item)
    }
}
