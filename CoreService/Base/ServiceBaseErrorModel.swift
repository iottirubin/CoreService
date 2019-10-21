//
//  ServiceBaseErrorModel.swift
//  CoreService
//
//  Created by Rubens Machion on 19/12/17.
//  Copyright © 2017 Rubens Machion. All rights reserved.
//

import Foundation
import ObjectMapper

open class ServiceBaseErrorModel : Mappable {
    
    public var statusCode: Int = 0
    public var errorCode: Int = 0
    public var message: String!
    public var errors: [String : String]?
    
    public init () {
        
    }
    
    public init(statusCode: Int, errorCode: Int, message: String) {
        
        self.statusCode = statusCode
        self.errorCode = errorCode
        self.message = message
    }
    
    public init(error: NSError) {
        
        self.errorCode = error.code
        self.statusCode = error.code
        self.message = error.localizedDescription
    }
    
    required public init?(map: Map) {
        
        self.mapping(map: map)
    }
    
    public func errorsMessage() -> String? {
        
        if let errors = self.errors {
            var message: String = ""
            
            errors.keys.forEach{ it in
                
                message += errors[it]!
                message += "\n"
            }
            
            return message
        } else {
            
            return nil
        }
    }
    
    public func mapping(map: Map) {
        
        statusCode <- map["statusCode"]
        errorCode <- map["errorCode"]
        message <- map["message"]
        errors <- map["errors"]
    }
}
