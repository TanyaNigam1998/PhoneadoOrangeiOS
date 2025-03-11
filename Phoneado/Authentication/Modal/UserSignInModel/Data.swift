//
//  Data.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 11, 2022
//
import Foundation

//struct UserSignInData: Codable {
//
//	let userId: String
//	let fullName: String
//	let mobile: String
//	let status: String
//	let profilePic: String
//	let lastLocation: LastLocation
//	let userType: String
//	let insertDate: Int
//
//	private enum CodingKeys: String, CodingKey {
//		case userId = "userId"
//		case fullName = "fullName"
//		case mobile = "mobile"
//		case status = "status"
//		case profilePic = "profilePic"
//		case lastLocation = "lastLocation"
//		case userType = "userType"
//		case insertDate = "insertDate"
//	}
//
//	init(from decoder: Decoder) throws {
//		let values = try decoder.container(keyedBy: CodingKeys.self)
//		userId = try values.decode(String.self, forKey: .userId)
//		fullName = try values.decode(String.self, forKey: .fullName)
//		mobile = try values.decode(String.self, forKey: .mobile)
//		status = try values.decode(String.self, forKey: .status)
//		profilePic = try values.decode(String.self, forKey: .profilePic)
//		lastLocation = try values.decode(LastLocation.self, forKey: .lastLocation)
//		userType = try values.decode(String.self, forKey: .userType)
//		insertDate = try values.decode(Int.self, forKey: .insertDate)
//	}
//
//	func encode(to encoder: Encoder) throws {
//		var container = encoder.container(keyedBy: CodingKeys.self)
//		try container.encode(userId, forKey: .userId)
//		try container.encode(fullName, forKey: .fullName)
//		try container.encode(mobile, forKey: .mobile)
//		try container.encode(status, forKey: .status)
//		try container.encode(profilePic, forKey: .profilePic)
//		try container.encode(lastLocation, forKey: .lastLocation)
//		try container.encode(userType, forKey: .userType)
//		try container.encode(insertDate, forKey: .insertDate)
//	}
//
//}
