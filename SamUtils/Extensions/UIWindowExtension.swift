//
//  UIWindowExtension.swift
//  SamUtils
//
//  Created by Qian-Yu Du on 2023/3/14.
//

import UIKit

public extension UIWindow {
    
    /// Get top Viewcontroller
    var visibleViewController: UIViewController? {
        return self.topViewController()
    }
    
    private func topViewController(controller: UIViewController? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController) -> UIViewController? {
        // Navigation
        if let navigationCroller = controller as? UINavigationController {
            return topViewController(controller: navigationCroller.visibleViewController)
        }
        
        // Tab
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        // Present
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
}
