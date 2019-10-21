//
//  Token.swift
//  HelpieModels
//
//  Created by Rubens Machion on 04/12/17.
//  Copyright © 2017 Rubens Machion. All rights reserved.
//

import ObjectMapper

public class Token : Mappable {
    
    public var uid: String?
    public var clientip: String?
    public var expiresdate: String?
    public var issueddate: String?
    public var refreshtoken: String?
    public var token: String?
    public var userdeviceid: String?
    
    public init () {
        
    }
   
    required public convenience init?(map: Map) {
        
        self.init()
        self.mapping(map: map)
    }
    
    public func mapping(map: Map) {
        
        uid <- map["uid"]
        clientip <- map["clientip"]
        expiresdate <- map["expiresdate"]
        issueddate <- map["issueddate"]
        refreshtoken <- map["refreshtoken"]
        token <- map["token"]
        userdeviceid <- map["userdeviceid"]
    }
}

// MARK: - TokenProtocol
extension Token: TokenProtocol {
    
    public func save() {
        
        let jsonString = self.toJSON()
        
        let defaults = UserDefaults.standard
        defaults.set(jsonString, forKey: "token")
        defaults.synchronize()
    }
    
    public func get() -> TokenProtocol? {
        
        let defaults = UserDefaults.standard
        
        if let saved = defaults.object(forKey: "token") as? [String : Any] {
            
            let t: Token = Token()
            
            t.mapping(map:  Map(mappingType: MappingType.fromJSON, JSON: saved))
            return t
        } else {
            
            return nil
        }
    }
    
    public func deleteTokenLocalData() {
        
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: "token")
        defaults.synchronize()
    }
    
    public func toJSON2() -> [String : Any] {
        
        return self.toJSON()
    }
}
