//
//  UIntExtension.swift
//  SamUtils
//
//  Created by Qian-Yu Du on 2023/3/14.
//

import Foundation

public enum Bit: UInt8, CustomStringConvertible {
    case zero, one
    
    public var description: String {
        switch self {
        case .one:
            return "1"
        case .zero:
            return "0"
        }
    }
}

public extension UInt8 {
    /// Get bits from UInt8
    ///
    ///     let byte: UInt8 = 0x01
    ///     let bits = byte.bits()
    ///     // bits = [0, 0, 0, 1, 1, 1, 1, 1]
    ///
    func bits() -> [Bit] {
        var byte = self
        var bits = [Bit](repeating: .zero, count: 8)
        for i in 0..<8 {
            let currentBit = byte & 0x01
            if currentBit != 0 {
                bits[i] = .one
            }
            
            byte >>= 1
        }
        
        return bits.reversed()
    }
}
