//
//  GetImageUniqueIDModel.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 19, 2022
//
import Foundation

struct GetImageUniqueIDModel: Codable {

	var statusCode: Int
	var message: String
	var data: GetImageUniqueIDData

	private enum CodingKeys: String, CodingKey {
		case statusCode = "statusCode"
		case message = "message"
		case data = "data"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		statusCode = try values.decode(Int.self, forKey: .statusCode)
		message = try values.decode(String.self, forKey: .message)
		data = try values.decode(GetImageUniqueIDData.self, forKey: .data)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(statusCode, forKey: .statusCode)
		try container.encode(message, forKey: .message)
		try container.encode(data, forKey: .data)
	}

}
struct GetImageUniqueIDData: Codable {

    var uniqueId: String

    private enum CodingKeys: String, CodingKey {
        case uniqueId = "uniqueId"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uniqueId = try values.decode(String.self, forKey: .uniqueId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uniqueId, forKey: .uniqueId)
    }

}
