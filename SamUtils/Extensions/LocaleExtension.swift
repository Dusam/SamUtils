//
//  LocaleExtension.swift
//  SamUtils
//
//  Created by Qian-Yu Du on 2023/3/22.
//

import UIKit

public extension Locale {
    /// Get preferred language code
    ///
    ///     let preferredLanguageCode = Locale.preferredLanguageCode
    ///     print(preferredLanguageCode) // zh
    static var preferredLanguageCode: String {
        guard let preferredLanguage = preferredLanguages.first,
              let code = Locale(identifier: preferredLanguage).languageCode else {
            return "en"
        }
        return code
    }
    
    /// Get preferred language codes
    ///
    ///     let preferredLanguageCodes = Locale.preferredLanguageCodes
    ///     print(preferredLanguageCodes) // ["zh", "en", "ja"]
    static var preferredLanguageCodes: [String] {
        return Locale.preferredLanguages.compactMap({Locale(identifier: $0).languageCode})
    }
    
    /// Get preferred language
    ///
    ///     let preferredLanguage = Locale.preferredLanguage
    ///     print(preferredLanguage) // zh-Hant
    static var preferredLanguage: String {
        guard let preLau = Locale.preferredLanguages.first else {
            return "en"
        }
        return preLau.replacingOccurrences(of: "-TW", with: "")
    }
}
