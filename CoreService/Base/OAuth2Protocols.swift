//
//  OAuth2Protocols.swift
//  CoreService
//
//  Created by Rubens Machion on 28/01/18.
//  Copyright © 2018 Rubens Machion. All rights reserved.
//

import Foundation



public protocol TokenProtocol {
    
    var refreshtoken: String? { get set }
    var clientip: String? { get set }
    var token: String? { get set }
    
//    init(_ JSON: [String : Any])
    
    func save()
    
    func get() -> TokenProtocol?
    
    func deleteTokenLocalData()
    
    func toJSON2() -> [String : Any]
}
