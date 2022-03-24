//
//  SCHomePageDeviceCell.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/17.
//

import UIKit

protocol SCHomePageDeviceCellDelegate: AnyObject {
    func cell(_ cell: SCHomePageDeviceCell, longPressGestureRecongnizer gesture: UILongPressGestureRecognizer)
}

class SCHomePageDeviceCell: SCBasicCollectionViewCell {
    
    static var itemSize: CGSize = .zero
        
    private weak var delegate: SCHomePageDeviceCellDelegate?
    
    private var device: SCNetResponseDeviceModel?
    /// corner渐变Layer
    private var cornerGradientLayer: CAGradientLayer?
    /// 在线cornerView
    private lazy var cornerView: UIView = UIView(cornerRadius: 14)
    /// 离线cornerView
    private lazy var offlineCornerView: UIView = UIView(backgroundColor: "HomePage.HomePageController.ItemCell.offlineBackgroundColor", cornerRadius: 14)
    
    private lazy var coverImageView: UIImageView = UIImageView(contentMode: .scaleAspectFit)
    
    private lazy var nameLabel: UILabel = UILabel(textColor: "HomePage.HomePageController.ItemCell.nameLabel.textColor", font: "HomePage.HomePageController.ItemCell.nameLabel.font", numberLines: 1)
    
    private lazy var statusLabel: UILabel = UILabel(textColor: "HomePage.HomePageController.ItemCell.statusLabel.textColor", font: "HomePage.HomePageController.ItemCell.statusLabel.font")
    
    private lazy var selectImageView: UIImageView = UIImageView(contentMode: .scaleAspectFit)
    
    private lazy var underView: UIView = UIView()
    
    private var isAnimating: Bool = false
}

extension SCHomePageDeviceCell {
    override func set(model: Any?) {
        guard let device = model as? SCNetResponseDeviceModel else { return }
        self.device = device
        if self.cornerGradientLayer == nil && SCHomePageDeviceCell.itemSize != .zero {
            self.cornerGradientLayer = self.cornerView.addGradientLayer(direction: .topToBottom, backgroundFromColor: "HomePage.HomePageController.ItemCell.backgroundColor.fromColor", backgroundToColor: "HomePage.HomePageController.ItemCell.backgroundColor.toColor", size: SCHomePageDeviceCell.itemSize)
        }
        
        if device.photoUrl.count > 0 {
            let imagePath = SCSmartNetworking.sharedInstance.getHttpPath(forPath: device.photoUrl)
            self.coverImageView.sd_setImage(with: URL(string: imagePath), completed: nil)
        }
        
        self.nameLabel.text = device.nickname
        
        if device.status > 0 {
            self.cornerView.isHidden = false
            self.offlineCornerView.isHidden = true
            self.statusLabel.theme_textColor = "HomePage.HomePageController.ItemCell.statusLabel.textColor"
            
            self.statusLabel.text = tempLocalize("在线")
        }
        else {
            self.cornerView.isHidden = true
            self.offlineCornerView.isHidden = false
            self.statusLabel.theme_textColor = "HomePage.HomePageController.ItemCell.statusLabel.offlineTextColor"
            
            self.statusLabel.text = tempLocalize("设备离线")
        }
        
        if device.isEditing {
            self.selectImageView.isHidden = false
            if device.isSelected {
                self.selectImageView.theme_image = "HomePage.HomePageController.ItemCell.selectImage"
            }
            else {
                self.selectImageView.theme_image = "HomePage.HomePageController.ItemCell.normalImage"
            }
        }
        else {
            self.selectImageView.isHidden = true
        }
        
        if device.isEditing {
            self.startAnimation()
        }
        else {
            self.stopAnimation()
        }
    }
    
    override func set(delegate: Any?) {
        self.delegate = delegate as? SCHomePageDeviceCellDelegate
    }
}

extension SCHomePageDeviceCell {
    override func setupView() {
        self.contentView.addSubview(self.underView)
        self.underView.addSubview(self.cornerView)
        self.underView.addSubview(self.offlineCornerView)
        self.underView.addSubview(self.coverImageView)
        self.underView.addSubview(self.nameLabel)
        self.underView.addSubview(self.statusLabel)
        self.underView.addSubview(self.selectImageView)
        
        self.addLongPressGestureRecongnizer()
    }
    
    override func setupLayout() {
        let margin: CGFloat = 12
        self.underView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }
        self.cornerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.offlineCornerView.snp.makeConstraints { make in
            make.edges.equalTo(self.cornerView)
        }
        self.coverImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.top.equalToSuperview().offset(margin)
            make.width.height.equalTo(50)
        }
        self.nameLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(margin)
            make.top.equalTo(self.coverImageView.snp.bottom).offset(12)
        }
        self.statusLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(2)
            make.right.equalToSuperview().offset(-margin)
        }
        self.selectImageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.top.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
    }
    
    private func addLongPressGestureRecongnizer() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecongnizerAction(_:)))
        self.addGestureRecognizer(longPress)
    }
    
    @objc private func longPressGestureRecongnizerAction(_ gesture: UILongPressGestureRecognizer) {
        self.delegate?.cell(self, longPressGestureRecongnizer: gesture)
    }
}

extension SCHomePageDeviceCell {
    private func startAnimation() {
        guard let device = self.device, device.isEditing else {
            self.stopAnimation()
            return }
        if self.isAnimating {
            self.stopAnimation()
            return
        }
        
        self.isAnimating = true
        let angle = CGFloat.pi / 180 * 1
        UIView.animate(withDuration: 0.15, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction) { [weak self] in
            self?.transform = CGAffineTransform(rotationAngle: angle)
        } completion: { [weak self] _ in
            UIView.animate(withDuration: 0.15, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction) { [weak self] in
                self?.transform = CGAffineTransform(rotationAngle: -angle)
            } completion: { [weak self] _ in
                self?.isAnimating = false
                self?.startAnimation()
            }
        }

    }
    
    private func stopAnimation() {
        self.transform = CGAffineTransform.identity
        self.isAnimating = false
    }
}
