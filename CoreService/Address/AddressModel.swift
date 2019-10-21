//
//  AddressModel.swift
//  CoreService
//
//  Created by Rubens Machion on 15/12/17.
//  Copyright © 2017 Rubens Machion. All rights reserved.
//

import Foundation
import ObjectMapper

open class AddressModel : Mappable {
    
    public var zipcode: String!
    public var street: String!
    public var neighborhood: String!
    public var city: String!
    public var state: String!
    
    public init () {
        
    }
    
    public init(zipcode: String!, street: String!, neighborhood: String!, city: String!, state: String!) {
        
        self.zipcode = zipcode
        self.street = street
        self.neighborhood = neighborhood
        self.city = city
        self.state = state
    }
    
    required public init?(map: Map) { }
    
    public func mapping(map: Map) {
        
        zipcode <- map["zipcode"]
        street <- map["street"]
        neighborhood <- map["neighborhood"]
        city <- map["city"]
        state <- map["state"]
    }
}
