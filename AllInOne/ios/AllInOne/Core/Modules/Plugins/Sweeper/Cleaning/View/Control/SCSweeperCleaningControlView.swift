//
//  SCSweeperCleaningControlView.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/2/15.
//

import UIKit

class SCSweeperCleaningControlView: SCBasicView {
    
    private var stationBlock: (() -> Void)?
    private var cleaningBlock: (() -> Void)?
    
    /// 圆角背景view
    private lazy var backgroundCornerView: UIView = {
        let height: CGFloat = 120
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kSCScreenWidth, height: height))
        let gradientView = UIView(gradientDirection: .topToBottom, backgroundFromColor: "PluginSweeperTheme.CleaningViewController.CleaningControlView.backgroundColor.fromColor", backgroundToColor: "PluginSweeperTheme.CleaningViewController.CleaningControlView.backgroundColor.toColor", corner: UIRectCorner(rawValue: UIRectCorner.topLeft.rawValue | UIRectCorner.topRight.rawValue), cornerRadius: 18, size: CGSize(width: kSCScreenWidth, height: height - 1))
        let sideView = UIView(corner: UIRectCorner(rawValue: UIRectCorner.topLeft.rawValue | UIRectCorner.topRight.rawValue), backgroundColor: "PluginSweeperTheme.CleaningViewController.CleaningControlView.backgroundColor.topSideColor", cornerRadius: 18, size: CGSize(width: kSCScreenWidth, height: height))
        gradientView.frame = CGRect(x: 0, y: 1, width: kSCScreenWidth, height: height - 1)
        sideView.frame = CGRect(x: 0, y: 0, width: kSCScreenWidth, height: height)
        view.addSubview(sideView)
        view.addSubview(gradientView)
        return view
    }()
    
    /// 非圆角背景view
    private lazy var backgroundView: UIView = {
        let height: CGFloat = 120
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kSCScreenWidth, height: height))
        let gradientView = UIView(gradientDirection: .topToBottom, backgroundFromColor: "PluginSweeperTheme.CleaningViewController.CleaningControlView.backgroundColor.fromColor", backgroundToColor: "PluginSweeperTheme.CleaningViewController.CleaningControlView.backgroundColor.toColor", corner: UIRectCorner(rawValue: UIRectCorner.topLeft.rawValue | UIRectCorner.topRight.rawValue), cornerRadius: 0, size: CGSize(width: kSCScreenWidth, height: height - 1))
        let sideView = UIView(backgroundColor: "PluginSweeperTheme.CleaningViewController.CleaningControlView.backgroundColor.topSideColor", cornerRadius: 0)
        gradientView.frame = CGRect(x: 0, y: 1, width: kSCScreenWidth, height: height - 1)
        sideView.frame = CGRect(x: 0, y: 0, width: kSCScreenWidth, height: height)
        view.addSubview(sideView)
        view.addSubview(gradientView)
        return view
    }()

    /// 基站按钮
    private lazy var stationButton: UIButton = UIButton(image: "PluginSweeperTheme.CleaningViewController.CleaningControlView.stationButton.backImage", target: self, action: #selector(stationButtonAction), imageEdgeInsets: UIEdgeInsets())
    
    /// 清扫按钮
    private lazy var cleaningButton: UIButton = UIButton(image: "PluginSweeperTheme.CleaningViewController.CleaningControlView.cleaningButton.startImage", target: self, action: #selector(cleaningButtonAction), imageEdgeInsets: UIEdgeInsets())
    
    /// 基站控制标题
    private lazy var stationLabel: UILabel = UILabel(text: tempLocalize("回站"), textColor: "PluginSweeperTheme.CleaningViewController.CleaningControlView.stationLabel.textColor", font: "PluginSweeperTheme.CleaningViewController.CleaningControlView.stationLabel.font")
    
    private lazy var slideTipLabel: UILabel = UILabel(text: tempLocalize("上滑显示清扫地图"), textColor: "PluginSweeperTheme.CleaningViewController.CleaningControlView.slideTipLabel.textColor", font: "PluginSweeperTheme.CleaningViewController.CleaningControlView.slideTipLabel.font", alignment: .center)

    convenience init(stationClickHandle: (() -> Void)?, cleaningClickHandle: (() -> Void)?) {
        self.init(frame: .zero)
        self.stationBlock = stationClickHandle
        self.cleaningBlock = cleaningClickHandle
    }
}

extension SCSweeperCleaningControlView {
    override func setupView() {
        self.addSubview(self.slideTipLabel)
        self.addSubview(self.backgroundCornerView)
        self.addSubview(self.backgroundView)
        self.addSubview(self.stationButton)
        self.addSubview(self.cleaningButton)
        self.addSubview(self.stationLabel)
        
        self.backgroundView.alpha = 0
        
        #if DEBUG
        self.stationButton.backgroundColor = .red
        self.cleaningButton.backgroundColor = .red
        #endif
    }
    
    override func setupLayout() {
        self.slideTipLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(40)
        }
        self.backgroundCornerView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(self.slideTipLabel.snp.bottom)
        }
        self.backgroundView.snp.makeConstraints { make in
            make.edges.equalTo(self.backgroundCornerView)
        }
        self.stationButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(self.backgroundView).offset(20)
            make.width.height.equalTo(60)
        }
        self.stationLabel.snp.makeConstraints { make in
            make.top.equalTo(self.stationButton.snp.bottom).offset(0)
            make.height.equalTo(30)
            make.centerX.equalTo(self.stationButton.snp.centerX)
        }
//        self.cleaningButton.snp.makeConstraints { make in
//            make.right.equalToSuperview().offset(-30)
//            make.top.bottom.equalToSuperview().inset(20)
//            make.width.equalTo(self.cleaningButton.snp.height)
//        }
        self.cleaningButton.frame = CGRect(x: kSCScreenWidth - 30 - 80, y: 20 + 40, width: 80, height: 80)
    }
    
    /// 缩小
    func reduce(height: CGFloat) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let `self` = self else { return }
            self.stationLabel.alpha = 0
            self.backgroundView.alpha = 1.0
            self.slideTipLabel.alpha = 0
            
            var rect = self.frame
            rect.size.height = height
            rect.origin.y = kSCScreenHeight - height
            self.frame = rect
            
            var cleanFrame = self.cleaningButton.frame
            cleanFrame.size.height = height - 2 * 20 - 40
            cleanFrame.size.width = height - 2 * 20 - 40
            cleanFrame.origin.x = kSCScreenWidth - 30 - cleanFrame.size.width
            self.cleaningButton.frame = cleanFrame
            
        } completion: { [weak self] _ in
            
        }

    }
    
    /// 还原
    func reset(height: CGFloat) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let `self` = self else { return }
            self.backgroundView.alpha = 0
            self.stationLabel.alpha = 1
            self.slideTipLabel.alpha = 1
            
            var rect = self.frame
            rect.size.height = height
            rect.origin.y = kSCScreenHeight - height
            self.frame = rect
            
            var cleanFrame = self.cleaningButton.frame
            cleanFrame.size.height = height - 2 * 20 - 40
            cleanFrame.size.width = height - 2 * 20 - 40
            cleanFrame.origin.x = kSCScreenWidth - 30 - cleanFrame.size.width
            self.cleaningButton.frame = cleanFrame
        } completion: { [weak self] _ in
            
        }
    }
}

extension SCSweeperCleaningControlView {
    @objc private func stationButtonAction() {
        self.stationBlock?()
    }
    
    @objc private func cleaningButtonAction() {
        self.cleaningBlock?()
    }
}
