//
//  BindingExtension.swift
//  MoneyManager
//
//  Created by 杜千煜 on 2022/11/3.
//

import Foundation
import SwiftUI

public extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}
