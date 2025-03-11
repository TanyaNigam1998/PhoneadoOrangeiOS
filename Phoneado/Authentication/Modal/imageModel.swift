//
//  imageModel.swift
//  Purpleelegant Customer
//
//  Created by Zimble on 2/6/20.
//  Copyright © 2020 Zimble. All rights reserved.
//

import Foundation
class imageModel{
    
    var data : imageDict!
    var message : String!
    var statusCode : Int!

    init(fromDictionary dictionary: [String:Any]){
        if let dataData = dictionary["data"] as? [String:Any]{
            data = imageDict(fromDictionary: dataData)
        }
        message = dictionary["message"] as? String
        statusCode = dictionary["statusCode"] as? Int
    }
}

class imageDict{
    
    var url : String!
   
    init(fromDictionary dictionary: [String:Any]){
        url = dictionary["url"] as? String
    }
}
