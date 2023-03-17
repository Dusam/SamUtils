//
//  ResultModel.swift
//  SamUtils
//
//  Created by Qian-Yu Du on 2023/3/10.
//

import Foundation

public struct ResponseErrorModel: Codable, CustomDebugStringConvertible {
    let result: String
    
    public var debugDescription: String {
        return "responseError: \(result)"
    }
}
