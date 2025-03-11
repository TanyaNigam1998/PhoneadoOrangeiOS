////
////  SocketHelper.swift
////  Socket_demo
////
////  Created by Krishna Soni on 06/12/19.
////  Copyright © 2019 Krishna Soni. All rights reserved.
////
//
//import UIKit
//import Foundation
//import SocketIO
//
//let kHost = "https://phoneado.herokuapp.com"
//var kConnectUser = "61d531a134d6970017027b2b" //6256c548e10e2c0018db885e
//let kUserList = "userList"
//let kExitUser = "exitUser"
//
////final class SocketHelper: NSObject {
////
////    static let shared = SocketHelper()
////    private var manager: SocketManager?
////    private var socket: SocketIOClient?
////
////    override init() {
////        super.init()
////        configureSocketClient()
////    }
////    private func configureSocketClient() {
////        guard let url = URL(string: kHost) else {
////            return
////        }
////        manager = SocketManager(socketURL: url, config: [.log(true), .compress])
////        guard let manager = manager else {
////            return
////        }
////        socket = manager.socket(forNamespace: "/individualChat")
////    }
////
////    func establishConnection() {
////        guard let socket = manager?.defaultSocket else{
////            return
////        }
////        let authorizationToken = Storage.shared.readObject(forKey: UserDefault.appToken) ?? ""
////        manager?.config = SocketIOClientConfiguration(arrayLiteral: .connectParams(["token": authorizationToken]))
////        socket.connect()
////    }
////
////    func closeConnection() {
////
////        guard let socket = manager?.defaultSocket else{
////            return
////        }
////
////        socket.disconnect()
////    }
////
////    func joinChatRoom(nickname: String, completion: () -> Void) {
////
////        guard let socket = manager?.defaultSocket else {
////            return
////        }
////
////        socket.emit(kConnectUser, nickname)
////        completion()
////    }
////
////    func leaveChatRoom(nickname: String, completion: () -> Void) {
////
////        guard let socket = manager?.defaultSocket else{
////            return
////        }
////
////        socket.emit(kExitUser, nickname)
////        completion()
////    }
////
////    func participantList(completion: @escaping (_ userList: [User]?) -> Void) {
////
////        guard let socket = manager?.defaultSocket else {
////            return
////        }
////
////        socket.on(kUserList) { [weak self] (result, ack) -> Void in
////
////            guard result.count > 0,
////                let _ = self,
////                let user = result.first as? [[String: Any]],
////                let data = UIApplication.jsonData(from: user) else {
////                    return
////            }
////
////            do {
////                let userModel = try JSONDecoder().decode([User].self, from: data)
////                completion(userModel)
////
////            } catch let error {
////                print("Something happen wrong here...\(error)")
////                completion(nil)
////            }
////        }
////
////    }
////
////    func getMessage(completion: @escaping (_ messageInfo: Message?) -> Void) {
////
////        guard let socket = manager?.defaultSocket else {
////            return
////        }
////
////        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
////
////            var messageInfo = [String: Any]()
////
////            guard let nickName = dataArray[0] as? String,
////                let message = dataArray[1] as? String,
////                let date = dataArray[2] as? String else{
////                    return
////            }
////
////            messageInfo["nickname"] = nickName
////            messageInfo["message"] = message
////            messageInfo["date"] = date
////
////            guard let data = UIApplication.jsonData(from: messageInfo) else {
////                return
////            }
////
////            do {
////                let messageModel = try JSONDecoder().decode(Message.self, from: data)
////                completion(messageModel)
////
////            } catch let error {
////                print("Something happen wrong here...\(error)")
////                completion(nil)
////            }
////        }
////    }
////
////    func sendMessage(message: String, withNickname nickname: String) {
////
////        guard let socket = manager?.defaultSocket else {
////            return
////        }
////
////        socket.emit("chatMessage", nickname, message)
////    }
////}
///
///

import UIKit
import SocketIO

enum SocketEvents {
    case isTyping
    case isStopTyping
    case connection
    case sendMessage
    case isSeen
    case disconnect
    case sendGroupMessage
    case voiceCall
    case voiceCallIncoming
    case isOnAnotherCall


    
    func name() -> String {
        switch self {
        case .isTyping:
            return "isTyping"
        case .connection:
            return "connection"
        case .sendMessage:
            return "sendMessage"
        case .sendGroupMessage:
            return "sendGroupMessage"
        case .isStopTyping:
            return "isTypingStop"
        case .isSeen:
            return "isSeen"
        case .disconnect:
            return "disconnect"
        case .voiceCall:
            return "voiceCall"
        case .voiceCallIncoming:
            return "voiceCallIncoming"
        case .isOnAnotherCall:
            return "isOnAnotherCall"
        }
    }
}

