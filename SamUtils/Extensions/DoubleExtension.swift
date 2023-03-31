//
//  DoubleExtension.swift
//  MoneyManager
//
//  Created by 杜千煜 on 2022/10/28.
//

import Foundation

public extension Double {
    var clearZero : String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.1f", self)
    }
}
