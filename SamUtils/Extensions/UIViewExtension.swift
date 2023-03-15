//
//  UIViewExtension.swift
//  SamUtils
//
//  Created by Qian-Yu Du on 2023/3/14.
//

import UIKit

public extension UIView {
    /// Add board to View.
    ///
    ///     UIView().addBoard(.top, .blue, 1)
    func addBoard(_ edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        guard edge != .all else {
            self.layer.borderColor = color.cgColor
            self.layer.borderWidth = thickness
            return
        }
        
        let border = UIView()
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(border)
        
        var firstLayout: NSLayoutConstraint.Attribute = .height
        var secondLayout: NSLayoutConstraint.Attribute = .top
        var thirdLayout: NSLayoutConstraint.Attribute = .leading
        var fourthLayout: NSLayoutConstraint.Attribute = .trailing
        
        switch edge {
        case UIRectEdge.top: ///上
            border.tag = 9999990
            firstLayout = .height
            secondLayout = .top
            thirdLayout = .leading
            fourthLayout = .trailing
            break
        case UIRectEdge.bottom: ///下
            border.tag = 9999991
            firstLayout = .height
            secondLayout = .bottom
            thirdLayout = .leading
            fourthLayout = .trailing
            break
        case UIRectEdge.right: ///右
            border.tag = 9999992
            firstLayout = .width
            secondLayout = .trailing
            thirdLayout = .bottom
            fourthLayout = .top
            break
        case UIRectEdge.left: ///左
            border.tag = 9999993
            firstLayout = .width
            secondLayout = .leading
            thirdLayout = .bottom
            fourthLayout = .top
            break
        default:
            break
        }
        
        border.addConstraint(NSLayoutConstraint(item: border,
                                                attribute: firstLayout,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .notAnAttribute,
                                                multiplier: 1, constant: thickness))
        self.addConstraint(NSLayoutConstraint(item: border,
                                              attribute: secondLayout,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: secondLayout,
                                              multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: border,
                                              attribute: thirdLayout,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: thirdLayout,
                                              multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: border,
                                              attribute: fourthLayout,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: fourthLayout,
                                              multiplier: 1, constant: 0))
    }
    
    /// Get Image from UIView.
    ///
    ///     UIView().asImage()
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in layer.render(in: rendererContext.cgContext) }
    }
    
    /// Get UIView from Xib file.
    ///
    /// **Note**, The Xib name should be the class name.
    static func xib() -> Self? {
        let name = String(describing: self)
        return fromXibHelper(name)
    }
    
    private class func fromXibHelper<T>(_ name: String) -> T? {
        guard let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?[0] else { return nil }
        guard let value = view as? T else { return nil }
        return value
    }
}
