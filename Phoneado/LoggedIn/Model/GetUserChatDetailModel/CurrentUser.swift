//
//  CurrentUser.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 21, 2022
//
import Foundation

struct CurrentUser: Codable {

	let Id: String
	let userId: String

	private enum CodingKeys: String, CodingKey {
		case Id = "_id"
		case userId = "userId"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		Id = try values.decode(String.self, forKey: .Id)
		userId = try values.decode(String.self, forKey: .userId)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(Id, forKey: .Id)
		try container.encode(userId, forKey: .userId)
	}

}

