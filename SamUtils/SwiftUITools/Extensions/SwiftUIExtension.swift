//
//  SwiftUIViewExtension.swift
//  MoneyManager
//
//  Created by 杜千煜 on 2023/2/9.
//

import Foundation
import SwiftUI
import UIKit

// MARK: Color
public extension Color {
    @available(iOS 14.0, *)
    var isLight: Bool {
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        UIColor(self).getWhite(&brightness, alpha: &alpha)
        
        return brightness > 0.6 ? true : false
    }
    
    @available(iOS 14.0, *)
    var uiColor: UIColor {
        return UIColor(self)
    }
}

// MARK: Binding
public extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}
