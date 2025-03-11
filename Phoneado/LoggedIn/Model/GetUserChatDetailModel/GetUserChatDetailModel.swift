//
//  GetUserChatDetailModel.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 21, 2022
//
import Foundation

struct GetUserChatDetailModel: Codable {

	let statusCode: Int
	let message: String
	let data: GetUserChatDetailData

	private enum CodingKeys: String, CodingKey {
		case statusCode = "statusCode"
		case message = "message"
		case data = "data"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		statusCode = try values.decode(Int.self, forKey: .statusCode)
		message = try values.decode(String.self, forKey: .message)
		data = try values.decode(GetUserChatDetailData.self, forKey: .data)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(statusCode, forKey: .statusCode)
		try container.encode(message, forKey: .message)
		try container.encode(data, forKey: .data)
	}

}

struct GetUserChatDetailData: Codable {

    let chatList: [ChatList]
    let currentUser: CurrentUser
    let chatUser: ChatUser

    private enum CodingKeys: String, CodingKey {
        case chatList = "chatList"
        case currentUser = "currentUser"
        case chatUser = "chatUser"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        chatList = try values.decode([ChatList].self, forKey: .chatList)
        currentUser = try values.decode(CurrentUser.self, forKey: .currentUser)
        chatUser = try values.decode(ChatUser.self, forKey: .chatUser)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(chatList, forKey: .chatList)
        try container.encode(currentUser, forKey: .currentUser)
        try container.encode(chatUser, forKey: .chatUser)
    }

}
