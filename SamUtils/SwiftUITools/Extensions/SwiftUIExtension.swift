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

@available(iOS 14.0, *)
extension Color {
    var isLight: Bool {
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        UIColor(self).getWhite(&brightness, alpha: &alpha)
        
        return brightness > 0.6 ? true : false
    }
    
    var uiColor: UIColor {
        return UIColor(self)
    }
}

// MARK: Binding
@available(iOS, introduced: 13.0)
extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}
