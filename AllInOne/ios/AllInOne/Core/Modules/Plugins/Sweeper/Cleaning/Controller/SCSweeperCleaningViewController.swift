//
//  SCSweeperCleaningViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/1/12.
//

import UIKit

private let controlViewHeightAtMapShow: CGFloat = 100
private let controlViewHeightAtMapHide: CGFloat = 120
private let mapViewTopMargin: CGFloat = 0
private let mapViewHeight: CGFloat = kSCScreenHeight - controlViewHeightAtMapShow

class SCSweeperCleaningViewController: SCBasicViewController {

    var device: SCNetResponseDeviceModel?
    
    private lazy var server: SCSweeperServer = SCSweeperServer(reloadDataHandler: { [weak self] in
        self?.reloadPropertyData()
    })
    
    /// 导航栏
    private lazy var navigationBar: SCSweeperCleaningNavigationBar = SCSweeperCleaningNavigationBar { [weak self] in // 返回
        self?.popBack()
    } settingsClickHandler: { // 进入设置页
        
    }

    /// 控制页
    private lazy var controlView: SCSweeperCleaningControlView = SCSweeperCleaningControlView { [weak self] in
        self?.stationAction()
    } cleaningClickHandle: { [weak self] in
        self?.cleanAction()
    }

    /// 地图页
    private lazy var mapView: SCSweeperCleaningMapView = SCSweeperCleaningMapView(closeHandler: { [weak self] in
        self?.hideMapView()
    }, changePlanTypeHandler: { [weak self] type in
        SCBPLog("点击切换清扫方案")
        self?.changePlanTypeHandler(type: type)
    }, selectCustomRoomHandler: { [weak self] room in
        SCBPLog("点击选择自定义房间")
    }, editCustomRoomHandler: { [weak self] room in
        SCBPLog("点击进入自定义房间编辑")
        let vc = SCSweeperCleaningCustomPlanRoomEditViewController()
        vc.room = room
        self?.navigationController?.pushViewController(vc, animated: true)
    })
    
    private lazy var mapModel: SCSweeperCleaningMapModel = SCSweeperCleaningMapModel { [weak self] offsetY in
        guard let `self` = self else { return }
        var rect = self.mapView.frame
        rect.origin.y += offsetY
        self.mapView.frame = rect
    } panEndedHandler: { [weak self] offsetY in
        if offsetY < -100 {
            self?.showMapView()
        }
        else {
            self?.hideMapView()
        }
    }

    override func viewDidLoad() {
        SCSweeperUtils.shared.setup()
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

extension SCSweeperCleaningViewController {
    override func setupView() {
        self.title = device?.nickname
        
        self.view.addSubview(self.navigationBar)
        self.view.addSubview(self.mapView)
        self.view.addSubview(self.controlView)
        
        self.mapModel.addPanGesture(fromView: self.view)
    }
    
    override func setupLayout() {
        self.mapView.frame = CGRect(x: 0, y: kSCScreenHeight - controlViewHeightAtMapHide + 20, width: kSCScreenWidth, height: mapViewHeight)
        self.navigationBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.topMargin)
            make.height.equalTo(44)
        }
        self.controlView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(controlViewHeightAtMapHide + 40)
        }
    }
    
    override func setupData() {
        SCSweeperNet.sharedInstance.device = device
        
        self.server.setup()
        self.navigationBar.title = self.device?.nickname
        
        #if DEBUG
        var items: [SCSweeperCleaningCustomPlanRoomModel] = []
        for i in 0..<5 {
            let item = SCSweeperCleaningCustomPlanRoomModel()
            item.roomId = i + 10
            item.roomName = "room\(i)"
            items.append(item)
        }
        self.mapView.customRooms = items
        #endif
    }
    
    private func popBack() {
        self.server.clear()
        self.navigationController?.popViewController(animated: true)
    }
}

extension SCSweeperCleaningViewController {
    func showMapView() {
        self.mapView.show(offsetY: mapViewTopMargin)
        self.mapModel.isPanEnabled = false
        self.controlView.reduce(height: controlViewHeightAtMapShow + 40)
    }
    
    func hideMapView() {
        self.mapView.hide(offsetY: kSCScreenHeight - controlViewHeightAtMapHide + 20)
        self.mapModel.isPanEnabled = true
        self.controlView.reset(height: controlViewHeightAtMapHide + 40)
    }
}

extension SCSweeperCleaningViewController {
    private func reloadPropertyData() {
        
    }
    
    private func cleanAction() {
        self.server.cleanAction()
    }
    
    private func stationAction() {
        self.server.stationAction()
    }
    
    private func changePlanTypeHandler(type: SCSweeperCleaningPlanType) {
        if type == .auto {
            if !self.server.aiSwitch {
                SCBPLog("AI关闭时，滑动切换至自动清扫时，引导用户开启AI")
                return
            }
        }
    }
}
