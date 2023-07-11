//
//  UIColorExtension.swift
//  SamUtils
//
//  Created by 杜千煜 on 2023/6/20.
//

import Foundation
import UIKit

public extension UIColor {
    var isLight: Bool {
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        self.getWhite(&brightness, alpha: &alpha)
        
        return brightness > 0.5 ? true : false
    }
}