enum SocketListeners {
    case socketErr
    case socketConnected
    case sendMessage
    case sendGroupMessage
    case isTyping
    case isTypingStop
    case isSeen
    case isOnline
    case disconnect
    case voiceCall
    case voiceCallIncoming
    case isOnAnotherCall


    
    func name() -> String {
        switch self {
        case .socketErr:
            return "socketErr"
        case .socketConnected:
            return "socketConnected"
        case .sendMessage:
            return "sendMessage"
        case .sendGroupMessage:
            return "sendGroupMessage"
        case .isTyping:
            return "isTyping"
        case .isTypingStop:
            return "isTypingStop"
        case .isSeen:
            return "isSeen"
        case .isOnline:
            return "isOnline"
        case .disconnect:
            return "disconnect"
        case .voiceCall:
            return "voiceCall"
        case .voiceCallIncoming:
            return "voiceCallIncoming"
        case .isOnAnotherCall:
            return "isOnAnotherCall"
        }
    }
}

class Socketton: NSObject {
    static let shared = Socketton()
    var manager:SocketManager?
    var socket:SocketIOClient?
    
    var isOnlineCallback : (([String:Any]) -> Void)?
    var isTypingCallback: (([String:Any]) -> Void)?
    var isTypingStopCallback:(([String:Any]) -> Void)?
    var isConnected:(([String:Any]) -> Void)?
    var isMessageSeenCallback:(([String:Any]) -> Void)?
    var isGroupMessageReceived:(([String:Any]) -> Void)?
    var isErrorReceived:(([String:Any]) -> Void)?
    var isSocketConnected:(([String:Any]) -> Void)?
    var isMessageReceivedCallback:(([String:Any]) -> Void)?
    var isVoiceIncoming:(([String:Any]) -> Void)?
    var isOnAnotherCall:(([String:Any]) -> Void)?

    
    
    override init() {
        super.init()
        //configureSocketClient()
    }
    
    private func configureSocketClient() {
        guard let url = URL(string: Constant.BASE_URL) else {
            return
        }
        print("Url  = \(url)")
        manager = SocketManager(socketURL: url, config: [.log(true), .compress])
        guard let manager = manager else {
            return
        }
        socket = manager.socket(forNamespace: "/chat")
    }
    
    func setupSocket() {
        guard socket == nil else {
            return
        }
        let userId = Storage.shared.readUser()?.userId
        let authorizationToken = Storage.shared.readObject(forKey: UserDefault.appToken) ?? ""
        manager = SocketManager(socketURL: URL(string: Constant.BASE_URL)!, config: SocketIOClientConfiguration(arrayLiteral: SocketIOClientOption.connectParams(["userId": userId ?? "","token": authorizationToken])))//,"token": authorizationToken
        print("Socket URl = \(Constant.BASE_URL), Token = \(authorizationToken), UserId  = \(userId ?? "")")
        socket = manager?.defaultSocket
    }
    
//    func establishConnection() {
//        guard let socket = manager?.defaultSocket else{
//            return
//        }
//        let authorizationToken = Storage.shared.readObject(forKey: UserDefault.appToken) ?? ""
//        manager?.config = SocketIOClientConfiguration(arrayLiteral: .connectParams(["token": authorizationToken]))
//        socket.connect()
//    }
    
    func establishConnection() {
        if let socketConnectionStatus = self.socket?.status {
            switch socketConnectionStatus {
            case SocketIOStatus.connected:
                print("socket connected")
                self.isSocketConnected?(["SocketStatus":true])
            case SocketIOStatus.connecting:
                print("socket connecting")
            case SocketIOStatus.disconnected:
                print("socket disconnected")
                self.setupConnection()
            case SocketIOStatus.notConnected:
                print("socket not connected")
                self.setupConnection()
            }
        } else {
            self.setupConnection()
        }
    }
    
    func setupConnection() {
        self.setupSocket()
        socket?.connect()
        manager?.connect()
        socket?.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            self.isSocketConnected?([:])
        }
        self.socket?.on(SocketListeners.socketErr.name(), callback: {data, ack in
            if let data = data[0] as? [String:Any] {
                self.isErrorReceived?(data)
            }
            print("socket Error = ", data)
        })
        self.socket?.on(SocketListeners.socketConnected.name(), callback: {data, ack in
            print("socket connected = ", data)
        })
        
