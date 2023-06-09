//
//  UIViewControllerExtension.swift
//  SamUtils
//
//  Created by Qian-Yu Du on 2023/3/10.
//

import UIKit

public extension UIViewController {
    /// Instantiates and returns the view controller from Storyboard with storyboard name. default name is "Main".
    ///
    /// **Note**, The storyboard identifier should be the class name.
    static func fromStoryboard(storyboardName: String = "Main") -> Self {
        let id = String(describing: self)
        return fromStoryboardHelper(storyboardName: storyboardName, storyboardId: id)
    }
    
    fileprivate class func fromStoryboardHelper<T>(storyboardName: String, storyboardId: String) -> T {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: storyboardId) as! T
        return controller
    }
    
    /// Show next ViewController
    /// - Parameters:
    ///   - vc: ViewController need to show.
    ///   - transition: Transition type.
    func push(vc: UIViewController, transition: CATransition? = nil) {
        if let transition = transition {
            self.navigationController?.view.layer.add(transition, forKey: "kCATransition")
            self.navigationController?.pushViewController(vc, animated: false)
        } else {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /// Back to previous ViewController
    /// - Parameter toRoot: if true, back to root ViewController.
    @objc func pop(toRoot: Bool = false) {
        if toRoot {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    /// Hide Navigation Bar
    /// - Parameter isHidden: if true, will hidden navigation bar.
    func hideNavigationBar(_ isHidden: Bool) {
        self.navigationController?.setNavigationBarHidden(isHidden, animated: true)
    }
    
    /// Set Navigation back button.
    /// - Parameters:
    ///   - title: Back button title.
    ///   - titleColor: Navigation bar title color.
    ///   - navigationColor: Navigation bar color
    ///   - backImage: Back button image.
    func setBackButton(title: String,
                       backImage: UIImage? = nil) {
        
        self.title = title
        if backImage != nil {
            let back = UIBarButtonItem(image: backImage, style: .plain, target: self, action: nil)
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = back
        } else {
            if #available(iOS 14.0, *) {
                self.navigationController?.navigationBar.topItem?.backButtonDisplayMode = .minimal
            } else {
                let back = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
                self.navigationController?.navigationBar.topItem?.backBarButtonItem = back
            }
        }
    }
    
    func setNavigationColor(titleColor: UIColor? = nil, navigationColor: UIColor = .white) {
        
        if #available(iOS 15, *) {
            let standard = UINavigationBarAppearance()
            standard.configureWithOpaqueBackground()
            standard.backgroundColor = navigationColor
            
            if navigationColor.isLight {
                standard.titleTextAttributes = [.foregroundColor: UIColor.black]
                self.navigationController?.navigationBar.tintColor = .black
            } else {
                standard.titleTextAttributes = [.foregroundColor: UIColor.white]
                self.navigationController?.navigationBar.tintColor = .white
            }
            
            if titleColor != nil {
                standard.titleTextAttributes = [.foregroundColor: titleColor!]
                self.navigationController?.navigationBar.tintColor = titleColor
            }
            
            self.navigationController?.navigationBar.standardAppearance = standard
            self.navigationController?.navigationBar.scrollEdgeAppearance = standard
            
        } else {
            self.navigationController?.navigationBar.barTintColor = navigationColor
            
            if navigationColor.isLight {
                self.navigationController?.navigationBar.tintColor = .black
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            } else {
                self.navigationController?.navigationBar.tintColor = .white
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            }
            
            if titleColor != nil {
                self.navigationController?.navigationBar.tintColor = titleColor
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor!]
            }
        }
    }
}

