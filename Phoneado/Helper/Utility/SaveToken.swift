//
//  SaveToken.swift
//  Cloud Seat
//
//  Created by Ishan Grover on 22/11/19.
//  Copyright © 2019 CYL8R. All rights reserved.
//

import Foundation

class SaveToken {
    private static var _OTPTOKEN:Int!
    private static var _DEVICE_TOKEN:String!
    private static var _APN_TOKEN:String!

    static var otpToken:Int?{
        get{
            return _OTPTOKEN
        }
        set{
            _OTPTOKEN = newValue
        }
    }
    static var deviceToken:String?{
        get {
            return _DEVICE_TOKEN
        }
        set{
            _DEVICE_TOKEN = newValue
        }
    }
    
    static var apnToken:String?{
        get {
            return _APN_TOKEN
        }
        set{
            _APN_TOKEN = newValue
        }
    }
    
    
    //apnToken
    
}
