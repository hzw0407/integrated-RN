//
//  SCMinePhotoSelectAlert.swift
//  AllInOne
//
//  Created by huangjie on 2021/12/27.
//

import UIKit

public enum SCMinePhotoActionType {
    case camera
    case photo
}

class SCMinePhotoSelectAlert: UIView {
    
    /// 拍照
    private lazy var cameraBtn: UIButton = {
        let cameraBtn = UIButton.init(tempLocalize("拍一张"), titleColor: "Mine.SCMineInfoEditController.SCMinePhotoSelectAlert.cameraBtn.titleColor", font: "Mine.SCMineInfoEditController.SCMinePhotoSelectAlert.cameraBtn.font", target: self, action: #selector(cameraBtnAction(btn:)))
        return cameraBtn
    }()
    /// 相册
    private lazy var photoBtn: UIButton = {
        let photoBtn = UIButton.init("从手机相册选择", titleColor: "Mine.SCMineInfoEditController.SCMinePhotoSelectAlert.photoBtn.titleColor", font: "Mine.SCMineInfoEditController.SCMinePhotoSelectAlert.photoBtn.font", target: self, action: #selector(photoBtnAction(btn:)))
        return photoBtn
    }()
    /// 取消
    private lazy var cancelBtn: UIButton = {
        let cancelBtn = UIButton.init("取消", titleColor: "Mine.SCMineInfoEditController.SCMinePhotoSelectAlert.cancelBtn.titleColor", font: "Mine.SCMineInfoEditController.SCMinePhotoSelectAlert.cancelBtn.font", target: self, action: #selector(cancelBtnAction(btn:)))
        cancelBtn.theme_backgroundColor = "Mine.SCMineInfoEditController.SCMinePhotoSelectAlert.cancelBtn.bgColor"
        return cancelBtn
    }()
    
    /// 横线
    private lazy var lineView: UIView = {
        let lineView = UIView.init(lineBackgroundColor: "Mine.SCMineInfoEditController.SCMinePhotoSelectAlert.lineView.bgColor")
        return lineView
    }()
    
    var actionBlock: ((SCMinePhotoActionType) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func showIn(superView: UIView) {
        superView.addSubview(self)
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveLinear) {
            let y = superView.bounds.size.height - self.frame.size.height
            self.frame = CGRect.init(x: 0, y: y, width: self.frame.size.width, height: self.frame.size.height)
        } completion: { finish in
            
        }
    }
    public func hide() {
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveLinear) {
            let y = UIScreen.main.bounds.size.height
            self.frame = CGRect.init(x: 0, y: y, width: self.frame.size.width, height: self.frame.size.height)
        } completion: { finish in
            self.removeFromSuperview()
        }
    }
}

// MARK: - Actions
extension SCMinePhotoSelectAlert {
    func initUI() {
        self.addSubview(self.cameraBtn)
        self.addSubview(self.photoBtn)
        self.addSubview(self.cancelBtn)
        self.addSubview(self.lineView)
        
        self.cameraBtn.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(10)
            make.height.equalTo(66)
        }
        self.photoBtn.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(self.cameraBtn.snp.bottom)
            make.height.equalTo(66)
        }
        self.cancelBtn.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.right.equalTo(-24)
            make.top.equalTo(self.photoBtn.snp.bottom).offset(20)
            make.height.equalTo(56)
        }
        self.lineView.snp.makeConstraints { make in
            make.left.equalTo(40)
            make.right.equalTo(-40)
            make.top.equalTo(self.cameraBtn.snp.bottom)
            make.height.equalTo(0.5)
        }
        
        self.cancelBtn.layer.cornerRadius = 18
        self.cancelBtn.layer.masksToBounds = true
        
        self.theme_backgroundColor = "Mine.SCMineInfoEditController.SCMinePhotoSelectAlert.bgColor"
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height), byRoundingCorners: UIRectCorner(rawValue: UIRectCorner.topLeft.rawValue | UIRectCorner.topRight.rawValue), cornerRadii: CGSize(width: 24, height: 24))
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        self.layer.mask = shape
    }
}

// MARK: - Actions
extension SCMinePhotoSelectAlert {
    @objc private func cameraBtnAction(btn: UIButton) {
        self.actionBlock?(SCMinePhotoActionType.camera)
        self.hide()
    }
    @objc private func photoBtnAction(btn: UIButton) {
        self.actionBlock?(SCMinePhotoActionType.photo)
        self.hide()
    }
    @objc private func cancelBtnAction(btn: UIButton) {
        self.hide()
    }
}
