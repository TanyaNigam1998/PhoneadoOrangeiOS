//
//  UserSignInModel.swift
//  Phoneado
//
//  Created by Zimble on 4/11/22.
//

import Foundation

//struct UserSignInModel: Codable {
//
//    let statusCode: Int?
//    let message: String?
//    let data: UserSignInData?
//
//    private enum CodingKeys: String, CodingKey {
//        case statusCode = "statusCode"
//        case message = "message"
//        case data = "data"
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        statusCode = try values.decode(Int.self, forKey: .statusCode)
//        message = try values.decode(String.self, forKey: .message)
//        data = try values.decode(UserSignInData.self, forKey: .data)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(statusCode, forKey: .statusCode)
//        try container.encode(message, forKey: .message)
//        try container.encode(data, forKey: .data)
//    }
//
//}



// MARK: - UserSignInModel
struct UserSignInModel: Codable {
    var statusCode: Int?
    var message: String?
    var data: UserSignInData?
    
    init(fromDictionary dictionary: [String:Any])
    {
        statusCode = dictionary["statusCode"] as? Int
        message = dictionary["message"] as? String
        data = dictionary["data"] as? UserSignInData
    }
    
}

// MARK: - UserSignInData
struct UserSignInData: Codable {
    var userID, fullName, mobile, status: String?
    var profilePic: String?
    var lastLocation: LastLocation?
    var userType: String?
    var insertDate: Int?
    var isNewUser: Bool?
    
//    enum CodingKeys: String, CodingKey {
//        case userID = "userId"
//        case fullName, mobile, status, profilePic, lastLocation, userType, insertDate, isNewUser
//    }
    
    init(fromDictionary dictionary: [String:Any])
    {
        userID = dictionary["userID"] as? String
        fullName = dictionary["fullName"] as? String
        mobile = dictionary["mobile"] as? String
        status = dictionary["status"] as? String
        profilePic = dictionary["profilePic"] as? String
        lastLocation = dictionary["lastLocation"] as? LastLocation
        userType = dictionary["userType"] as? String
        insertDate = dictionary["insertDate"] as? Int
        isNewUser = dictionary["isNewUser"] as? Bool
    }
    
}

// MARK: - LastLocation
struct LastLocation: Codable {
    let lat: Int?
    let lng: Int?
    
    private enum CodingKeys: String, CodingKey {
        case lat = "lat"
        case lng = "lng"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lat = try values.decode(Int.self, forKey: .lat)
        lng = try values.decode(Int.self, forKey: .lng)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lat, forKey: .lat)
        try container.encode(lng, forKey: .lng)
    }
}

