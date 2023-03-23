//
//  BaseBluetoothManager.swift
//  SamUtils
//
//  Created by 杜千煜 on 2023/3/17.
//

import Foundation
import CoreBluetooth

public typealias bluetoothDeviceHandler = ([BluetoothDevice]) -> Void
public typealias DeviceConnectHandler = (_ isConnected: Bool) -> Void


public protocol BaseBluetoothDelegate: AnyObject {
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
    private var connectHandler: DeviceConnectHandler?
    private var peripherals: [BluetoothDevice] = []
    
    private weak var delegate: BaseBluetoothDelegate?

    /// Device is connect or not.
    public var isConnected = false
    
    public override init() {
        super.init()
        
    }
    
    /// required to set.
    public func setUpDelegate(delegate: BaseBluetoothDelegate) {
        self.delegate = delegate
    }
    
    private func checkDelegate() {
        if self.delegate == nil {
            print("BaseBluetoothManager: delegate must be set! use setUpDelegate func to set.")
        }
    }
    
    deinit {
        centralManager?.stopScan()
        centralManager?.delegate = nil
        connectPeripheral?.delegate = nil
        
        if let connectPeripheral = connectPeripheral {
            centralManager?.cancelPeripheralConnection(connectPeripheral)
        }
        
        centralManager = nil
        writeCharactic = nil
        notifyCharactic = nil
    }
}

public extension BaseBluetoothManager {
    /// Set up Bluetooth device service or characteristic UUID.
    ///
    ///     // Example
    ///     let serviceUUID = "180D"
    ///     let notifyUUID = "2A37"
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
    
    /// Start scan bluetooth device.
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
    
    /// Stop scan bluetooth device.
    func stopScan() {
        if let centralManager = centralManager {
            centralManager.stopScan()
            peripherals.removeAll()
        }
    }
    
    /// Connect to bluetooth deivce with device uuid and handler.
    func connectPeripheral(withUUID uuid: String, handler: DeviceConnectHandler?) {
        self.connectHandler = handler
        connectPeripheral(withUUID: uuid)
    }
    
    /// Connect to bluetooth deivce with device uuid.
    func connectPeripheral(withUUID uuid: String) {
        guard let centralManager = centralManager, centralManager.state == .poweredOn else {
            return
        }
        
        isConnected = false
        
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
    
    /// Disconnect to bluetooth deivce with device uuid.
    func disConnectPeripheral(withUUID uuid: String?) {
        if let peripheral = connectPeripheral, let notifyCharactic = notifyCharactic {
            peripheral.setNotifyValue(false, for: notifyCharactic)
            
            if let centralManager = centralManager {
                centralManager.cancelPeripheralConnection(peripheral)
                centralManager.stopScan()
            }
        }
    }
    
    /// Send data to bluetooth device
    ///
    /// if data size > 20, the method will split data to two data slice, first slice size = 20,  send first slice and automatic send left over data again, until data size <= 20.
    ///
    ///     // Example usgae
    ///     let hexData: [UInt8] = [0x68, 0x10, 0x20, 0x30]
    ///     let data = Data(hexData)
    ///     sendData(data, .withoutResponse)
    ///
    /// - Parameters:
    ///   - data: Hexadecimal need to convert to Data.
    ///   - writeType: Write type, need response or don't need response.
    func sendData(_ data: Data, with writeType: CBCharacteristicWriteType) {
        guard let centerManger = centralManager,
              let peripheral = connectPeripheral,
              let writeCharactic = writeCharactic,
              centerManger.state == .poweredOn,
              isConnected
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
    
    // 連接設備失敗
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            #if DEBUG
            print("\(TAG) connect failed: \(error)")
            #endif
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        checkDelegate()
        
        notifyCharactic = nil
        connectPeripheral = nil
        
        isConnected = false
        connectHandler?(false)
    }
    
}

extension BaseBluetoothManager: CBPeripheralDelegate {
    
    // 掃描設備服務
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil, let services = peripheral.services else {
            #if DEBUG
            print("\(TAG) DiscoverServices error: \(error!)")
            #endif
            return
        }
        
        for service in services {
            if service.uuid.uuidString == serviceUUID {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    // 掃描服務特徵
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil, let characteristics = service.characteristics else {
            #if DEBUG
            print("\(TAG) DiscoverCharacteristics error: \(error!)")
            #endif
            return
        }
        
        for characteristic in characteristics {
            let uuidString = characteristic.uuid.uuidString
            
            if uuidString == writeUUID {
                writeCharactic = characteristic
            }
            
            if uuidString == notifyUUID {
                notifyCharactic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        
        isConnected = true
        
        checkDelegate()
        connectHandler?(true)
        
    }
    
    // 設備回傳資料時方法
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil, let requestData = characteristic.value else {
            return
        }
        
        checkDelegate()
        
        delegate?.receiveData(requestData)
    }
    
    // 寫入資料
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            #if DEBUG
            print("\(TAG) Write data error：: \(error!)")
            #endif
        }
    }
}
