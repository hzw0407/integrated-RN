//
//  SCSweeperNet.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/1/25.
//

import UIKit

class SCSweeperNet {
    
    private var mapNet: SCSweeperMapNet = SCSweeperMapNet()
    
    static let sharedInstance = SCSweeperNet()
    
    var device: SCNetResponseDeviceModel? {
        didSet {
            guard let device = device else {
                return
            }
            self.mapNet.deviceSn = device.sn
            self.mapNet.productModeCode = device.productModeCode
            
        }
    }
    
    init() {
        
    }
    
    func getMap(success: ((Data) -> Void)?) {
        self.mapNet.getRealTimeMap(success: success)
    }
}
