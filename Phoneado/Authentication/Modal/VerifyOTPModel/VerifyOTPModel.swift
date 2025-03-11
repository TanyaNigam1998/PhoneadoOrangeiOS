//
//  VerifyOTPModel.swift
//  Phoneado
//
//  Created by Zimble on 4/13/22.
//

import Foundation

// MARK: - VerifyOTPModel
class VerifyOTPModel: Codable {
    var statusCode: Int?
    var message: String?
    var data: VerifyOTPData?
    
    init(statusCode: Int?, message: String?, data: VerifyOTPData?) {
        self.statusCode = statusCode
        self.message = message
        self.data = data
    }
    
}

// MARK: - DataClass
class VerifyOTPData: Codable {
    var token: Int?
    var type: String?

    init(token: Int?, type: String?) {
        self.token = token
        self.type = type
    }
}




class VerifyOTPDataClass: NSObject,NSCoding {
    var token: Int?
    var type: String?

    init(token: Int?, type: String?) {
        self.token = token
        self.type = type
    }
    
    @objc required init(coder aDecoder: NSCoder)
    {
        token = aDecoder.decodeObject(forKey: "token") as? Int
        type = aDecoder.decodeObject(forKey: "type") as? String
    }
    
    @objc func encode(with aCoder: NSCoder)
    {
         if token != nil {
           aCoder.encode(token, forKey: "token")
         }
         if type != nil {
           aCoder.encode(type, forKey: "type")
         }
    }
    
}
