//
//  UserDetail.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 12, 2022
//
import Foundation
import UIKit

class UserDetail:NSObject, NSCoding {
    
    var userId: String?
    var fullName: String?
    var mobile: String?
    var status: String?
    var profilePic: String?
    var lastLocation: LastLocation?
    var userType: String?
    var insertDate: Int?
    var dialCode: String?
    var userLoginType: String?
    var isLocationUpdateRequired: Bool?
    var locationUpdateTime: Double?
    var isAdmin:Bool?
    
    init(_ dict: [String: Any]) {
        
        print(dict)
        
        userId = dict["userId"] as? String
        fullName = dict["fullName"] as? String
        mobile = dict["mobile"] as? String
        status = dict["status"] as? String
        profilePic = dict["profilePic"] as? String
        dialCode = dict["dialCode"] as? String
        userLoginType = dict["userLoginType"] as? String
        lastLocation = dict["lastLocation"] as? LastLocation
        userType = dict["userType"] as? String
        insertDate = dict["insertDate"] as? Int
        isLocationUpdateRequired = dict["isLocationUpdateRequired"] as? Bool
        locationUpdateTime = dict["locationUpdateTime"] as? Double
        isAdmin = dict["isAdmin"] as? Bool

    }
    
    @objc required init(coder aDecoder: NSCoder)
    {
        userId = aDecoder.decodeObject(forKey: "userId") as? String
        fullName = aDecoder.decodeObject(forKey: "fullName") as? String
        mobile = aDecoder.decodeObject(forKey: "mobile") as? String
        status = aDecoder.decodeObject(forKey: "status") as? String
        userType = aDecoder.decodeObject(forKey: "userType") as? String
        profilePic = aDecoder.decodeObject(forKey: "profilePic") as? String
        insertDate = aDecoder.decodeObject(forKey: "insertDate") as? Int
        dialCode = aDecoder.decodeObject(forKey: "dialCode") as? String
        userLoginType = aDecoder.decodeObject(forKey: "userLoginType") as? String
        lastLocation = aDecoder.decodeObject(forKey: "lastLocation") as? LastLocation
        isLocationUpdateRequired = aDecoder.decodeObject(forKey: "isLocationUpdateRequired") as? Bool
        locationUpdateTime = aDecoder.decodeObject(forKey: "locationUpdateTime") as? Double
        isAdmin = aDecoder.decodeObject(forKey: "isAdmin") as? Bool

    }
    
    func toDictionary() -> [String: Any] {
        var jsonDict = [String: Any]()
        jsonDict["userId"] = userId
        jsonDict["fullName"] = fullName
        jsonDict["mobile"] = mobile
        jsonDict["isAdmin"] = isAdmin
        jsonDict["locationUpdateTime"] = locationUpdateTime
        jsonDict["lastLocation"] = lastLocation
        jsonDict["userLoginType"] = userLoginType
        jsonDict["dialCode"] = dialCode
        jsonDict["insertDate"] = insertDate
        jsonDict["profilePic"] = profilePic
        jsonDict["userType"] = userType
        jsonDict["status"] = status
        return jsonDict
    }
    @objc func encode(with aCoder: NSCoder)
    {
        if userId != nil{
            aCoder.encode(userId, forKey: "userId")
        }
        if fullName != nil{
            aCoder.encode(fullName, forKey: "fullName")
        }
        if mobile != nil{
            aCoder.encode(mobile, forKey: "mobile")
        }
        if status != nil{
            aCoder.encode(status, forKey: "status")
        }
        if userType != nil{
            aCoder.encode(userType, forKey: "userType")
        }
        if profilePic != nil{
            aCoder.encode(profilePic, forKey: "profilePic")
        }
        if insertDate != nil{
            aCoder.encode(insertDate, forKey: "insertDate")
        }
        if dialCode != nil{
            aCoder.encode(dialCode, forKey: "dialCode")
        }
        if userLoginType != nil{
            aCoder.encode(userLoginType, forKey: "userLoginType")
        }
        if lastLocation != nil{
            aCoder.encode(lastLocation, forKey: "lastLocation")
        }
        if isLocationUpdateRequired != nil{
            aCoder.encode(isLocationUpdateRequired, forKey: "isLocationUpdateRequired")
        }
        if locationUpdateTime != nil{
            aCoder.encode(locationUpdateTime, forKey: "locationUpdateTime")
        }
        if isAdmin != nil{
            aCoder.encode(isAdmin, forKey: "isAdmin")
        }
    }
}
class GroupDetail:NSObject{
    struct Keys {
        static let _id = "_id"
        static let name = "name"
        static let image = "image"
        static let admin = "admin"
        static let creationDate = "creationDate"
        static let insertDate = "insertDate"
        static let totalMembers = "totalMembers"
        static let maximumMembers = "maximumMembers"
        static let isAdmin = "isAdmin"
        static let userId = "userId"
        static let fullName = "fullName"
        static let profilePic = "profilePic"

    }
    var _id:String!
    var name:String!
    let image:String?
    let admin:String?
    var creationDate:String!
    let insertDate:Int?
    let totalMembers:Int?
    let maximumMembers:Int?
    let isAdmin:Bool?
    var userId:String!
    var fullName:String!
    var profilePic:String!

    init(data: Dictionary<String, Any> = [:]) {
        self._id = data[Keys._id] as? String
        self.name = data[Keys.name] as? String
        self.image = data[Keys.image] as? String
        self.admin = data[Keys.admin] as? String
        self.creationDate = data[Keys.creationDate] as? String
        self.insertDate = data[Keys.insertDate] as? Int
        self.totalMembers = data[Keys.totalMembers] as? Int
        self.maximumMembers = data[Keys.maximumMembers] as? Int
        self.isAdmin = data[Keys.isAdmin] as? Bool

        self.userId = data[Keys.userId] as? String
        self.fullName = data[Keys.fullName] as? String
        self.profilePic = data[Keys.profilePic] as? String
        super.init()
    }
}
