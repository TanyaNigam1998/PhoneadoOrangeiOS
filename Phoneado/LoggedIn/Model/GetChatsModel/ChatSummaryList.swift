//
//  ChatSummaryList.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 19, 2022
//
import Foundation

struct ChatSummaryList: Codable {
    
    var senderId: String?
    var receiverId: String?
    var message: String?
    var type: String?
    var sentAt: Int?
    var isRead: Bool?
    var readAt: Any?
    var isDelivered: Bool?
    var deliveredAt: Any?
    var isGroupMessage: Bool?
    var unReadCount: Int?
    var conversationId: String?
    var blockByYou: Bool?
    var senderFullName: String?
    var groupId: String?
    var groupName: String?
    var groupImage: String?
    var isMemberExists: Bool?
    var receiverFullName: String?
    var senderProfilePic: String?
    var receiverProfilePic: String?

    private enum CodingKeys: String, CodingKey {
        case senderId = "senderId"
        case receiverId = "receiverId"
        case message = "message"
        case type = "type"
        case sentAt = "sentAt"
        case isRead = "isRead"
        case readAt = "readAt"
        case isDelivered = "isDelivered"
        case deliveredAt = "deliveredAt"
        case isGroupMessage = "isGroupMessage"
        case unReadCount = "unReadCount"
        case conversationId = "conversationId"
        case blockByYou = "blockByYou"
        case senderFullName = "senderFullName"
        case groupId = "groupId"
        case groupName = "groupName"
        case groupImage = "groupImage"
        case isMemberExists = "isMemberExists"
        case receiverFullName = "receiverFullName"
        case senderProfilePic = "senderProfilePic"
        case receiverProfilePic = "receiverProfilePic"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        senderId = try values.decodeIfPresent(String.self, forKey: .senderId)
        receiverId = try values.decodeIfPresent(String.self, forKey: .receiverId)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        sentAt = try values.decodeIfPresent(Int.self, forKey: .sentAt)
        isRead = try values.decodeIfPresent(Bool.self, forKey: .isRead)
        readAt = nil // TODO: Add code for decoding `readAt`, It was null at the time of model creation.
        isDelivered = try values.decodeIfPresent(Bool.self, forKey: .isDelivered)
        deliveredAt = nil // TODO: Add code for decoding `deliveredAt`, It was null at the time of model creation.
        isGroupMessage = try values.decodeIfPresent(Bool.self, forKey: .isGroupMessage)
        unReadCount = try values.decodeIfPresent(Int.self, forKey: .unReadCount)
        conversationId = try values.decodeIfPresent(String.self, forKey: .conversationId)
        blockByYou = try values.decodeIfPresent(Bool.self, forKey: .blockByYou)
        senderFullName = try values.decodeIfPresent(String.self, forKey: .senderFullName)
        groupId = try values.decodeIfPresent(String.self, forKey: .groupId)
        groupName = try values.decodeIfPresent(String.self, forKey: .groupName)
        groupImage = try values.decodeIfPresent(String.self, forKey: .groupImage)
        isMemberExists = try values.decodeIfPresent(Bool.self, forKey: .isMemberExists)
        receiverFullName = try values.decodeIfPresent(String.self, forKey: .receiverFullName)
        senderProfilePic = try values.decodeIfPresent(String.self, forKey: .senderProfilePic)
        receiverProfilePic = try values.decodeIfPresent(String.self, forKey: .receiverProfilePic)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(senderId, forKey: .senderId)
        try container.encodeIfPresent(receiverId, forKey: .receiverId)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(sentAt, forKey: .sentAt)
        try container.encodeIfPresent(isRead, forKey: .isRead)
        // TODO: Add code for encoding `readAt`, It was null at the time of model creation.
        try container.encodeIfPresent(isDelivered, forKey: .isDelivered)
        // TODO: Add code for encoding `deliveredAt`, It was null at the time of model creation.
        try container.encodeIfPresent(isGroupMessage, forKey: .isGroupMessage)
        try container.encodeIfPresent(unReadCount, forKey: .unReadCount)
        try container.encodeIfPresent(conversationId, forKey: .conversationId)
        try container.encodeIfPresent(blockByYou, forKey: .blockByYou)
        try container.encodeIfPresent(senderFullName, forKey: .senderFullName)
        try container.encodeIfPresent(groupId, forKey: .groupId)
        try container.encodeIfPresent(groupName, forKey: .groupName)
        try container.encodeIfPresent(groupImage, forKey: .groupImage)
        try container.encodeIfPresent(isMemberExists, forKey: .isMemberExists)
        try container.encodeIfPresent(receiverFullName, forKey: .receiverFullName)
        try container.encodeIfPresent(senderProfilePic, forKey: .senderProfilePic)
        try container.encodeIfPresent(receiverProfilePic, forKey: .receiverProfilePic)
        
    }
}
