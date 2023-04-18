//
//  UserDefaultsExtension.swift
//  MoneyManager
//
//  Created by 杜千煜 on 2022/10/24.
//

import Foundation

public extension UserDefaults {
    static func isFirstLaunch() -> Bool {
        let hasBeenLaunched = "hasBeenLaunched"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunched)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: hasBeenLaunched)
        }
        return isFirstLaunch
    }
    
    static func isFirstLaunchOfNewVersion() -> Bool {
        // 版本號
        let infoDictionary = Bundle.main.infoDictionary!
        let majorVersion = infoDictionary["CFBundleShortVersionString"] as! String
        
        // 上次啟動的版本號
        let hasBeenLaunchedOfNewVersion = "hasBeenLaunchedOfNewVersion"
        let lastLaunchVersion = UserDefaults.standard.string(forKey: hasBeenLaunchedOfNewVersion)
        
        // 比較版本號
        let isFirstLaunchOfNewVersion = majorVersion != lastLaunchVersion
        if isFirstLaunchOfNewVersion {
            UserDefaults.standard.set(majorVersion, forKey: hasBeenLaunchedOfNewVersion)
        }
        return isFirstLaunchOfNewVersion
    }
}
