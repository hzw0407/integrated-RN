//
//  SCHomePageViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/13.
//

import UIKit

fileprivate let kSaveFamilyIdKey = "kSaveFamilyIdKey"

class SCHomePageViewModel: SCBasicViewModel {
    /// 家庭列表
    var familyList: [SCNetResponseFamilyModel] = []
    /// 房间列表
    var roomList: [SCNetResponseFamilyRoomModel] = []
    /// 设备列表
    var deviceList: [SCNetResponseDeviceModel] = []
    
    /// 家庭
    var family: SCNetResponseFamilyModel = SCNetResponseFamilyModel()
    
    var currentFamilyId: String?
    
    var alertFamilys: [SCHomePageAlertFamilyListItem] = []
    
//    var room: SCNetResponseFamilyRoomModel = SCNetResponseFamilyRoomModel()
    
    private var isCache: Bool = true
    
    override init() {
        super.init()
        
        self.loadFamilyId()
    }
    
    func loadData(isNewFamily: Bool = false, success: (() -> Void)?, failure: (() -> Void)? = nil) {
//        SCProgressHUD.showWaitHUD()
        
        var loadedRoom: Bool = false
        var loadedDevice: Bool = false
        self.loadFamilyData(isNewFamily: isNewFamily) { [weak self] in
            guard let `self` = self, self.familyList.count > 0 else { return }
            let familyId = self.currentFamilyId ?? self.familyList.first!.id
            self.loadFamilyDetail(familyId: familyId) { [weak self] in
//                SCProgressHUD.hideHUD()
                self?.reloadData()
                loadedRoom = true
                if loadedRoom && loadedDevice {
                    self?.isCache = false
                }
                success?()
            } failure: {
                failure?()
            }
            self.loadDeviceData(familyId: familyId) { [weak self] in
                self?.reloadData()
                loadedDevice = true
                
                if loadedRoom && loadedDevice {
                    self?.isCache = false
                }
                
                success?()
            } failure: {
                failure?()
            }

        } failure: {
            failure?()
        }
    }
    
    func saveFamilyId(familyId: String, success: @escaping (() -> Void)) {
        guard self.familyList.count > 0 && self.currentFamilyId != familyId else { return }
//        UserDefaults.standard.setValue(familyId, forKey: kSaveFamilyIdKey)
//        UserDefaults.standard.synchronize()
        SCHomePageViewModel.saveFamilyIdToLocal(familyId: familyId)
        self.currentFamilyId = familyId
        self.family = self.familyList.first(where: { item in
            return item.id == familyId
        }) ?? SCNetResponseFamilyModel()
         
        self.loadData(success: success)
    }
    
    func loadFamilyId() {
        self.currentFamilyId = SCHomePageViewModel.currentFamilyId() ?? ""
    }
    
    func loadFamilyData(isNewFamily: Bool = false, success: (() -> Void)?, failure: (() -> Void)? = nil) {
        SCSmartNetworking.sharedInstance.getFamilyListRequest(isCache: self.isCache) { [weak self] list in
            guard let `self` = self, list.count > 0 else { return }
            self.familyList = list
            var currentFamilyId: String?
            self.family = list.first!
            self.family.isSelected = true
            do {
                var items: [SCHomePageAlertFamilyListItem] = []
                for (i, family) in list.enumerated() {
                    let item = SCHomePageAlertFamilyListItem()
                    item.family = family
                    item.hasLineView = true
                    item.isSelected = self.currentFamilyId == family.id
                    family.isOwner = family.creatorId == SCSmartNetworking.sharedInstance.user?.id
                    if isNewFamily {
                        item.isSelected = i == list.count - 1
                        self.family = family
                        self.currentFamilyId = family.id
                    }
                    else if item.isSelected {
                        currentFamilyId = family.id
                        self.family = family
                    }
                    
                    items.append(item)
                }
                
                if currentFamilyId == nil {
                    self.currentFamilyId = self.family.id
                }
                SCHomePageViewModel.saveFamilyIdToLocal(familyId: self.family.id)
                
                let item = SCHomePageAlertFamilyListItem()
                items.append(item)
                self.alertFamilys = items
            }
            success?()
        } failure: { error in
            failure?()
        }

    }
    
    func loadFamilyDetail(familyId: String, success: (() -> Void)?, failure: (() -> Void)? = nil) {
        SCSmartNetworking.sharedInstance.getFamilyDetailRequest(id: familyId, isCache: self.isCache) { [weak self] model in
            guard let `self` = self, let model = model else { return }
            model.isOwner = model.creatorId == SCSmartNetworking.sharedInstance.user?.id
            
            var rooms: [SCNetResponseFamilyRoomModel] = []
            for room in model.rooms {
                let roomType = SCFamilyRoomType(rawValue: room.roomType) ?? .normal
                if roomType == .used {
                    rooms.insert(room, at: 0)
                }
                else if roomType == .normal {
                    rooms.append(room)
                }
                else if roomType == .share && room.deviceNum > 0 {
                    rooms.append(room)
                }
            }
            model.rooms = rooms
            
            self.family = model
            self.roomList = model.rooms
            success?()
        } failure: { error in
            failure?()
        }
    }
    
