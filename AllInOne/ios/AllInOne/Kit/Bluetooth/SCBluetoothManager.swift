//
//  SCBluetoothManager.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/12/9.
//

import UIKit
import BabyBluetooth
import CoreBluetooth
import sqlcipher

fileprivate let kChannelOnPeropheralView = "kChannelOnPeropheralView"

class SCBluetoothManager {
//    static let sharedInstance = SCBluetoothManager()
    
    private let baby: BabyBluetooth = BabyBluetooth.share()
    
    private var prepareScan: Bool = false
                    
    private var readDataBlock: ((CBPeripheral?, CBCharacteristic?, Data) -> Void)?
    private var centerUpdateStateBlock: ((CBCentralManager?) -> Void)?
    private var discoverPeripheralBlock: ((CBCentralManager?, CBPeripheral?, [AnyHashable: Any]?) -> Void)?
    private var connectedPeripheralBlock: ((CBCentralManager?, CBPeripheral?) -> Void)?
    private var connectPeripheralFailBlock: ((CBCentralManager?, CBPeripheral?, Error?) -> Void)?
    private var disconnectPeripheralBlock: ((CBCentralManager?, CBPeripheral?, Error?) -> Void)?
    private var discoverServicesBlock: ((CBPeripheral?, Error?) -> Void)?
    private var discoverCharacteristicsBlock: ((CBPeripheral?, CBService?, Error?) -> Void)?
    /// MTU - 3 为最大传输字节
    private var maximumUpdateValueLength: Int = 20
    
    private var readData: Data = Data()
    
    init(centerUpdateStateHandle: ((CBCentralManager?) -> Void)?,
         discoverPeripheralHandle: ((CBCentralManager?, CBPeripheral?, [AnyHashable: Any]?) -> Void)?,
                 connectedPeripheralHandle: ((CBCentralManager?, CBPeripheral?) -> Void)?,
                 connectPeripheralFailHandle: ((CBCentralManager?, CBPeripheral?, Error?) -> Void)?,
                 disconnectPeripheralHandle: ((CBCentralManager?, CBPeripheral?, Error?) -> Void)?,
                 discoverServicesHandle: ((CBPeripheral?, Error?) -> Void)?,
                 discoverCharacteristicsHandle: ((CBPeripheral?, CBService?, Error?) -> Void)?,
                 readDataHandle: ((CBPeripheral?, CBCharacteristic?, Data) -> Void)?) {
        self.setup()
        self.centerUpdateStateBlock = centerUpdateStateHandle
        self.discoverPeripheralBlock = discoverPeripheralHandle
        self.connectedPeripheralBlock = connectedPeripheralHandle
        self.connectPeripheralFailBlock = connectPeripheralFailHandle
        self.disconnectPeripheralBlock = disconnectPeripheralHandle
        self.discoverServicesBlock = discoverServicesHandle
        self.discoverCharacteristicsBlock = discoverCharacteristicsHandle
        self.readDataBlock = readDataHandle
    }
    
    func startScan() {
        self.prepareScan = true
        guard self.baby.centralManager().state == .poweredOn else { return }
        self.prepareScan = false
        self.baby.cancelAllPeripheralsConnection()
        self.baby.scanForPeripherals()()?.begin()()
    }
    
    func cancelScan() {
        self.prepareScan = false
        self.baby.cancelScan()
    }
    
    func stop() {
        self.prepareScan = false
        self.baby.stop()
    }
    
    func connect(peripheral: CBPeripheral) {
        self.setupOptions()
        self.baby.having()(peripheral)?.and()?.channel()(kChannelOnPeropheralView)?.then()?.connectToPeripherals()()?.discoverServices()()?.discoverCharacteristics()()?.readValueForCharacteristic()()?.discoverDescriptorsForCharacteristic()()?.readValueForDescriptors()()?.begin()()
    }
    
    func disconnect() {
        self.baby.cancelAllPeripheralsConnection()
    }
    
    func write(peripheral: CBPeripheral, characteristic: CBCharacteristic, data: Data) {
        DispatchQueue.global().async {
            SCSDKLog("发送蓝牙数据：\(data.hexString())")
            let sendDatas = self.splitBag(data: data)
            for item in sendDatas {
                peripheral.writeValue(item, for: characteristic, type: .withResponse)
                Thread.sleep(forTimeInterval: 0.02)
            }
        }
        
//        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    func readCharacteristic(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        self.baby.channel()(kChannelOnPeropheralView)?.characteristicDetails()(peripheral, characteristic)
        self.baby.notify(peripheral, characteristic: characteristic) { [weak self] peripheral, characteristic, error in
            guard let `self` = self else { return }
            if let data = characteristic?.value {
                SCSDKLog("BLE-- 收到数据 设备名称:\(peripheral?.name ?? "") 特征uuid:\(characteristic?.uuid.uuidString ?? ""), value length:\(data.count)")
                
                if data.count < 2 {
                    return
                }
                
                let bytes: [UInt8] = data.bytes
                let serial = bytes[0]
                let sum = bytes[1]
                
                print("收到收据serial:\(serial), sum:\(sum)")
                
                if serial == 0 {
                    self.readData.removeAll()
                }
                if serial <= sum {
                    let contentData = (data as NSData).subdata(with: NSRange(location: 2, length: data.count - 2))
                    self.readData.append(contentData)
                    if serial == sum {
                        let result = self.readData
                        self.readDataBlock?(peripheral, characteristic, result)
                        self.readData.removeAll()
                    }
                }
            }
        }
    }
    
