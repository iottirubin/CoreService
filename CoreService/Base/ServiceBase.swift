//
//  ServiceBase.swift
//  For1
//
//  Created by Rubens Machion on 02/11/17.
//  Copyright © 2017 Rubens Machion. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

public class ResultModel: Mappable {
    
    public var result: Bool = false
    
    public init() {
        
    }
    
    required public convenience init?(map: Map) {
        
        self.init()
        self.mapping(map: map)
    }
    
    public func mapping(map: Map) {
        
        result <- map["result"]
    }
}

open class ServiceBase<T: Mappable> : NSObject {
    
    public let sessionManager = Alamofire.SessionManager.default
    
    // MARK: - Public
    open func connectGetObject(route: String!, parameters: Parameters? = nil, completion: @escaping (T?, String?, ServiceBaseErrorModel?) -> ()) {
        
        self.connectObject(route: route, parameters: parameters, method: .get, encoding: JSONEncoding.default, headers: nil, completion: completion)
    }
    
    open func connectGetObject(route: String!, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, completion: @escaping (T?, String?, ServiceBaseErrorModel?) -> ()) {
        
        self.connectObject(route: route, parameters: parameters, method: .get, encoding: encoding, headers: nil, completion: completion)
    }
    
    open func connectGetArray(route: String!, parameters: Parameters? = nil, completion: @escaping (Array<T>?, String?, ServiceBaseErrorModel?) -> ()) {
        
        self.connectArray(route: route, parameters: parameters, completion: completion)
    }

    open func connectGetArray(route: String!, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, completion: @escaping (Array<T>?, String?, ServiceBaseErrorModel?) -> ()) {

        self.connectArray(route: route, parameters: parameters, method: .get, encoding: encoding, headers: nil, completion: completion)
    }

    open func connectDelete(route: String!, parameters: Parameters? = nil, completion: @escaping (T?, String?, ServiceBaseErrorModel?) -> ()) {
        
        self.connectObject(route: route, parameters: parameters, method: .delete, encoding: JSONEncoding.default, headers: nil, completion: completion)
    }
    
    open func connectPutObject(route: String!, parameters: Parameters? = nil, headers: HTTPHeaders? = nil, completion: @escaping (T?, String?, ServiceBaseErrorModel?) -> ()) {
        
        self.connectObject(route: route, parameters: parameters, method: .put, encoding: JSONEncoding.default, headers: headers, completion: completion)
    }
    
    open func connectPutArray(route: String!, parameters: Parameters? = nil, headers: HTTPHeaders? = nil, completion: @escaping (Array<T>?, String?, ServiceBaseErrorModel?) -> ()) {
        
        assertionFailure("Missing implementation \(#function)")
    }
    
    open func connectPostObject(route: String!, parameters: Parameters? = nil, headers: HTTPHeaders? = nil, completion: @escaping (T?, String?, ServiceBaseErrorModel?) -> ()) {
        
        self.connectObject(route: route, parameters: parameters, method: .post, encoding: JSONEncoding.default, headers: headers, completion: completion)
    }
    
    open func connectPostArray(route: String!, parameters: Parameters? = nil, headers: HTTPHeaders? = nil, completion: @escaping (Array<T>?, String?, ServiceBaseErrorModel?) -> ()) {
        
        self.connectArray(route: route, parameters: parameters, method: .post, encoding: JSONEncoding.default, headers: headers, completion: completion)
    }
    
