//
//  SCSelectBluetoothDeviceViewModel.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/16.
//

import UIKit
import CoreBluetooth

class SCSelectBluetoothDeviceViewModel: SCBasicViewModel {
    var product: SCNetResponseProductModel?
    
    private (set) var devices: [SCSelectBluetoothDeviceModel] = []
    
    func startScanDevices(stateHandle: ((CBManagerState) -> Void)?, discoverDeviceHandle: (([SCSelectBluetoothDeviceModel]) -> Void)?) {
        guard let product = self.product else { return }
        var filterPeripheraNames: [String] = []
        var filterPeripheralUuids: [String] = []
        
//        if product.dmsPrefix.count > 0 {
//            filterPeripheraNames.append(product.ssidPrefix)
//        }
//        if product.deviceUuid.count > 0 {
//            filterPeripheralUuids.append(product.deviceUuid)
//        }
        
        
        SCBindDeviceBluetoothService.shared.startScan() { state in
            stateHandle?(state)
        } discoverPeripheralsHandle: { [weak self] periphrals in
            guard let `self` = self else { return }
            var items: [SCSelectBluetoothDeviceModel] = []
            for periphral in periphrals {
                if let productId = periphral.productId {
                    if productId == self.product?.id {
                        let item = SCSelectBluetoothDeviceModel()
                        item.product = self.product
                        item.peripheral = periphral
                        items.append(item)
                    }
                }
//                let name = periphral.name ?? ""
//                let uuid = periphral.identifier.uuidString
//                if uuid == product.deviceUuid {
//                    let item = SCSelectBluetoothDeviceModel()
//                    item.product = self.product
//                    item.peripheral = periphral
//                    items.append(item)
//                }
//                else if name.hasPrefix(product.ssidPrefix) {
//                    let item = SCSelectBluetoothDeviceModel()
//                    item.product = self.product
//                    item.peripheral = periphral
//                    items.append(item)
//                }
            }
            self.devices = items
            discoverDeviceHandle?(items)
        }
    }
    
    func stopScan() {
        SCBindDeviceBluetoothService.shared.stopScan()
    }
}
