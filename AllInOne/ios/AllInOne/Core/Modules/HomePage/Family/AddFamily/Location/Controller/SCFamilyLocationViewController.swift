//
//  SCFamilyLocationViewController.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/21.
//

import UIKit
import MAMapKit
import AMapLocationKit
import AMapSearchKit

fileprivate let kMapPrivacyAgreeStatusKey = "kMapPrivacyAgreeStatusKey"

class SCFamilyLocationViewController: SCBasicViewController {

    private var saveBlock: ((SCFamilyLocationModel) -> Void)?
    
    private var mapView: MAMapView?
    
    private var annotation: MAPointAnnotation = MAPointAnnotation()
    
    private var locationManager: AMapLocationManager = AMapLocationManager()
    private var locationCoordinate: CLLocationCoordinate2D?
    
    private var locationItem: SCFamilyLocationModel = SCFamilyLocationModel()
    
    private lazy var search: AMapSearchAPI? = {
        let search = AMapSearchAPI()
        search?.delegate = self
        return search
    }()
    
    private var geo: AMapGeocodeSearchRequest = AMapGeocodeSearchRequest()
    private var regeo: AMapReGeocodeSearchRequest = AMapReGeocodeSearchRequest()
    
    private lazy var searchButton: SCFamilyLocationSearchButton = SCFamilyLocationSearchButton { [weak self] in
        let vc = SCSearchLocationViewController()
        vc.key = self?.searchButton.text ?? ""
        vc.add { [weak self] item in
            guard let `self` = self else { return }
            self.locationItem.latitude = item.location.latitude
            self.locationItem.longitude = item.location.longitude
            self.locationItem.searchKey = item.title
            self.locationItem.address = item.content
            
            self.reloadLocationData()
//            self.reloadLocationText()
        }
        self?.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.setupPrivacy()
        self.setupMapView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func add(saveHandle: ((SCFamilyLocationModel) -> Void)?) {
        self.saveBlock = saveHandle
    }
}

extension SCFamilyLocationViewController {
    override func setupNavigationBar() {
        self.title = tempLocalize("家庭位置")
        self.addRightBarButtonItem(image: "Global.GeneralImage.saveImage", action: #selector(saveButtonAction))
    }
    
    @objc private func saveButtonAction() {
        self.saveBlock?(self.locationItem)
        self.navigationController?.popViewController(animated: true)
    }
}

extension SCFamilyLocationViewController {
//    private func setupPrivacy() {
//        if !UserDefaults.standard.bool(forKey: kMapPrivacyAgreeStatusKey) {
//            let message = String(format: tempLocalize("\n亲，感谢您对%@一直以来的信任！我们依据最新的监管要求更新了%@《隐私权政策》，特向您说明如下\n1.为向您提供交易相关基本功能，我们会收集、使用必要的信息；\n2.基于您的明示授权，我们可能会获取您的位置（为您提供附近的商品、店铺及优惠资讯等）等信息，您有权拒绝或取消授权；\n3.我们会采取业界先进的安全措施保护您的信息安全；\n4.未经您同意，我们不会从第三方处获取、共享或向提供您的信息；"), kAppName, kAppName)
//            SCAlertView.alert(title: tempLocalize("提示"), message: message, cancelTitle: tempLocalize("不同意"), confirmTitle: tempLocalize("同意"), cancelCallback: { 
//                MAMapView.updatePrivacyAgree(.notAgree)
//            }, confirmCallback: { [weak self] in
//                MAMapView.updatePrivacyAgree(.didAgree)
//                UserDefaults.standard.setValue(true, forKey: kMapPrivacyAgreeStatusKey)
//                UserDefaults.standard.synchronize()
//                
//                self?.setupMapView()
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) { [weak self] in
//                    self?.setupLocation()
//                }
//            })
//            MAMapView.updatePrivacyShow(AMapPrivacyShowStatus.didShow, privacyInfo: AMapPrivacyInfoStatus.didContain)
//        }
//        else {
//            self.setupMapView()
//        }
//    }
    
    private func setupMapView() {
        let mapView = MAMapView()
        mapView.mapType = .standardNight
        mapView.delegate = self
        mapView.setZoomLevel(17, animated: false)
        self.view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.topMargin)
            make.left.right.bottom.equalToSuperview()
        }
        mapView.addAnnotation(self.annotation)
        
        mapView.addSubview(self.searchButton)
        
