//
//  OAuth2Handler.swift
//  CoreService
//
//  Created by Rubens Machion on 25/01/18.
//  Copyright © 2018 Rubens Machion. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

public class OAuth2Handler: RequestAdapter, RequestRetrier, Mappable {
    
    private typealias RefreshCompletion = (_ succeeded: Bool, _ newToken: TokenProtocol?) -> Void
    
    private let sessionManager: SessionManager = {
        
        return ServiceBase<OAuth2Handler>().sessionManager
//        return Alamofire.SessionManager.default
    }()
    
    private let lock = NSLock()
    
    private var token: TokenProtocol?
    private var accept: String
    private var baseURLString: String
    
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    // MARK: - Initialization
    
    public init(accept: String, baseURLString: String, token: TokenProtocol) {
        self.accept = accept
        self.baseURLString = baseURLString
        self.token = token
    }
    
    // MARK: - Mappable
    public required init?(map: Map) {
        fatalError("Don't use this \(#function)")
    }
    
    public func mapping(map: Map) {
        fatalError("Don't use this \(#function)")
    }
    
    // MARK: - RequestAdapter
    
    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(baseURLString) {
            var urlRequest = urlRequest
            if let t = self.token {
                urlRequest.setValue("Bearer " + t.token!, forHTTPHeaderField: "Authorization")
            }
            urlRequest.setValue(self.accept, forHTTPHeaderField: "Accept")
            return urlRequest
        }
        
        return urlRequest
    }
    
    // MARK: - RequestRetrier
    
    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                refreshTokens(currentToken: self.token!,
                              completion: { [weak self] succeeded, newToken in
                                guard let strongSelf = self else { return }
                                
                                strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                                
                                if let t = newToken {
                                    strongSelf.token = t
                                    strongSelf.token?.save()
                                }
                                
                                strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                                strongSelf.requestsToRetry.removeAll()
                })
            }

        } else {
            completion(false, 0.0)
        }
    }
    
    // MARK: - Private - Refresh Tokens
    private func refreshTokens(currentToken: TokenProtocol, completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        
        let urlString = baseURLString
        
        let p: Parameters = [
            "command" : "SecurityController.getTokenRefreshToken",
            "param" : currentToken.toJSON2()
        ]
        
        sessionManager.request(urlString, method: .post, parameters: p, encoding: JSONEncoding.default)
            .responseJSON { [weak self] response in
                guard let strongSelf = self else { return }
                
                if let json = response.result.value as? [String: Any] {
                    
                    if let r = json["response"] as? [String: Any] {
                        
                        completion(true, Token(JSON: r))
                    } else {
                        completion(false, nil)
                    }
                } else {
                    completion(false, nil)
                }
                
                strongSelf.isRefreshing = false
        }
    }
}
