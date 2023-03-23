//
//  BluetoothManager.swift
//  SamUtilsExample
//
//  Created by 杜千煜 on 2023/3/17.
//

import Foundation
import SamUtils

class BluetoothManagerSample: BaseBluetoothManager {
    
    static let shared = BluetoothManagerSample()
    
    private let TAG = "BluetoothManager"
    
    private override init() {
        super.init()
        
        // delegate is required.
        setUpDelegate(delegate: self)
        setUUID(serviceUUID: "", notifyUUID: "", writeUUID: "")
    }
    
    func setTime() {        
        let timeData = [0x02].map { UInt8($0) }
        let data = Data(bytes: timeData, count: timeData.count)
        sendData(data, with: .withoutResponse)
    }
    
}

extension BluetoothManagerSample: BaseBluetoothDelegate {
    func receiveData(_ data: Data?) {
        // TODO: Analysis data
    }
}