    deinit {
        self.disconnect()
        self.stop()
    }
}

extension SCBluetoothManager {
    private func setup() {
        let scanOptions = [CBCentralManagerScanOptionAllowDuplicatesKey: true, CBCentralManagerOptionShowPowerAlertKey: false]
        self.baby.setBabyOptionsWithScanForPeripheralsWithOptions(scanOptions, connectPeripheralWithOptions: nil, scanForPeripheralsWithServices: nil, discoverWithServices: nil, discoverWithCharacteristics: nil)
        self.setupDelegate()
    }
    
    private func setupOptions() {
        let perScanOptions = [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        let connectionOptions = [CBConnectPeripheralOptionNotifyOnConnectionKey: true, CBConnectPeripheralOptionNotifyOnDisconnectionKey: true, CBConnectPeripheralOptionNotifyOnNotificationKey: true]
        self.baby.setBabyOptionsAtChannel(kChannelOnPeropheralView, scanForPeripheralsWithOptions: perScanOptions, connectPeripheralWithOptions: connectionOptions, scanForPeripheralsWithServices: nil, discoverWithServices: nil, discoverWithCharacteristics: nil)
    }
    
    private func setupDelegate() {
        let rhythm = BabyRhythm()
        
        self.baby.setFilterOnDiscoverPeripherals { peripheralName, advertisementData, RSSI in
            
            return true
        }
        
        self.baby.setBlockOnCentralManagerDidUpdateState { [weak self] central in
            guard let `self` = self else { return }
            if central?.state == .poweredOn {
                if self.prepareScan {
                    self.startScan()
                }
            }
            self.centerUpdateStateBlock?(central)
        }
        self.baby.setBlockOnDiscoverToPeripherals { [weak self] central, peripheral, advertisementData, RSSI in
            
            self?.discoverPeripheralBlock?(central, peripheral, advertisementData)
        }
        
        self.baby.setBlockOnConnectedAtChannel(kChannelOnPeropheralView) { [weak self] central, peripheral in
            guard let `self` = self else { return }
            if let peripheral = peripheral {
                self.maximumUpdateValueLength = peripheral.maximumWriteValueLength(for: .withoutResponse)
                SCSDKLog("外设MTU:\(self.maximumUpdateValueLength)")
            }
            self.connectedPeripheralBlock?(central, peripheral)
        }
        
        self.baby.setBlockOnFailToConnectAtChannel(kChannelOnPeropheralView) { [weak self] central, peripheral, error in
            self?.connectPeripheralFailBlock?(central, peripheral, error)
        }
        
        self.baby.setBlockOnDisconnectAtChannel(kChannelOnPeropheralView) { [weak self] central, peripheral, error in
            self?.disconnectPeripheralBlock?(central, peripheral, error)
        }
        
        self.baby.setBlockOnDiscoverServicesAtChannel(kChannelOnPeropheralView) { [weak self] peripheral, error in
            self?.discoverServicesBlock?(peripheral, error)
            rhythm.beats()
        }
        
        self.baby.setBlockOnDiscoverCharacteristicsAtChannel(kChannelOnPeropheralView) { [weak self] peripheral, service, error in
            self?.discoverCharacteristicsBlock?(peripheral, service, error)
        }
        
        rhythm.setBlockOnBeatsBreak { thm in
            
        }
        
        rhythm.setBlockOnBeatsOver { thm in
            
        }
        
        self.baby.setBlockOnReadValueForCharacteristicAtChannel(kChannelOnPeropheralView) { peripheral, characteristic, error in
            
        }
        
        self.baby.setBlockOnDidWriteValueForCharacteristicAtChannel(kChannelOnPeropheralView) { characteristic, error in
            
        }
        
        self.baby.setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel(kChannelOnPeropheralView) { peripheral, error in
            
        }
    }
}

extension SCBluetoothManager {
    private func splitBag(data: Data) -> [Data] {
        var offset: Int = 0
        var index: UInt8 = 1
        let unitLength: Int = self.maximumUpdateValueLength - 3 - 2
        let count = UInt8((data.count + 1) / unitLength + 1)
        var result: [Data] = []
        while offset < data.count {
            var subData: Data = Data()
            var length: Int = 0
            if data.count >= offset + unitLength {
                length = unitLength
                subData = (data as NSData).subdata(with: NSRange(location: offset, length: length))
                
            }
            else {
                length = data.count - offset
                subData = (data as NSData).subdata(with: NSRange(location: offset, length: length))
            }
            let preBytes = [index, count]
            let preData = Data(bytes: preBytes, count: preBytes.count)
            result.append(preData + subData)
            
            offset += length
            index += 1
        }
        return result
    }
}
