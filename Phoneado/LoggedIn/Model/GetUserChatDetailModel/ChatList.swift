//
//  ChatList.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 21, 2022
//
import Foundation
import UIKit

struct ChatList: Codable {

	let Id: String
	let isRead: Bool
	let isDelivered: Bool
	let senderId: String
	let receiverId: String
	let sentAt: Int
	let message: String
	let type: String
	let conversationId: String
	let isOwnMessage: Bool
	let blockByYou: Bool

	private enum CodingKeys: String, CodingKey {
		case Id = "_id"
		case isRead = "isRead"
		case isDelivered = "isDelivered"
		case senderId = "senderId"
		case receiverId = "receiverId"
		case sentAt = "sentAt"
		case message = "message"
		case type = "type"
		case conversationId = "conversationId"
		case isOwnMessage = "isOwnMessage"
		case blockByYou = "blockByYou"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		Id = try values.decode(String.self, forKey: .Id)
		isRead = try values.decode(Bool.self, forKey: .isRead)
		isDelivered = try values.decode(Bool.self, forKey: .isDelivered)
		senderId = try values.decode(String.self, forKey: .senderId)
		receiverId = try values.decode(String.self, forKey: .receiverId)
		sentAt = try values.decode(Int.self, forKey: .sentAt)
		message = try values.decode(String.self, forKey: .message)
		type = try values.decode(String.self, forKey: .type)
		conversationId = try values.decode(String.self, forKey: .conversationId)
		isOwnMessage = try values.decode(Bool.self, forKey: .isOwnMessage)
		blockByYou = try values.decode(Bool.self, forKey: .blockByYou)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(Id, forKey: .Id)
		try container.encode(isRead, forKey: .isRead)
		try container.encode(isDelivered, forKey: .isDelivered)
		try container.encode(senderId, forKey: .senderId)
		try container.encode(receiverId, forKey: .receiverId)
		try container.encode(sentAt, forKey: .sentAt)
		try container.encode(message, forKey: .message)
		try container.encode(type, forKey: .type)
		try container.encode(conversationId, forKey: .conversationId)
		try container.encode(isOwnMessage, forKey: .isOwnMessage)
		try container.encode(blockByYou, forKey: .blockByYou)
	}
    
}

class ChatData: NSObject,NSCoding {

    let Id: String?
    let isRead: Bool?
    let isDelivered: Bool?
    let senderId: String?
    let receiverId: String?
    let mobile: String?

    let sentAt: Int?
    let message: String?
    let type: String?
    let conversationId: String?
    let isOwnMessage: Bool?
    let blockByYou: Bool?
    let senderFullName:String?
    var isMemberExists: Bool?
    var actionType:String?
    var actionPerformedBy:ChatActions!
    var actionPerformedOn:ChatActions!
//    private enum CodingKeys: String, CodingKey {
//        case Id = "_id"
//        case isRead = "isRead"
//        case isDelivered = "isDelivered"
//        case senderId = "senderId"
//        case receiverId = "receiverId"
//        case sentAt = "sentAt"
//        case message = "message"
//        case type = "type"
//        case conversationId = "conversationId"
//        case isOwnMessage = "isOwnMessage"
//        case blockByYou = "blockByYou"
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        Id = try values.decode(String.self, forKey: .Id)
//        isRead = try values.decode(Bool.self, forKey: .isRead)
//        isDelivered = try values.decode(Bool.self, forKey: .isDelivered)
//        senderId = try values.decode(String.self, forKey: .senderId)
//        receiverId = try values.decode(String.self, forKey: .receiverId)
//        sentAt = try values.decode(Int.self, forKey: .sentAt)
//        message = try values.decode(String.self, forKey: .message)
//        type = try values.decode(String.self, forKey: .type)
//        conversationId = try values.decode(String.self, forKey: .conversationId)
//        isOwnMessage = try values.decode(Bool.self, forKey: .isOwnMessage)
//        blockByYou = try values.decode(Bool.self, forKey: .blockByYou)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(Id, forKey: .Id)
//        try container.encode(isRead, forKey: .isRead)
//        try container.encode(isDelivered, forKey: .isDelivered)
//        try container.encode(senderId, forKey: .senderId)
//        try container.encode(receiverId, forKey: .receiverId)
//        try container.encode(sentAt, forKey: .sentAt)
//        try container.encode(message, forKey: .message)
//        try container.encode(type, forKey: .type)
//        try container.encode(conversationId, forKey: .conversationId)
//        try container.encode(isOwnMessage, forKey: .isOwnMessage)
//        try container.encode(blockByYou, forKey: .blockByYou)
//    }
    
