//
//  BaseBluetoothManager.swift
//  SamUtils
//
//  Created by 杜千煜 on 2023/3/17.
//

import Foundation
import CoreBluetooth

public typealias bluetoothDeviceHandler = ([BluetoothDevice]) -> Void

public protocol BaseBluetoothDelegate: AnyObject {
    func isConnected(_ isConnected: Bool)
    func receiveData(_ data: Data?)
}

open class BaseBluetoothManager: NSObject {
    
    private let TAG = "BaseBluetoothManager"
    
    private var serviceUUID = ""
    private var notifyUUID = ""
    private var writeUUID = ""
    
    private var centralManager: CBCentralManager?
    private var connectPeripheral: CBPeripheral?
    private var writeCharactic: CBCharacteristic?
    private var notifyCharactic: CBCharacteristic?
    
    private var devicesHandler: bluetoothDeviceHandler?
    private var peripherals: [BluetoothDevice] = []
    
    private var isConnect = false
    
    public weak var delegate: BaseBluetoothDelegate?
    
    public override init() {
        super.init()
    }
    
    deinit {
        centralManager?.stopScan()
        centralManager?.delegate = nil
        connectPeripheral?.delegate = nil
        
        if let connectPeripheral = connectPeripheral {
            centralManager?.cancelPeripheralConnection(connectPeripheral)
        }
        
        centralManager = nil
        notifyCharactic = nil
    }
}

public extension BaseBluetoothManager {
    func setUUID(serviceUUID: String = "", notifyUUID: String, writeUUID: String) {
        self.serviceUUID = serviceUUID
        self.notifyUUID = notifyUUID
        self.writeUUID = writeUUID
    }
}

public extension BaseBluetoothManager {
    
    private func scanPeripherals() {
        if serviceUUID.isEmpty {
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
        } else {
            centralManager?.scanForPeripherals(withServices: [CBUUID(string: serviceUUID)], options: nil)
        }
    }
    
    func startScan(with devicesHandler: @escaping bluetoothDeviceHandler) {
        peripherals = []
        centralManager?.stopScan()
        self.devicesHandler = devicesHandler
        
        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self, queue: nil)
            
        } else {
            scanPeripherals()
        }
        
    }
    
    func stopScan() {
        if let centralManager = centralManager {
            centralManager.stopScan()
            peripherals.removeAll()
        }
    }
    
    func connectPeripheral(with uuid: String) {
        guard let centralManager = centralManager, centralManager.state == .poweredOn else {
            return
        }
        
        isConnect = false
        
        if let uuid = UUID(uuidString: uuid) {
            let peripheralArray = centralManager.retrievePeripherals(withIdentifiers: [uuid])
            
            if let peripheral = peripheralArray.first {
                centralManager.connect(peripheral, options: nil)
                
                switch peripheral.state {
                case .disconnected, .disconnecting:
                    centralManager.stopScan()
                    scanPeripherals()
                default:
                    break
                }
                
            } else {
                centralManager.stopScan()
                scanPeripherals()
            }
        }
    }
    
    func disConnectPeripheral(withUUID uuid: String?) {
        if let peripheral = connectPeripheral, let notifyCharactic = notifyCharactic {
            peripheral.setNotifyValue(false, for: notifyCharactic)
            
            if let centralManager = centralManager {
                centralManager.cancelPeripheralConnection(peripheral)
                centralManager.stopScan()
            }
        }
    }
    
    func sendData(_ data: Data, with writeType: CBCharacteristicWriteType) {
        guard let centerManger = centralManager,
              let peripheral = connectPeripheral,
              let writeCharactic = writeCharactic,
              centerManger.state == .poweredOn,
              isConnect
        else {
            return
            
        }
        
        if data.count > 20 {
            let subData = data.subdata(in: 0..<20)
            let lostData = data.subdata(in: 20..<data.count)
            
            peripheral.writeValue(subData, for: writeCharactic, type: writeType)
            peripheral.readValue(for: writeCharactic)
            sendData(lostData, with: writeType)
        } else {
            peripheral.writeValue(data, for: writeCharactic, type: writeType)
        }
    }
}

extension BaseBluetoothManager: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            scanPeripherals()
        default:
            break
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let deviceName = peripheral.name else {
            return
        }
        
        if !peripherals.contains(where: { $0.deviceUUID == peripheral.identifier.uuidString }) {
            let uuidString = peripheral.identifier.uuidString
            peripherals.append(BluetoothDevice(deviceName: deviceName,
                                               deviceUUID: uuidString))
            devicesHandler?(peripherals)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectPeripheral = peripheral
        centralManager?.stopScan()
        
        connectPeripheral?.delegate = self
        connectPeripheral?.discoverServices(nil)
    }
    
    //連接設備失敗
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            #if DEBUG
            print("\(TAG) connect failed: \(error)")
            #endif
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        notifyCharactic = nil
        connectPeripheral = nil
        
        isConnect = false
        delegate?.isConnected(false)
    }
    
}

extension BaseBluetoothManager: CBPeripheralDelegate {
    
    //掃描設備服務
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            #if DEBUG
            print("\(TAG) DiscoverServices error: \(error!)")
            #endif
            return
        }
        
        for service in peripheral.services! {
            if service.uuid.uuidString == serviceUUID {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    //掃描服務特徵
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            #if DEBUG
            print("\(TAG) DiscoverCharacteristics error: \(error!)")
            #endif
            return
        }
        
        for characteristic in service.characteristics! {
            let uuidString = characteristic.uuid.uuidString
            
            if uuidString == writeUUID {
                writeCharactic = characteristic
            }
            
            if uuidString == notifyUUID {
                notifyCharactic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
        }
        
        isConnect = true
        delegate?.isConnected(true)
        
    }
    
    //設備回傳資料時方法
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            return
        }
        
        if let requestData = characteristic.value {
            delegate?.receiveData(requestData)
        }
    }
    
    //寫入資料
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            #if DEBUG
            print("\(TAG) Write data error：: \(error!)")
            #endif
        }
    }
}
