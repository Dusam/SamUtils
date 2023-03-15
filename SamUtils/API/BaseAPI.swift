//
//  API.swift
//  SamUtils
//
//  Created by Qian-Yu Du on 2023/3/10.
//

import Foundation
import Alamofire

/// Base API Method
///
/// Recommended to use inheritance.
open class BaseAPI: NSObject {
    private let TAG = "BaseAPI"
    private var statusCode: Int? = 404
    private var sharedSession: Session = Alamofire.Session.default
    
    public override init() {
        super.init()
    }
    
    /// Send request method
    ///
    ///     // if response failed
    ///     let errorData = ResponseErrorModel(result: errorMessage)
    ///     completionHandler(statusCode, errorData)
    ///
    /// - Parameters:
    ///   - url: Url string
    ///   - method: Http method
    ///   - parameters: Send to api's parameter
    ///   - encoding: Parameter Encoding
    ///   - headers: HTTP Headers
    ///   - model: Model(Codable) to return
    ///   - completionHandler: Completion Handler.
    public func sendRequest<T: Codable>(url: String,
                                        method: HTTPMethod = .get,
                                        parameters: Parameters? = nil,
                                        encoding: ParameterEncoding = JSONEncoding.default,
                                        headers: HTTPHeaders? = nil,
                                        model: T.Type,
                                        completionHandler: @escaping (_ statusCode: Int?, _ dataModel: Any?) -> Void) {
        
        sharedSession.request(url,
                              method: method,
                              parameters: parameters,
                              encoding: encoding,
                              headers: headers)
        .responseDecodable(of: T.self) { [unowned self] (dataResponse) in
            statusCode = dataResponse.response?.statusCode
          
            switch dataResponse.result {
            case .success(let result):
                completionHandler(statusCode, result)
                
                #if DEBUG
                print("============ \(TAG) RESPONSE SUCCESS ============")
                print("statusCode : \(statusCode ?? 9999)")
                print(result)
                #endif
                
            case .failure(let result):
                if dataResponse.error == nil {
                    let errorData = ResponseErrorModel(result: "Data decode failed")
                    completionHandler(statusCode, errorData)
                } else {
                    let errorData = ResponseErrorModel(result: "\(dataResponse.error!.localizedDescription)")
                    completionHandler(statusCode, errorData)
                }
                
                #if DEBUG
                print("============ \(TAG) RESPONSE FAILED============")
                print("statusCode : \(statusCode ?? 9999)")
                print(result)
                #endif
                
            }
            
        }
        
    }
}