        self.socket?.on(SocketListeners.disconnect.name(), callback: { data, ack in
            print("Disconnected = ", data)
        })
        self.socket?.on(SocketListeners.isOnline.name(), callback: {[weak self] data, ack in
//            print(data.jsonString)
            if let data = data[0] as? [String:Any] {
                self?.isOnlineCallback?(data)
            }
        })
        self.socket?.on(SocketListeners.isTyping.name(), callback: {[weak self] data, ack in
//            print(data.jsonString)
            if let data = data[0] as? [String:Any] {
                self?.isTypingCallback?(data)
            }
        })
        self.socket?.on(SocketListeners.isSeen.name(), callback: {[weak self] data, ack in
//            print(data.jsonString)
            if let data = data[0] as? [String:Any] {
                self?.isMessageSeenCallback?(data)
            }
        })
        
        self.socket?.on(SocketListeners.voiceCallIncoming.name(), callback: {[weak self] data, ack in
//            print(data.jsonString)
            if let data = data[0] as? [String:Any] {
                self?.isVoiceIncoming?(data)
            }
        })
        
        self.socket?.on(SocketListeners.isOnAnotherCall.name(), callback: {[weak self] data, ack in
//            print(data.jsonString)
            if let data = data[0] as? [String:Any] {
                self?.isOnAnotherCall?(data)
            }
        })

        
        self.socket?.on("getBadge", callback: {data, ack in
            print(data)
        })
        self.socket?.on(SocketListeners.isTypingStop.name(), callback: {[weak self] data, ack in
//            print(data.jsonString)
            if let data = data[0] as? [String:Any] {
                self?.isTypingStopCallback?(data)
            }
        })
        self.socket?.on(SocketListeners.sendMessage.name(), callback: {[weak self] data, ack in
//            print(data.jsonString)
            if let data = data[0] as? [String:Any] {
                self?.isMessageReceivedCallback?(data)
            }
        })
        
        self.socket?.on(SocketListeners.voiceCall.name(), callback: {[weak self] data, ack in
//            print(data.jsonString)
            if let data = data[0] as? [String:Any] {
                self?.isConnected?(data)
            }
        })
        self.socket?.on(SocketListeners.sendGroupMessage.name(), callback: {[weak self] data, ack in
            //            print(data.jsonString)
            if let data = data[0] as? [String:Any] {
                self?.isGroupMessageReceived?(data)
            }
        })
        
       
    }
    func subscribeGroupChannel(groupId:String,userId:String,leave:Bool = false){
        
        var channelData = ["groupId": groupId,"userId":userId,"action":"join"]
        if leave{
            channelData["action"] = "leave"
        }
        self.socket?.emit("joinOrLeaveRooms", channelData) {

        }
        
    }
    func isTypingEmit(json:[String:String]) {
        self.socket?.emit(SocketEvents.isTyping.name(), json)
    }
    
    func stopTypingEmit(json: [String: String]) {
        self.socket?.emit(SocketEvents.isStopTyping.name(), json)
    }
    
    func seenEmit(json: [String: String]) {
        self.socket?.emit(SocketEvents.isSeen.name(), json)
    }
    
    func sendMessage(json: [String: Any]) {
        if self.socket?.status.active == false {
            self.establishConnection()
        }
        self.socket?.emit(SocketEvents.sendMessage.name(), json)
    }
    
    func voiceCallIncoming(json:[String:Any]) {
        if self.socket?.status.active == false {
            self.establishConnection()
        }
        self.socket?.emit(SocketEvents.voiceCallIncoming.name(), json)
    }
    
    
    func alreadyAnotherCall(json:[String:Any]) {
        if self.socket?.status.active == false {
            self.establishConnection()
        }
        self.socket?.emit(SocketEvents.isOnAnotherCall.name(), json)
    }

    
    func sendConnect(json:[String:String]) {
        if self.socket?.status.active == false {
            self.establishConnection()
        }
        self.socket?.emit(SocketEvents.voiceCall.name(), json)
    }
//    func sendMessageEvent() {
//
//        sendMessage (Listeners for receiver - sendMessage)
//        {
//            senderId : _id of Sender,
//            receiverId : _id of Receiver,
//            message : Message String,
//            sentAt : Date Time (UTC Date Time)
//        }
//    }

    
    func sendGroupMessage(json:[String:Any]) {
        if self.socket?.status.active == false {
            self.establishConnection()
        }
        self.socket?.emit(SocketEvents.sendGroupMessage.name(), json)
    }
//    func sendMessageEvent() {
//
//        sendMessage (Listeners for receiver - sendMessage)
//        {
//            senderId : _id of Sender,
//            receiverId : _id of Receiver,
//            message : Message String,
//            sentAt : Date Time (UTC Date Time)
//        }
//    }
    func closeConnection() {
        socket?.disconnect()
        self.socket = nil
    }
}
