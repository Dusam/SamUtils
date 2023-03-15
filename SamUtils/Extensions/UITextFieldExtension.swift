//
//  UITextFieldExtension.swift
//  SamUtils
//
//  Created by Qian-Yu Du on 2023/3/10.
//

import Foundation
import UIKit

public extension UITextField {
    
    @available(iOS 13.0, *)
    fileprivate func setPasswordToggleImage(_ button: UIButton) {
        if (isSecureTextEntry) {
            button.setImage(UIImage(systemName: "eye"), for: .normal)
        } else {
            button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }
    }
    
    /// Enable password button in TextField
    ///
    ///     let textField = UITextField()
    ///     textField.enablePasswordToggle(buttonColor: .blue)
    ///
    /// - Parameter buttonColor: Button tint color.
    @available(iOS 13.0, *)
    func enablePasswordToggle(buttonColor: UIColor){
        let button = UIButton(type: .custom)
        setPasswordToggleImage(button)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.frame = CGRect(x: self.frame.size.width - 25, y: 5, width: 25, height: 25)
        button.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
        button.tintColor = buttonColor
        self.rightView = button
        self.rightViewMode = .always
    }
    
    @available(iOS 13.0, *)
    @objc fileprivate func togglePasswordView(_ sender: Any) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        setPasswordToggleImage(sender as! UIButton)
    }
}
