//
//  LastLocation.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on June 21, 2023
//
import Foundation

class ProfileLastLocation {
	var lat: Double?
	var lng: Double?

	init(_ dict: [String: Any]) {
		lat = dict["lat"] as? Double
		lng = dict["lng"] as? Double
	}

	func toDictionary() -> [String: Any] {
		var jsonDict = [String: Any]()
		jsonDict["lat"] = lat
		jsonDict["lng"] = lng
		return jsonDict
	}
}
