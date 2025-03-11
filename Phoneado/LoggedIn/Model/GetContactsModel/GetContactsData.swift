//
//  Data.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 14, 2022
//
import Foundation

struct GetContactsData: Codable {
    
	let contactList: [ContactList]
    
	private enum CodingKeys: String, CodingKey {
		case contactList = "contactList"
	}
    
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		contactList = try values.decode([ContactList].self, forKey: .contactList)
	}
    
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(contactList, forKey: .contactList)
	}
    
}
