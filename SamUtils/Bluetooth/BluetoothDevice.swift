//
//  BluetoothDevice.swift
//  SamUtils
//
//  Created by 杜千煜 on 2023/3/17.
//

import Foundation

public struct BluetoothDevice: CustomDebugStringConvertible {
    
    var deviceName: String
    var deviceUUID: String
    
    public var debugDescription: String {
        return "deviceName: \(deviceName), deviceUUID: \(deviceUUID)"
    }
}