    init(_ dict: [String: Any]) {
        Id = dict["_id"] as? String
        isRead = dict["isRead"] as? Bool
        isDelivered = dict["isDelivered"] as? Bool
        senderId = dict["senderId"] as? String
        mobile = dict["mobile"] as? String

        receiverId = dict["receiverId"] as? String
        sentAt = dict["sentAt"] as? Int
        message = dict["message"] as? String
        type = dict["type"] as? String
        conversationId = dict["conversationId"] as? String
        isOwnMessage = dict["isOwnMessage"] as? Bool
        blockByYou = dict["blockByYou"] as? Bool
        senderFullName = dict["senderFullName"] as? String
        isMemberExists = dict["isMemberExists"] as? Bool
        if let data = dict["actionPerformedBy"] as? [String:Any]{
            actionPerformedBy = ChatActions(data)
        }
        if let data = dict["actionPerformedOn"] as? [String:Any]{
            actionPerformedOn = ChatActions(data)
        }
        actionType =  dict["actionType"] as? String
    }
    
    @objc required init(coder aDecoder: NSCoder)
    {
           Id = aDecoder.decodeObject(forKey: "_id") as? String
           isRead = aDecoder.decodeObject(forKey: "isRead") as? Bool
           isDelivered = aDecoder.decodeObject(forKey: "isDelivered") as? Bool
        mobile = aDecoder.decodeObject(forKey: "mobile") as? String

           senderId = aDecoder.decodeObject(forKey: "senderId") as? String
           receiverId = aDecoder.decodeObject(forKey: "receiverId") as? String
           sentAt = aDecoder.decodeObject(forKey: "sentAt") as? Int
           message = aDecoder.decodeObject(forKey: "message") as? String
        type = aDecoder.decodeObject(forKey: "type") as? String
        conversationId = aDecoder.decodeObject(forKey: "conversationId") as? String
        isOwnMessage = aDecoder.decodeObject(forKey: "isOwnMessage") as? Bool
        blockByYou = aDecoder.decodeObject(forKey: "blockByYou") as? Bool
        senderFullName = aDecoder.decodeObject(forKey: "senderFullName") as? String
        isMemberExists = aDecoder.decodeObject(forKey: "isMemberExists") as? Bool
        actionType = aDecoder.decodeObject(forKey: "actionType") as? String
        
        actionPerformedBy = aDecoder.decodeObject(forKey: "actionPerformedBy") as? ChatActions
        actionPerformedOn = aDecoder.decodeObject(forKey: "actionPerformedOn") as? ChatActions
        
    }
    
    @objc func encode(with aCoder: NSCoder)
    {
         if Id != nil{
           aCoder.encode(Id, forKey: "_id")
         }
           if isRead != nil{
             aCoder.encode(isRead, forKey: "isRead")
           }
           if isDelivered != nil{
             aCoder.encode(isDelivered, forKey: "isDelivered")
           }
           if senderId != nil{
             aCoder.encode(senderId, forKey: "senderId")
           }
        if mobile != nil{
          aCoder.encode(mobile, forKey: "mobile")
        }
           if receiverId != nil{
             aCoder.encode(receiverId, forKey: "receiverId")
           }
           if sentAt != nil{
             aCoder.encode(sentAt, forKey: "sentAt")
           }
           if message != nil{
             aCoder.encode(message, forKey: "message")
           }
        if type != nil{
          aCoder.encode(type, forKey: "type")
        }
        if conversationId != nil{
          aCoder.encode(conversationId, forKey: "conversationId")
        }
        if isOwnMessage != nil{
          aCoder.encode(isOwnMessage, forKey: "isOwnMessage")
        }
        if blockByYou != nil{
          aCoder.encode(blockByYou, forKey: "blockByYou")
        }
        if senderFullName != nil{
          aCoder.encode(senderFullName, forKey: "senderFullName")
        }
        if isMemberExists != nil{
          aCoder.encode(isMemberExists, forKey: "isMemberExists")
        }
        
        if actionType != nil{
          aCoder.encode(actionType, forKey: "actionType")
        }
        if actionPerformedBy != nil{
          aCoder.encode(actionPerformedBy, forKey: "actionPerformedBy")
        }
        if actionPerformedOn != nil{
          aCoder.encode(actionPerformedOn, forKey: "actionPerformedOn")
        }
    }

}
class ChatActions: NSObject,NSCoding {
    let userId: String?
    let fullName: String?
    let groupName:String?
    init(_ dict: [String: Any]) {
        userId = dict["userId"] as? String
        fullName = dict["fullName"] as? String
        groupName = dict["groupName"] as? String
        
    }
    @objc required init(coder aDecoder: NSCoder)
    {
        userId = aDecoder.decodeObject(forKey: "userId") as? String
        fullName = aDecoder.decodeObject(forKey: "fullName") as? String
        groupName = aDecoder.decodeObject(forKey: "groupName") as? String

    }
    @objc func encode(with aCoder: NSCoder)
    {
        if userId != nil{
            aCoder.encode(userId, forKey: "userId")
        }
        if fullName != nil{
            aCoder.encode(fullName, forKey: "fullName")
        }
        if groupName != nil{
            aCoder.encode(groupName, forKey: "groupName")
        }
    }
}
