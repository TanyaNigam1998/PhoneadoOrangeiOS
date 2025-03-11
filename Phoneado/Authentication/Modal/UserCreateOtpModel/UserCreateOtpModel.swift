//
//  UserCreateOtpModel.swift
//  Phoneado
//
//  Created by Zimble on 4/12/22.
//

import Foundation

struct CreateOtpModel {
    let statusCode: Int?
    let message: String?
    let data: String?
    
    init(_ dict: [String: Any]) {
        statusCode = dict["statusCode"] as? Int
        message = dict["message"] as? String
        data = dict["data"] as? String
    }
    
    func toDictionary() -> [String: Any] {
        var jsonDict = [String: Any]()
        jsonDict["statusCode"] = statusCode
        jsonDict["message"] = message
        jsonDict["data"] = data
        return jsonDict
    }
    
//    @objc required init(coder aDecoder: NSCoder)
//    {
//        statusCode = aDecoder.decodeObject(forKey: "userId") as? String
//           fullName = aDecoder.decodeObject(forKey: "fullName") as? String
//           mobile = aDecoder.decodeObject(forKey: "mobile") as? String
//           status = aDecoder.decodeObject(forKey: "status") as? String
//           userType = aDecoder.decodeObject(forKey: "userType") as? String
//           profilePic = aDecoder.decodeObject(forKey: "profilePic") as? String
//           insertDate = aDecoder.decodeObject(forKey: "insertDate") as? Int
//    }
//
//    @objc func encode(with aCoder: NSCoder)
//    {
//         if userId != nil{
//           aCoder.encode(userId, forKey: "userId")
//         }
//           if fullName != nil{
//             aCoder.encode(fullName, forKey: "fullName")
//           }
//           if mobile != nil{
//             aCoder.encode(mobile, forKey: "mobile")
//           }
//           if status != nil{
//             aCoder.encode(status, forKey: "status")
//           }
//           if userType != nil{
//             aCoder.encode(userType, forKey: "userType")
//           }
//           if profilePic != nil{
//             aCoder.encode(profilePic, forKey: "profilePic")
//           }
//           if insertDate != nil{
//             aCoder.encode(insertDate, forKey: "insertDate")
//           }
//    }
    
}
