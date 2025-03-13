//
//  API.swift
//  SamUtils
//
//  Created by Qian-Yu Du on 2023/3/10.
//

import Foundation
import Alamofire


public typealias apiCompletionHandler = (_ statusCode: Int?, _ dataModel: Any?) -> Void
/// Base API
///
/// Recommended to use inheritance.
open class BaseAPI: NSObject {
    private let TAG = "BaseAPI"
    private var statusCode: Int? = 404
    private var sharedSession: Session
    
    public override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30  // 單次請求的超時時間
        configuration.timeoutIntervalForResource = 30 // 整個資源請求的超時時間
        sharedSession = Session(configuration: configuration)
        
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
                                        completionHandler: @escaping apiCompletionHandler) {
        
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
    
    /// **使用 async/await 發送請求**
    ///
    /// - Parameters:
    ///   - url: API URL
    ///   - method: HTTP 方法 (預設: `.get`)
    ///   - parameters: API 參數 (可選)
    ///   - encoding: 參數編碼方式 (預設: `.json`)
    ///   - headers: HTTP Headers (可選)
    /// - Returns: **解碼後的 `T` 模型**
    /// - Throws: **發生錯誤時拋出 `Error`**
    public func sendRequest<T: Codable>(
        url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        do {
            let response = try await sharedSession.request(url,
                                                           method: method,
                                                           parameters: parameters,
                                                           encoding: encoding,
                                                           headers: headers)
                .validate { request, response, data in
                    if (200...299).contains(response.statusCode) {
                        return .success(())
                    } else if response.statusCode == 401 {
                        return .failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 401)))
                    } else {
                        return .failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: response.statusCode)))
                    }
                }
                .serializingDecodable(T.self)
                .value
            
            #if DEBUG
            print("============ \(TAG) RESPONSE SUCCESS ============")
            print(response)
            #endif
            
            return response
            
        } catch {
            #if DEBUG
            print("============ \(TAG) RESPONSE FAILED ============")
            print("Error: \(error.localizedDescription)")
            #endif
            throw error
        }
    }
}
