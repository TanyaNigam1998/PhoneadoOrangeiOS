//
//  UploadGalleryImageModel.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 19, 2022
//
import Foundation

struct UploadGalleryImageModel: Codable {

	var statusCode: Int
	var message: String
	var data: UploadGalleryImageData

	private enum CodingKeys: String, CodingKey {
		case statusCode = "statusCode"
		case message = "message"
		case data = "data"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		statusCode = try values.decode(Int.self, forKey: .statusCode)
		message = try values.decode(String.self, forKey: .message)
		data = try values.decode(UploadGalleryImageData.self, forKey: .data)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(statusCode, forKey: .statusCode)
		try container.encode(message, forKey: .message)
		try container.encode(data, forKey: .data)
	}

}

struct UploadGalleryImageData: Codable {

    var url: String
    var imageId: String

    private enum CodingKeys: String, CodingKey {
        case url = "url"
        case imageId = "imageId"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        url = try values.decode(String.self, forKey: .url)
        imageId = try values.decode(String.self, forKey: .imageId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(imageId, forKey: .imageId)
    }

}