    open func uploadFile(route: String!, data: Data, method: HTTPMethod = .put, headers: HTTPHeaders? = nil, completion: @escaping (String?, String?, ServiceBaseErrorModel?) -> ()) {
        
        DispatchQueue.main.async {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        Alamofire.upload(data, to: route, method: method)
            .logRequest(.verbose)
            .logResponse(.verbose)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                
                DispatchQueue.main.async {
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                debugPrint(response)
                if response.result.isSuccess {
                    
                    completion(response.result.value as? String, route, nil)
                } else {
                    
                    let error = self.buildError(response.data, statusCode: (response.response?.statusCode)!)
                    completion(nil, route, error)
                }
                
                
                //            completion(true)
        }
    }
    
    open func connectJSONObject(route: String!,
                                 parameters: Parameters? = nil,
                                 method: HTTPMethod = .get,
                                 headers: HTTPHeaders? = nil,
                                 oauth: OAuth2Handler? = nil,
                                 completion: @escaping ([String : Any]?, String?, ServiceBaseErrorModel?) -> ()) {
        
        DispatchQueue.main.async {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let s = sessionManager
        s.adapter = oauth
        s.retrier = oauth
        
        s.request(route,
                  method: method,
                  parameters: parameters,
                  encoding: JSONEncoding.default,
                  headers: headers)
            .logRequest(.verbose)
            .logResponse(.verbose)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"]).responseJSON { response in
                
                if let json = response.result.value {
                    let j = json as! [String : Any]
                    if let response = j["response"] {
                        print(response)
                        completion(response as? [String : Any], route, nil)
                    } else {
                        
                        completion(j, route, nil)
                    }
                } else {
                    
                    let e = self.buildError(response.result.error)
                    completion(nil, route, e)
                }
                
                DispatchQueue.main.async {
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
        }
    }
    
    open func connectJSONArray(route: String!,
                               parameters: Parameters? = nil,
                               method: HTTPMethod = .get,
                               headers: HTTPHeaders? = nil,
                               oauth: OAuth2Handler? = nil,
                               encoding: ParameterEncoding? = JSONEncoding.default,
                               completion: @escaping ([[String : Any]]?, String?, ServiceBaseErrorModel?) -> ()) {
        
        DispatchQueue.main.async {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let s = sessionManager
        s.adapter = oauth
        s.retrier = oauth
        
        s.request(route,
                  method: method,
                  parameters: parameters,
                  encoding: encoding!,
                  headers: headers)
            .logRequest(.verbose)
            .logResponse(.verbose)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"]).responseJSON { response in
                
                DispatchQueue.main.async {
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                if let json = response.result.value {

                    if let j = json as? [String : Any] {

                        if let resp = j["response"] {

                            if resp is [[String : Any]] {
                                let array = resp as! [[String : Any]]

                                completion(array, route, nil)
                            } else {
                                let e = ServiceBaseErrorModel(statusCode: 0, errorCode: 0, message: (response.result.value! as! NSDictionary).object(forKey: "message") as! String)

                                completion(nil, route, e)
                            }
                        }
                    } else {

                        if json is [[String : Any]] {
                            let j = json as! [[String : Any]]
                            //                    print(j["response"]!)
                            //                        print("JSON: \(json)") // serialized json response

                            completion(j, route, nil)
                        } else {
                            if let rs = response.result.value as? Bool, rs == true {
                                
                                completion([["response" : rs]], route, nil)
                            } else {
                                let e = ServiceBaseErrorModel(statusCode: 0, errorCode: 0, message: (response.result.value! as! NSDictionary).object(forKey: "message") as! String)
                                
                                completion(nil, route, e)
                            }
                        }
                    }
                    
                } else {
                    
                    completion(nil, route, ServiceBaseErrorModel(error: response.result.error! as NSError))
                }
                
                //UIApplication.shared.isNetworkActivityIndicatorVisible = false

        }
    }
    
//    open func connectJSONArray(route: String!,
//                      parameters: Parameters? = nil,
//                      method: HTTPMethod = .get,
//                      headers: HTTPHeaders? = nil,
//                      encoding: ParameterEncoding? = JSONEncoding.default,
//                      completion: @escaping ([[String : Any]]?, String?, ServiceBaseErrorModel?) -> ()) {
//
//        Alamofire.request(route,
//                          method: method,
//                          parameters: parameters,
//                          encoding: encoding!,
//                          headers: headers)
//            .logRequest(.verbose)
//            .logResponse(.verbose)
//            .validate(contentType: ["application/json"]).responseJSON { response in
//
//                if let json = response.result.value {
//                    if json is [[String : Any]] {
//                        let j = json as! [[String : Any]]
//                        //                    print(j["response"]!)
////                        print("JSON: \(json)") // serialized json response
//
//                        completion(j, route, nil)
//                    } else {
//                        let e = ServiceBaseErrorModel(statusCode: 0, errorCode: 0, message: (response.result.value! as! NSDictionary).object(forKey: "message") as! String)
//
//                        completion(nil, route, e)
//                    }
//
//                } else {
//
//                    completion(nil, route, ServiceBaseErrorModel(error: response.result.error! as NSError))
//                }
//
//                //UIApplication.shared.isNetworkActivityIndicatorVisible = false
//        }
//    }
    
    public func createCommandParameter(command: String!, params: Parameters) -> Parameters {
        
        let p: Parameters = [
            "command" : command,
            "param" : params
        ]

        return p
    }
    
    public func cancel() {
        
        self.sessionManager.session.invalidateAndCancel()
    }
    
    // MARK: - Private
    
    private func connectArray(route: String!,
                              parameters: Parameters? = nil,
                              method: HTTPMethod = .get,
                              encoding: ParameterEncoding = JSONEncoding.default,
                              headers: HTTPHeaders? = nil,
                              completion: @escaping (Array<T>?, String?, ServiceBaseErrorModel?) -> ()) {
        
        DispatchQueue.main.async {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        Alamofire.request(route,
                          method: method,
                          parameters: parameters,
                          encoding: encoding,
                          headers: headers)
            .logRequest(.verbose)
            .logResponse(.verbose)
            .validate(contentType: ["application/json"]).responseArray { (response: DataResponse<[T]>) -> Void in
                
                DispatchQueue.main.async {
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                print(response)
                
                if response.result.isSuccess {
                
                    completion(response.result.value!, route, nil)
                } else {
                    
                    let error = self.buildError(dataResponse: response)
//                    let error = self.buildError(response.data, statusCode: (response.response?.statusCode)!)
                    
                    completion(nil, route, error)
                }
        }
    }
    
    private func connectObject(route: String!,
                         parameters: Parameters? = nil,
                         method: HTTPMethod = .get,
                         encoding: ParameterEncoding = JSONEncoding.default,
                         headers: HTTPHeaders? = nil,
                         completion: @escaping (T?, String?, ServiceBaseErrorModel?) -> ()) {
        
        DispatchQueue.main.async {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        Alamofire.request(route,
                          method: method,
                          parameters: parameters,
                          encoding: encoding,
                          headers: headers)
            .logRequest(.verbose)
            .logResponse(.verbose)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"]).responseObject { (response: DataResponse<T>) -> Void in
                
                DispatchQueue.main.async {
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                switch response.result {
                    
                case .success:
                    
                    completion(response.result.value!, route, nil)
                    break
                    
                case .failure:
                    
                    let error = self.buildError(dataResponse: response)
                    if let r = response.response {
                        error?.statusCode = r.statusCode
                    } else {
                        error?.statusCode = -1
                    }
                    
                    completion(nil, route, error)
                    
                    break
                }
        }
    }
    
    // MARK: - Error
    
    private func buildError(dataResponse: DataResponse<[T]>?) -> ServiceBaseErrorModel? {
        
        if let response = dataResponse?.response {
            
            return self.buildError(dataResponse?.data, statusCode: response.statusCode)
        } else {
            
            if let result = dataResponse?.result {
                
                if result.error != nil {
                    return ServiceBaseErrorModel(error: (result.error! as NSError))
                } else {
                    return self.buildError(nil, statusCode: -1)
                }
            } else {
                return self.buildError(nil, statusCode: -1)
            }
        }
    }
    
    private func buildError(dataResponse: DataResponse<T>?) -> ServiceBaseErrorModel? {
        
        if let response = dataResponse?.response {
            
            return self.buildError(dataResponse?.data, statusCode: response.statusCode)
        } else {
            
            if let result = dataResponse?.result {
                
                if result.error != nil {
                    return ServiceBaseErrorModel(error: (result.error! as NSError))
                } else {
                    return self.buildError(nil, statusCode: -1)
                }
            } else {
                return self.buildError(nil, statusCode: -1)
            }
        }
    }
    
    private func buildError(_ error: Error?) -> ServiceBaseErrorModel {
        
        return ServiceBaseErrorModel(error: error! as NSError)
    }
    
    private func buildError(_ error: Data?, statusCode: Int) -> ServiceBaseErrorModel {
        
        if let _ = error, let errString = String(data: error!, encoding: .utf8) {
            
            if let err = ServiceBaseErrorModel(JSONString: errString) {

                return err
            } else {

                return ServiceBaseErrorModel()
            }

        } else {
            
            let err = ServiceBaseErrorModel(statusCode: statusCode, errorCode: -1, message: "UNKOWN")
            
            return err
        }
    }
    
    // MARK: -
}