    func loadDeviceData(familyId: String, success: (() -> Void)?, failure: (() -> Void)? = nil) {
        SCSmartNetworking.sharedInstance.getDeviceListByFamilyRequest(familyId: familyId, isCache: self.isCache) { [weak self] list in
            guard let `self` = self else { return }
            list.forEach { item in
                item.isOwner = item.owner == SCSmartNetworking.sharedInstance.user?.id
            }
            self.deviceList = list
            success?()
        } failure: { error in
            failure?()
        }

    }
    
    func saveRoomDevicesSortRequest(roomId: String, deviceIds: [String], success: (() -> Void)?, failure: (() -> Void)?) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.updateRoomDevicesSortRequest(deviceIds: deviceIds, roomId: roomId) {
            SCProgressHUD.hideHUD()
            success?()
        } failure: { error in
            SCProgressHUD.hideHUD()
            failure?()
        }

    }
    
    func moveDeviceToTopRequest(roomId: String, topDeviceIds: [String], originalDeviceIds: [String], success: (() -> Void)?, failure: (() -> Void)?) {
        SCProgressHUD.showWaitHUD()
        
        var ids: [String] = []
        ids.append(contentsOf: topDeviceIds)
        for id in originalDeviceIds {
            if topDeviceIds.contains(id) {
                continue
            }
            ids.append(id)
        }
        SCSmartNetworking.sharedInstance.updateRoomDevicesSortRequest(deviceIds: ids, roomId: roomId) {
            SCProgressHUD.hideHUD()
            success?()
        } failure: { error in
            SCProgressHUD.hideHUD()
            failure?()
        }
    }
    
    func addToUsedRoom(deviceIds: [String], roomId: String, usedRoomId: String, success: (() -> Void)?, failure: (() -> Void)?) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.moveDeviceToUsedRoom(deviceIds: deviceIds, roomId: roomId) {
            SCProgressHUD.hideHUD()
            success?()
        } failure: { error in
            SCProgressHUD.hideHUD()
            failure?()
        }
    }
    
    func moveDevicesOutOfUsed(deviceIds: [String], roomId: String, success: (() -> Void)?, failure: (() -> Void)?) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.moveDeviceOutUsedRequest(deviceIds: deviceIds, roomId: roomId) {
            SCProgressHUD.hideHUD()
            success?()
        } failure: { error in
            SCProgressHUD.hideHUD()
            failure?()
        }

    }
    
    func unbindDevice(deviceId: String, roomId: String, success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.unbindDeviceRequest(deviceId: deviceId) { result in
            SCProgressHUD.hideHUD()
            if result == true {
                success()
            }
        } failure: { error in
            SCProgressHUD.hideHUD()
        }

    }
    
