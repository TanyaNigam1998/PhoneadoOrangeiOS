//
//  UserProfile.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 21, 2023
//
import Foundation

struct UserProfileResponse: Codable {

    var statusCode: Int
    var message: String
    var data: UserProfile

    private enum CodingKeys: String, CodingKey {
        case statusCode = "statusCode"
        case message = "message"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        statusCode = try values.decode(Int.self, forKey: .statusCode)
        message = try values.decode(String.self, forKey: .message)
        data = try values.decode(UserProfile.self, forKey: .data)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusCode, forKey: .statusCode)
        try container.encode(message, forKey: .message)
        try container.encode(data, forKey: .data)
    }

}

struct UserProfile: Codable {
    
    var fullName: String
    var mobile: String
    var status: String
    var profilePic: String
    var lastLocation: LastLocation
    var isLocationUpdateRequired: Bool
    var userType: String
    var insertDate: Int
    var locationUpdateTime: Int
    var userId: String
    
    private enum CodingKeys: String, CodingKey {
        case fullName = "fullName"
        case mobile = "mobile"
        case status = "status"
        case profilePic = "profilePic"
        case lastLocation = "lastLocation"
        case isLocationUpdateRequired = "isLocationUpdateRequired"
        case userType = "userType"
        case insertDate = "insertDate"
        case locationUpdateTime = "locationUpdateTime"
        case userId = "userId"
    }
    
     init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fullName = try values.decode(String.self, forKey: .fullName)
        mobile = try values.decode(String.self, forKey: .mobile)
        status = try values.decode(String.self, forKey: .status)
        profilePic = try values.decode(String.self, forKey: .profilePic)
        lastLocation = try values.decode(LastLocation.self, forKey: .lastLocation)
        isLocationUpdateRequired = try values.decode(Bool.self, forKey: .isLocationUpdateRequired)
        userType = try values.decode(String.self, forKey: .userType)
        insertDate = try values.decode(Int.self, forKey: .insertDate)
        locationUpdateTime = try values.decode(Int.self, forKey: .locationUpdateTime)
        userId = try values.decode(String.self, forKey: .userId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(mobile, forKey: .mobile)
        try container.encode(status, forKey: .status)
        try container.encode(profilePic, forKey: .profilePic)
        try container.encode(lastLocation, forKey: .lastLocation)
        try container.encode(isLocationUpdateRequired, forKey: .isLocationUpdateRequired)
        try container.encode(userType, forKey: .userType)
        try container.encode(insertDate, forKey: .insertDate)
        try container.encode(locationUpdateTime, forKey: .locationUpdateTime)
        try container.encode(userId, forKey: .userId)
    }
}
