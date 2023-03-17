//
//  BluetoothManager.swift
//  SamUtilsExample
//
//  Created by 杜千煜 on 2023/3/17.
//

import Foundation
import SamUtils

class BluetoothManager: BaseBluetoothManager {
    
    static let shared = BluetoothManager()
    
    private override init() {
        super.init()
        
        setUUID(serviceUUID: "", notifyUUID: "", writeUUID: "")
        self.delegate = self
    }
    
    func setTime() {
        let timeData = [0x02].map { UInt8($0) }
        let data = Data(bytes: timeData, count: timeData.count)
        sendData(data, with: .withoutResponse)
    }
    
}

extension BluetoothManager: BaseBluetoothDelegate {
    func isConnected(_ isConnected: Bool) {
        
    }
    
    func receiveData(_ data: Data?) {
        
    }
}