        self.searchButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(self.view.snp.topMargin).offset(12)
            make.height.equalTo(56)
        }
        
        self.mapView = mapView
        self.setupLocation()
    }
    
    private func setupLocation() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.requestLocation(withReGeocode: true, completionBlock: { [weak self] (location: CLLocation?, reGeocode: AMapLocationReGeocode?, error: Error?) in
            print("error:\(error?.localizedDescription)")
            guard let `self` = self else { return }
            if location != nil {
                self.locationItem.latitude = location!.coordinate.latitude
                self.locationItem.longitude = location!.coordinate.longitude
                self.locationItem.address = reGeocode?.formattedAddress ?? ""
                self.locationItem.city = reGeocode?.city ?? ""
                self.locationItem.street = reGeocode?.district ?? ""
                
                self.reloadLocationText()
                self.reloadLocationData()
            }
        })
    }
    
    private func reloadLocationData() {
        let coordinate = CLLocationCoordinate2D(latitude: self.locationItem.latitude, longitude: self.locationItem.longitude)
        self.mapView?.centerCoordinate = coordinate
        self.annotation.coordinate = coordinate
        
    }
    
    private func reloadLocationText() {
//        let address = self.locationItem.city + " " + self.locationItem.street
        let address = self.locationItem.locationName
        self.annotation.title = address
        self.searchButton.text = address
    }
}

extension SCFamilyLocationViewController: MAMapViewDelegate {
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        self.annotation.coordinate = mapView.centerCoordinate
        self.regeo.location = AMapGeoPoint.location(withLatitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        self.mapView?.selectAnnotation(self.annotation, animated: true)
        
        self.locationItem.latitude = mapView.centerCoordinate.latitude
        self.locationItem.longitude = mapView.centerCoordinate.longitude
                
        self.search?.aMapReGoecodeSearch(self.regeo)
    }
    
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        if view == self.annotation {
            
        }
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as? MAPinAnnotationView
            if annotationView == nil {
                annotationView = MAPinAnnotationView.init(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView?.canShowCallout = true
            annotationView?.animatesDrop = true
            annotationView?.isDraggable = true
            annotationView?.pinColor = .red
            
            return annotationView
        }
        return nil
    }
}

extension SCFamilyLocationViewController: AMapSearchDelegate {
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        if let regeocode = response.regeocode {
            self.locationItem.city = regeocode.addressComponent.city
            self.locationItem.street = regeocode.addressComponent.township
            self.locationItem.address = regeocode.formattedAddress
            self.reloadLocationText()
//            print("city:\(regeocode.addressComponent.city), twon:\(regeocode.addressComponent.township), neighborhood:\(regeocode.addressComponent.neighborhood), building:\(regeocode.addressComponent.building)")
            print("regeocode adress: \(regeocode.formattedAddress)")
        }
    }
}

extension SCFamilyLocationViewController {
    class func checkMapPrivacy(agreeHandle: (() -> Void)?) {
        if !UserDefaults.standard.bool(forKey: kMapPrivacyAgreeStatusKey) {
            let message = String(format: tempLocalize("\n亲，感谢您对%@一直以来的信任！我们依据最新的监管要求更新了%@《隐私权政策》，特向您说明如下\n1.为向您提供交易相关基本功能，我们会收集、使用必要的信息；\n2.基于您的明示授权，我们可能会获取您的位置（为您提供附近的商品、店铺及优惠资讯等）等信息，您有权拒绝或取消授权；\n3.我们会采取业界先进的安全措施保护您的信息安全；\n4.未经您同意，我们不会从第三方处获取、共享或向提供您的信息；"), kAppName, kAppName)
            SCAlertView.alert(title: tempLocalize("提示"), message: message, cancelTitle: tempLocalize("不同意"), confirmTitle: tempLocalize("同意"), cancelCallback: {
                MAMapView.updatePrivacyAgree(.notAgree)
            }, confirmCallback: {
                MAMapView.updatePrivacyAgree(.didAgree)
                UserDefaults.standard.setValue(true, forKey: kMapPrivacyAgreeStatusKey)
                UserDefaults.standard.synchronize()
                agreeHandle?()
            })
            MAMapView.updatePrivacyShow(AMapPrivacyShowStatus.didShow, privacyInfo: AMapPrivacyInfoStatus.didContain)
        }
        else {
            agreeHandle?()
        }
    }
}
