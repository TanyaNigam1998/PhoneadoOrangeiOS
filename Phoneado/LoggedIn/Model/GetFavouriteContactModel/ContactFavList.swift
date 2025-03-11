//
//  ContactFavList.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 18, 2022
//
import Foundation
import PhoneNumberKit

struct ContactFavList: Codable {

	var isFavorite: Bool
	var Id: String
	var userId: String
	var id: String
	var firstName: String
	var phoneNumber: [PhoneNumber]
	var email: String
	var _v: Int
    var profilePic:String?
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
		isFavorite = try values.decode(Bool.self, forKey: .isFavorite)
		Id = try values.decode(String.self, forKey: .Id)
		userId = try values.decode(String.self, forKey: .userId)
		id = try values.decode(String.self, forKey: .id)
		firstName = try values.decode(String.self, forKey: .firstName)
		phoneNumber = try values.decode([PhoneNumber].self, forKey: .phoneNumber)
		email = try values.decode(String.self, forKey: .email)
		_v = try values.decode(Int.self, forKey: ._v)
        profilePic = try values.decodeIfPresent(String.self, forKey: .profilePic)

	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(isFavorite, forKey: .isFavorite)
		try container.encode(Id, forKey: .Id)
		try container.encode(userId, forKey: .userId)
		try container.encode(id, forKey: .id)
		try container.encode(firstName, forKey: .firstName)
		try container.encode(phoneNumber, forKey: .phoneNumber)
		try container.encode(email, forKey: .email)
		try container.encode(_v, forKey: ._v)
        try container.encodeIfPresent(profilePic, forKey: .profilePic)

	}

}
