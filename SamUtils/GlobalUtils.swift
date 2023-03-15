//
//  GlobalParameter.swift
//  SamUtils
//
//  Created by Qian-Yu Du on 2023/3/10.
//

import Foundation

public class Global: NSObject {
    /// yyyyMMddHHmmss
    public static let DateFormat = "yyyyMMddHHmmss"
    /// yyyy-MM-dd
    public static let DayFormat:String = "yyyy-MM-dd"
    /// yyyy-MM-dd HH:mm:ss
    public static let DayTimeFormat:String = "yyyy-MM-dd HH:mm:ss"
    
    /// yyyy-MM-dd'T'HH:mm:ss.SSS
    public static let ServerMsFormat:String = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    /// yyyy-MM-dd'T'HH:mm:ss
    public static let ServerFormat:String = "yyyy-MM-dd'T'HH:mm:ss"
    /// yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
    public static let ServerIso8601Fromat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    
    /// HH:mm:ss
    public static let TimeFormat:String = "HH:mm:ss"
}