//    func bindDevicesToRoom(devices: [SCNetResponseDeviceModel], roomId: String, success: @escaping (() -> Void)) {
//        SCProgressHUD.showWaitHUD()
//        var deviceIds: [String] = []
//        var sns: [String] = []
//        for device in devices {
//            deviceIds.append(device.deviceId)
//            sns.append(device.sn)
//        }
//        let deviceId = deviceIds.first ?? ""
//        let sn = sns.first ?? ""
//        SCSmartNetworking.sharedInstance.bindDeviceByRoom(sn: sn, deviceId: deviceId, nickname: nil, roomId: roomId) { result in
//            SCProgressHUD.hideHUD()
//            if result == true {
//                success()
//            }
//        } failure: { error in
//            SCProgressHUD.hideHUD()
//        }
//
//    }
//
    func unbindDeviceFromRoom(deviceId: String, roomId: String, success: @escaping (() -> Void)) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.unbindDeviceByRoom(deviceId: deviceId, roomId: roomId) { result in
            SCProgressHUD.hideHUD()
            if result == true {
                success()
            }
        } failure: { error in
            SCProgressHUD.hideHUD()

        }
    }
    
    func modifyDeviceNickname(deviceId: String, roomId: String, name: String, success: (() -> Void)?) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.modifyDeviceNicknameRequest(deviceId: deviceId, roomId: roomId, nickname: name) {
            SCProgressHUD.hideHUD()
            success?()
        } failure: { error in
            SCProgressHUD.hideHUD()
        }

    }
    
    func bindDeviceToRoom(deviceId: String, roomId: String, familyId: String, nickname: String?, sn: String?, productId: String?, success: (() -> Void)?, failure: (() -> Void)?) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.bindDeviceByRoom(deviceId: deviceId, roomId: roomId, familyId: familyId, nickname: nickname, sn: sn, productId: productId, success: {
            SCProgressHUD.hideHUD()
            success?()
        }, failure: { error in
            SCProgressHUD.hideHUD()
            failure?()
        })
    }
    
    func addRoom(familyId: String, name: String, success: (() -> Void)?) {
        SCProgressHUD.showWaitHUD()
        SCSmartNetworking.sharedInstance.addFamilyRoomRequest(familyId: familyId, name: name) {
            SCProgressHUD.hideHUD()
            success?()
        } failure: { error in
            SCProgressHUD.hideHUD()
        }

    }
    
    func reloadData() {
        guard self.roomList.count > 0 else { return }
        for item in self.roomList {
            var devices: [SCNetResponseDeviceModel] = []
            for deviceId in item.deviceIds {
                if let device = self.deviceList.filter({ $0.deviceId == deviceId }).first {
                    devices.append(device)
                }
            }
//            #if DEBUG
//            if devices.count == 0 {
//                devices.append(contentsOf: self.deviceList)
//            }
//            #endif
            item.devices = devices
        }
    }
    
    private func loadLocalDevicesData() {
        let titles = ["大哥大", "老板", "孙悟空", "猪八戒", "荒天帝", "青木", "玉皇大帝", "如来佛祖", "唐三藏", "九头蛇"]
        let statuses = [0, 1, 2, 0, 1, 2, 1, 0, 2, 0]
        let images = ["https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimage.suning.cn%2Fuimg%2FMZMS%2Fshow%2F162826123133945586.jpg&refer=http%3A%2F%2Fimage.suning.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1642322088&t=23adf29c7275afb99603ea52b0814020", "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwww.zuyushop.com%2FProPic%2F20131%2F201301001142101217.jpg&refer=http%3A%2F%2Fwww.zuyushop.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1642322115&t=2be25d38a4b71f984dd717a6c852e4be", "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fqnam.smzdm.com%2F202106%2F21%2F60cffe9092be15579.jpg_e1080.jpg&refer=http%3A%2F%2Fqnam.smzdm.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1642322132&t=51cacb15ec4bc5dfa4c54db3343fbe08", "https://img1.baidu.com/it/u=3269050307,3258730149&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500", "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimage.suning.cn%2Fuimg%2FMZMS%2Fshow%2F162826123133945586.jpg&refer=http%3A%2F%2Fimage.suning.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1642322088&t=23adf29c7275afb99603ea52b0814020", "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwww.zuyushop.com%2FProPic%2F20131%2F201301001142101217.jpg&refer=http%3A%2F%2Fwww.zuyushop.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1642322115&t=2be25d38a4b71f984dd717a6c852e4be", "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fqnam.smzdm.com%2F202106%2F21%2F60cffe9092be15579.jpg_e1080.jpg&refer=http%3A%2F%2Fqnam.smzdm.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1642322132&t=51cacb15ec4bc5dfa4c54db3343fbe08", "https://img1.baidu.com/it/u=3269050307,3258730149&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500", "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimage.suning.cn%2Fuimg%2FMZMS%2Fshow%2F162826123133945586.jpg&refer=http%3A%2F%2Fimage.suning.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1642322088&t=23adf29c7275afb99603ea52b0814020", "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwww.zuyushop.com%2FProPic%2F20131%2F201301001142101217.jpg&refer=http%3A%2F%2Fwww.zuyushop.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1642322115&t=2be25d38a4b71f984dd717a6c852e4be", "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fqnam.smzdm.com%2F202106%2F21%2F60cffe9092be15579.jpg_e1080.jpg&refer=http%3A%2F%2Fqnam.smzdm.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1642322132&t=51cacb15ec4bc5dfa4c54db3343fbe08", "https://img1.baidu.com/it/u=3269050307,3258730149&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500"]
        
        var items: [SCNetResponseDeviceModel] = []
        for (i, title) in titles.enumerated() {
            let device = SCNetResponseDeviceModel()
            device.nickname = title
            device.photoUrl = images[i]
            device.status = statuses[i]
            items.append(device)
        }
        self.deviceList = items
    }
}

extension SCHomePageViewModel {
    class func saveFamilyIdToLocal(familyId: String) {
        let uid = SCSmartNetworking.sharedInstance.user?.id ?? ""
        let param = [uid: familyId]
        UserDefaults.standard.setValue(param, forKey: kSaveFamilyIdKey)
        UserDefaults.standard.synchronize()
    }
    
    class func currentFamilyId() -> String? {
        let uid = SCSmartNetworking.sharedInstance.user?.id ?? ""
        let param = UserDefaults.standard.value(forKey: kSaveFamilyIdKey) as? [String: String]
        return param?[uid] ?? ""
    }
}
