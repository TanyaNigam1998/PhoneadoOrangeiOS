//
//  GetFavouriteContactModel.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 18, 2022
//
import Foundation

struct GetFavouriteContactModel: Codable {
    
	var statusCode: Int
	var message: String
	var data: GetFavouriteContactsData
    
	private enum CodingKeys: String, CodingKey {
		case statusCode = "statusCode"
		case message = "message"
		case data = "data"
	}
    
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		statusCode = try values.decode(Int.self, forKey: .statusCode)
		message = try values.decode(String.self, forKey: .message)
		data = try values.decode(GetFavouriteContactsData.self, forKey: .data)
	}
    
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(statusCode, forKey: .statusCode)
		try container.encode(message, forKey: .message)
		try container.encode(data, forKey: .data)
	}
    
}
