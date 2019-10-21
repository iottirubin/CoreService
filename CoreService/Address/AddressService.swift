//
//  AddressService.swift
//  CoreService
//
//  Created by Rubens Machion on 15/12/17.
//  Copyright © 2017 Rubens Machion. All rights reserved.
//

import Foundation

public struct AddressServiceConst {
    
    static let URL_PATH_ZIP_CODE = "https://api.pagar.me/1/zipcodes/"
//    static let URL_PATH = (Bundle.main.object(forInfoDictionaryKey: "For1") as! NSDictionary).object(forKey: "endpoint") as! String
}

open class AddressService: ServiceBase<AddressModel> {
    
    public func getSearchZipCode(_ zipCode: String!, completion: @escaping (AddressModel?, String?, ServiceBaseErrorModel?) -> ()) {
        
        let p = "\(AddressServiceConst.URL_PATH_ZIP_CODE)\(zipCode!)"
//        let p = "\(AddressServiceConst.URL_PATH)/utils/location/zipcode/\(zipCode!)"
//        let path = "https://api-dev.for1.com.br/1/location/zipcode/\(zipCode!)"
        
        self.connectGetObject(route: p, completion: { (address, route, error) -> Void in
            
            completion(address, route, error)
        })
    }
}
