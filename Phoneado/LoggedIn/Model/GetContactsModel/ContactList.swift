//
//  ContactList.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 14, 2022
//
import Foundation

struct ContactList: Codable {
    
	let isFavorite: Bool?
	let Id: String?
	let userId: String?
	let id: String?
	let firstName: String?
	let phoneNumber: [PhoneNumber]?
	let email: String?
	let _v: Int?
    let profilePic:String?
	private enum CodingKeys: String, CodingKey {
		case isFavorite = "isFavorite"
		case Id = "_id"
		case userId = "userId"
		case id = "id"
		case firstName = "firstName"
		case phoneNumber = "phoneNumber"
		case email = "email"
		case _v = "__v"
        case profilePic = "profilePic"
	}
    
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		isFavorite = try values.decodeIfPresent(Bool.self, forKey: .isFavorite)
		Id = try values.decodeIfPresent(String.self, forKey: .Id)
		userId = try values.decodeIfPresent(String.self, forKey: .userId)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
		phoneNumber = try values.decodeIfPresent([PhoneNumber].self, forKey: .phoneNumber)
		email = try values.decodeIfPresent(String.self, forKey: .email)
		_v = try values.decodeIfPresent(Int.self, forKey: ._v)
        profilePic = try? values.decodeIfPresent(String.self, forKey: .profilePic)
	}
    
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(isFavorite, forKey: .isFavorite)
		try container.encodeIfPresent(Id, forKey: .Id)
		try container.encodeIfPresent(userId, forKey: .userId)
		try container.encodeIfPresent(id, forKey: .id)
		try container.encodeIfPresent(firstName, forKey: .firstName)
		try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
		try container.encodeIfPresent(email, forKey: .email)
		try container.encodeIfPresent(_v, forKey: ._v)
        try container.encodeIfPresent(profilePic, forKey: .profilePic)

	}
    
}
