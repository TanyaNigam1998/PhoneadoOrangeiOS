//
//  CallLogDetails.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on July 05, 2023
//
import Foundation

class CallLogDetails {

	var statusCode: Int?
	var message: String?
	var data: CallLogsData?

	init(_ dict: [String: Any]) {
		statusCode = dict["statusCode"] as? Int
		message = dict["message"] as? String

		if let dataDict = dict["data"] as? [String: Any] {
			data = CallLogsData(dataDict)
		}
	}

	func toDictionary() -> [String: Any] {
		var jsonDict = [String: Any]()
		jsonDict["statusCode"] = statusCode
		jsonDict["message"] = message
		jsonDict["data"] = data?.toDictionary()
		return jsonDict
	}
}

class CallLogsData {

    var callLogs: [CallLogs]?

    init(_ dict: [String: Any]) {

        if let callLogsDictArray = dict["callLogs"] as? [[String: Any]] {
            callLogs = callLogsDictArray.map { CallLogs($0) }
        }
    }

    func toDictionary() -> [String: Any] {
        var jsonDict = [String: Any]()
        jsonDict["callLogs"] = callLogs?.map { $0.toDictionary() }
        return jsonDict
    }
}

class CallLogs {

    var dateCreated: Double?
    var dateUpdated: Double?
    var direction: String?
    var duration: String?
    var endTime: Double?
    var startTime: Double?
    var status: String?
    var to: String?
    var from: String?
    var sid: String?
    var type: String?
    var toDetails: ToDetails?
    var fromDetails: FromDetails?

    init(_ dict: [String: Any]) {
        dateCreated = dict["dateCreated"] as? Double
        dateUpdated = dict["dateUpdated"] as? Double
        direction = dict["direction"] as? String
        duration = dict["duration"] as? String
        endTime = dict["endTime"] as? Double
        startTime = dict["startTime"] as? Double
        status = dict["status"] as? String
        to = dict["to"] as? String
        from = dict["from"] as? String
        sid = dict["sid"] as? String
        type = dict["type"] as? String
        if let toDetailsDict = dict["toDetails"] as? [String: Any] {
            toDetails = ToDetails(toDetailsDict)
        }

        if let fromDetailsDict = dict["fromDetails"] as? [String: Any] {
            fromDetails = FromDetails(fromDetailsDict)
        }
    }

    func toDictionary() -> [String: Any] {
        var jsonDict = [String: Any]()
        jsonDict["dateCreated"] = dateCreated
        jsonDict["dateUpdated"] = dateUpdated
        jsonDict["direction"] = direction
        jsonDict["duration"] = duration
        jsonDict["endTime"] = endTime
        jsonDict["startTime"] = startTime
        jsonDict["status"] = status
        jsonDict["to"] = to
        jsonDict["from"] = from
        jsonDict["sid"] = sid
        jsonDict["type"] = type
        jsonDict["toDetails"] = toDetails?.toDictionary()
        jsonDict["fromDetails"] = fromDetails?.toDictionary()
        return jsonDict
    }
}

class ToDetails {

    var fullName: String?
    var mobile: String?
    var userId: String?
    var profilePic:String?
    init(_ dict: [String: Any]) {
        fullName = dict["fullName"] as? String
        mobile = dict["mobile"] as? String
        userId = dict["userId"] as? String
        profilePic = dict["profilePic"] as? String
    }

    func toDictionary() -> [String: Any] {
        var jsonDict = [String: Any]()
        jsonDict["fullName"] = fullName
        jsonDict["mobile"] = mobile
        jsonDict["userId"] = userId
        jsonDict["profilePic"] = profilePic

        return jsonDict
    }
}

class FromDetails {

    var fullName: String?
    var mobile: String?
    var userId: String?
    var profilePic:String?
    init(_ dict: [String: Any]) {
        fullName = dict["fullName"] as? String
        mobile = dict["mobile"] as? String
        userId = dict["userId"] as? String
        profilePic = dict["profilePic"] as? String
    }

    func toDictionary() -> [String: Any] {
        var jsonDict = [String: Any]()
        jsonDict["fullName"] = fullName
        jsonDict["mobile"] = mobile
        jsonDict["userId"] = userId
        jsonDict["profilePic"] = profilePic

        return jsonDict
    }
}
