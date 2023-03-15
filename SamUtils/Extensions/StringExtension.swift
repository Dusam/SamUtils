//
//  StringExtension.swift
//  SamUtils
//
//  Created by Qian-Yu Du on 2023/3/14.
//

import UIKit

public extension String {
    
    /// Split string
    ///
    ///     let text = "Hello World!"
    ///     let subString = text.substring(0, 5)
    ///     // subString = "Hello"
    func substring(_ start: Int, _ end: Int) -> String {
        return (self as NSString).substring(with: NSMakeRange(start, end - start))
    }
    
    /// Replace string with regular.
    func replaceWithRegular(pattern: String, with: String, options: NSRegularExpression.Options = []) -> String {
        let regex = try? NSRegularExpression(pattern: pattern, options: options)
        return regex?.stringByReplacingMatches(in: self, options: [],
                                               range: NSMakeRange(0, self.count),
                                               withTemplate: with) ?? ""
    }
    
    /// Convert String to Date
    ///
    ///     let dateString = "2023-03-14"
    ///     let date = dateString.toDate() // default format = "yyyy-MM-dd"
    func toDate(withFormat format: String = "yyyy-MM-dd") -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        guard let date = dateFormatter.date(from: self) else { return Date() }
        
        return date
    }
    
    /// Get Age from birthday.
    func getAge() -> Int {
        let date = self.toDate()
        let calendar = Calendar.current
        
        let ageComponents = calendar.dateComponents([.year, .month, .day], from: date, to: Date())
        
        return ageComponents.year!
    }
    
    /// Hex to Int
    func hexToInt() -> Int {
        if let int = Int(self, radix: 16) {
            return int
        }
        return 0
    }
    
    /// Validate Id number.
    func validateIdNumberFormat() -> Bool {
        func validateFormat(str: String) -> Bool {
            let regex: String = "^[A-Z]{1}[1-2]{1}[0-9]{8}$"
            let predicate: NSPredicate = NSPredicate(format: "SELF MATCHES[c] %@", regex)
            return predicate.evaluate(with: str)
        }
        
        if validateFormat(str: self) {
            
            let cityAlphabets: [String:Int] = [
                "A":10, "B":11, "C":12, "D":13, "E":14, "F":15, "G":16, "H":17, "I":34, "J":18, "K":19,
                "M":21, "N":22, "O":35, "P":23, "Q":24, "T":27, "U":28, "V":29, "W":32, "X":30, "Z":33,
                "L":20, "R":25, "S":26, "Y":31
            ]
            
            /// 把 [Character] 轉換成 [Int] 型態
            let ints = self.compactMap{ Int(String($0)) }
            
            /// 拿取身分證第一位英文字母所對應當前城市的
            guard let key = self.first,
                let cityNumber = cityAlphabets[String(key)] else {
                    return false
            }
            
            /// 經過公式計算出來的總和
            let firstNumberConvert = (cityNumber / 10) + ((cityNumber % 10) * 9)
            let section1 = (ints[0] * 8) + (ints[1] * 7) + (ints[2] * 6)
            let section2 = (ints[3] * 5) + (ints[4] * 4) + (ints[5] * 3)
            let section3 = (ints[6] * 2) + (ints[7] * 1) + (ints[8] * 1)
            let total = firstNumberConvert + section1 + section2 + section3
            
            /// 總和如果除以10是正確的那就是真的
            if total % 10 == 0 { return true }
        }
        
        return false
    }
}
