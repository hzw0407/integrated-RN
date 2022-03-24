//
//  SCQRCodeScanViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/16.
//

import UIKit
import AVFoundation

enum SCQRcodeScanType: Int {
    case addDevice
}

class SCQRCodeScanViewController: UIViewController {

    var type: SCQRcodeScanType = .addDevice
    
    // 启动区域识别功能
    var isOpenInterestRect = false
    
    //连续扫码
    var isSupportContinuous = false;
    
    // 是否需要识别后的当前图像
    var isNeedCodeImage = false

    // 相机启动提示文字
    var readyString: String = "loading"
    
    // 识别码的类型
    var arrayCodeType: [AVMetadataObject.ObjectType]?
    
    private var scanWrapper: LBXScanWrapper?
    
    private lazy var scanStyle: LBXScanViewStyle = {
        var style = LBXScanViewStyle()
        style.centerUpOffset = 44
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner
        style.photoframeLineW = 2
        style.photoframeAngleW = 18
        style.photoframeAngleH = 18
        style.isNeedShowRetangle = false
//        style.color_NotRecoginitonArea = ThemeColorPicker(keyPath: "Global.ViewController.backgroundColor.fromColor").value() as! UIColor
        style.anmiationStyle = LBXScanViewAnimationStyle.LineMove
        style.animationImage = ThemeImagePicker(keyPath: "Global.QRCodeScanController.animationImage").value() as? UIImage
        style.colorAngle = ThemeColorPicker(keyPath: "Global.QRCodeScanController.cornerColor").value() as! UIColor
        return style
    }()
    
    private lazy var scanView: LBXScanView = {
        let view = LBXScanView(frame: UIScreen.main.bounds, vstyle: self.scanStyle)
        return view
    }()
    
    private lazy var backButton: UIButton = UIButton(image: "Global.NavigationBackItem.image", target: self, action: #selector(backBarButtonAction))
    
    private lazy var rightButton: UIButton = UIButton(image: "Global.QRCodeScanController.photoImage", target: self, action: #selector(rightBarButtonAction))
    
    private lazy var titleLabel: UILabel = UILabel(text: tempLocalize("二维码添加设备"), textColor: "Global.NavigationBar.textColor", font: "Global.NavigationBar.textFont", numberLines: 0, alignment: .center)
    
    private lazy var flashButton: UIButton = UIButton(image: "Global.QRCodeScanController.flashCloseImage", target: self, action: #selector(flashButtonAction), selectedImage: "Global.QRCodeScanController.flashOpenImage")
    
    private lazy var flashLabel: UILabel = UILabel(text: tempLocalize("轻触点亮"), textColor: "Global.QRCodeScanController.flashLabel.textColor", font: "Global.QRCodeScanController.flashLabel.font", alignment: .center)
    
    private lazy var backgroundView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        let fromColor = ThemeColorPicker(keyPath: "Global.ViewController.backgroundColor.fromColor").value() as! UIColor
        let toColor = ThemeColorPicker(keyPath: "Global.ViewController.backgroundColor.toColor").value() as! UIColor
        view.layer.addSublayer(kGradientLayer(colors: [fromColor.cgColor, toColor.cgColor], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)))
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.setupView()
        self.setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.scanView.deviceStartReadying(readyStr: self.readyString)
        perform(#selector(SCQRCodeScanViewController.startScan), with: nil, afterDelay: 0.3)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
                
        self.scanView.deviceStopReadying()
        self.scanWrapper?.stop()
        self.scanWrapper?.setTorch(torch: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension SCQRCodeScanViewController {
    func setupView() {
        view.backgroundColor = UIColor.black
        edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        
//        self.view.addSubview(self.backgroundView)
        self.view.addSubview(self.scanView)
        self.view.addSubview(self.backButton)
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.rightButton)
        
        self.scanView.addSubview(self.flashButton)
        self.scanView.addSubview(self.flashLabel)
    }
    
    func setupLayout() {
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.top.equalTo(self.view.snp.topMargin).offset(2)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.backButton.snp.right).offset(10)
            make.right.equalTo(self.rightButton.snp.left).offset(-10)
            make.top.equalTo(self.view.snp.topMargin)
            make.height.equalTo(44)
        }
        self.rightButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.width.height.top.equalTo(self.backButton)
        }
        self.flashButton.snp.updateConstraints { make in
            make.width.height.equalTo(52)
            make.centerX.equalToSuperview()
            var offsetY = -self.scanStyle.centerUpOffset + 104
            let height = (kSCScreenWidth - 2 * self.scanStyle.xScanRetangleOffset) / self.scanStyle.whRatio
            offsetY += height / 2
            make.top.equalTo(self.view.snp.centerY).offset(offsetY)
        }
        self.flashLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(self.scanStyle.xScanRetangleOffset)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.flashButton.snp.bottom).offset(12)
        }
    }
    
    @objc private func startScan() {
        if self.scanWrapper == nil {
            var cropRect = CGRect.zero
            if isOpenInterestRect {
                cropRect = LBXScanView.getScanRectWithPreView(preView: view, style: scanStyle)
            }

            // 指定识别几种码
            if arrayCodeType == nil {
                arrayCodeType = [AVMetadataObject.ObjectType.qr as NSString,
                                 AVMetadataObject.ObjectType.ean13 as NSString,
                                 AVMetadataObject.ObjectType.code128 as NSString] as [AVMetadataObject.ObjectType]
            }
            
            self.scanWrapper = LBXScanWrapper(videoPreView: view,
                                              objType: arrayCodeType!,
                                              isCaptureImg: isNeedCodeImage,
                                              cropRect: cropRect,
                                              success: { [weak self] (arrayResult) -> Void in
                                                 guard let `self` = self else {
                                                     return
                                                 }
                                                 if !self.isSupportContinuous {
                                                     // 停止扫描动画
                                                     self.scanView.stopScanAnimation()
                                                 }
                                                 self.handleCodeResult(arrayResult: arrayResult)
                                              })
        }
        self.scanWrapper?.supportContinuous = isSupportContinuous;

        // 结束相机等待提示
        self.scanView.deviceStopReadying()

        // 开始扫描动画
        self.scanView.startScanAnimation()

        // 相机运行
        self.scanWrapper?.start()
    }
    
    /// 处理扫码结果，如果是继承本控制器的，可以重写该方法,作出相应地处理，或者设置delegate作出相应处理
    private func handleCodeResult(arrayResult: [LBXScanResult]) {
        let result = arrayResult.first
        print("qr content: \(result?.strScanned), type:\(result?.strBarCodeType)")
    }
}

extension SCQRCodeScanViewController {
    @objc private func backBarButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func rightBarButtonAction() {
        SCPhotoBrowser.pushPhotoLibrary(maxSelectCount: 1) { [weak self] images in
            guard let `self` = self, let image = images?.first else { return }
            let arrayResult = LBXScanWrapper.recognizeQRImage(image: image)
            if !arrayResult.isEmpty {
                self.handleCodeResult(arrayResult: arrayResult)
            }
        }
    }
    
    @objc private func flashButtonAction() {
        self.flashButton.isSelected = !self.flashButton.isSelected
        if self.flashButton.isSelected {
            self.flashLabel.text = tempLocalize("轻触关闭")
        }
        else {
            self.flashLabel.text = tempLocalize("轻触点亮")
        }
        
        self.scanWrapper?.changeTorch()
    }
}

