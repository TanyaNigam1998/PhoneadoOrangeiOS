//
//  PhoneNumber.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 14, 2022
//

import Foundation

struct PhoneNumber: Codable {
    
	let key: String?
	let value: String?
    
	private enum CodingKeys: String, CodingKey {
		case key = "key"
		case value = "value"
	}
    
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		key = try values.decodeIfPresent(String.self, forKey: .key)
		value = try values.decodeIfPresent(String.self, forKey: .value)
	}
    
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(key, forKey: .key)
		try container.encodeIfPresent(value, forKey: .value)
	}
    
}
