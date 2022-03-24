//
//  SCAddDeviceAutoSearchBluetoothGuideView.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/16.
//

import UIKit

class SCAddDeviceAutoSearchBluetoothGuideView: SCBasicView {
    private static let sharedInstance = SCAddDeviceAutoSearchBluetoothGuideView()
    
    private var prePoint: CGPoint = .zero
    
    private var containerHeight: CGFloat = 0
    
    private var setAuthBlock: (() -> Void)?
    
    private lazy var backgorundView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = "Global.AlertView.backgroundColor"
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundViewAction))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var container: UIView = {
        let view = UIView()
        view.theme_backgroundColor = "Global.AlertView.containerColor"
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: kSCScreenWidth, height: kSCScreenHeight), byRoundingCorners: UIRectCorner(rawValue: UIRectCorner.topLeft.rawValue | UIRectCorner.topRight.rawValue), cornerRadii: CGSize(width: 20, height: 20))
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        view.layer.mask = shape
        return view
    }()
    
    private lazy var setAuthImageView: UIImageView = UIImageView(image: "HomePage.AddDeviceController.AutoSearchView.GuideView.bluetoothAuthImage")
    
    private lazy var setAuthTitleButton: UIButton = {
        let btn = UIButton(tempLocalize("允许本应用的“蓝牙”权限"), titleColor: "HomePage.AddDeviceController.AutoSearchView.GuideView.titleLabel.textColor", font: "HomePage.AddDeviceController.AutoSearchView.GuideView.titleLabel.font")
        btn.theme_setImage("HomePage.AddDeviceController.AutoSearchView.GuideView.leftTipImage", forState: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        return btn
    }()
    
    private lazy var setAuthButton: UIButton = UIButton(tempLocalize("去开启>"), titleColor: "HomePage.AddDeviceController.AutoSearchView.GuideView.setAuthButton.textColor", font: "HomePage.AddDeviceController.AutoSearchView.GuideView.setAuthButton.font", target: self, action: #selector(setAuthButtonAction), disabledTitleColor: "HomePage.AddDeviceController.AutoSearchView.GuideView.setAuthButton.disabledTextColor")
    
    private lazy var lineView: UIView = UIView(lineBackgroundColor: "HomePage.AddDeviceController.AutoSearchView.GuideView.lineBackgroundColor")
    
    private lazy var openImageView: UIImageView = UIImageView(image: "HomePage.AddDeviceController.AutoSearchView.GuideView.bluetoothOpenImage")
    
    private lazy var openTitleButton: UIButton = {
        let btn = UIButton(tempLocalize("打开系统蓝牙"), titleColor: "HomePage.AddDeviceController.AutoSearchView.GuideView.titleLabel.textColor", font: "HomePage.AddDeviceController.AutoSearchView.GuideView.titleLabel.font")
        btn.theme_setImage("HomePage.AddDeviceController.AutoSearchView.GuideView.leftTipImage", forState: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        return btn
    }()
    
    convenience init(setAuthHandle: (() -> Void)?) {
        self.init(frame: .zero)
        self.setAuthBlock = setAuthHandle
    }
    
    class func show(hasAuth: Bool, setAuthHandle: (() -> Void)?) {
        let `self` = SCAddDeviceAutoSearchBluetoothGuideView.sharedInstance
        self.setAuthBlock = setAuthHandle
        kGetNormalWindow()?.addSubview(self)
        self.isHidden = false
        self.show()
        self.setAuthButton.isEnabled = !hasAuth
        if hasAuth {
            self.setAuthButton.setTitle(tempLocalize("已设置"), for: .normal)
        }
        else {
            self.setAuthButton.setTitle(tempLocalize("去开启>"), for: .normal)
        }
    }
}

extension SCAddDeviceAutoSearchBluetoothGuideView {
    override func setupView() {
        self.frame = UIScreen.main.bounds
        self.addSubview(self.backgorundView)
        self.addSubview(self.container)
        self.container.addSubview(self.setAuthImageView)
        self.container.addSubview(self.setAuthTitleButton)
        self.container.addSubview(self.setAuthButton)
        self.container.addSubview(self.lineView)
        self.container.addSubview(self.openImageView)
        self.container.addSubview(self.openTitleButton)
        
        self.addPanGesture()
    }
    
    override func setupLayout() {
        let horizontalMargin: CGFloat = 40
        self.backgorundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.openTitleButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(horizontalMargin)
        }
        self.openImageView.snp.makeConstraints { make in
            make.width.equalTo(188)
            make.height.equalTo(108)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.openTitleButton.snp.top).offset(-12)
        }
        self.lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(horizontalMargin)
            make.height.equalTo(0.5)
            make.bottom.equalTo(self.openImageView.snp.top).offset(-30)
        }
        self.setAuthButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.lineView.snp.top).offset(-30)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
        }
        self.setAuthTitleButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(horizontalMargin)
            make.bottom.equalTo(self.setAuthButton.snp.top)
        }
        self.setAuthImageView.snp.makeConstraints { make in
            make.width.equalTo(188)
            make.height.equalTo(108)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.setAuthTitleButton.snp.top).offset(-12)
        }
        self.container.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.setAuthImageView.snp.top).offset(-30)
        }
    }
    
    private func show() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let `self` = self else { return }
            var frame = self.container.frame
            frame.origin.y = kSCScreenHeight - self.container.frame.height
            self.container.frame = frame
        }
    }
    
    private func hide() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let `self` = self else { return }
            var frame = self.container.frame
            frame.origin.y = kSCScreenHeight
            self.container.frame = frame
        } completion: { [weak self] (_) in
            guard let `self` = self else { return }
            self.removeFromSuperview()
            self.isHidden = true
        }
    }
    
    private func addPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction))
        self.container.addGestureRecognizer(pan)
    }
}

extension SCAddDeviceAutoSearchBluetoothGuideView {
    @objc private func setAuthButtonAction() {
        self.setAuthBlock?()
    }
    
    @objc private func didTapBackgroundViewAction() {
        self.hide()
    }
}

extension SCAddDeviceAutoSearchBluetoothGuideView {
    @objc private func panGestureAction(pan: UIPanGestureRecognizer) {
        let point =  pan.translation(in: self.container)
        var rect = self.container.frame
        switch pan.state {
        case .began:
            self.prePoint = point
            self.containerHeight = self.container.bounds.height
            break
        case .changed:
            let offsetY = point.y - self.prePoint.y
            if offsetY > 0 && offsetY < self.containerHeight {
                let top = kSCScreenHeight - self.containerHeight
                rect.origin.y = top + offsetY
            }
            self.container.frame = rect
            break
        case .ended:
            let offsetY = point.y - self.prePoint.y
            let changeHeight: CGFloat = 100
            if offsetY < changeHeight {
                self.show()
            }
            else {
                self.hide()
            }
            break
        default:
            break
        }
    }
}
