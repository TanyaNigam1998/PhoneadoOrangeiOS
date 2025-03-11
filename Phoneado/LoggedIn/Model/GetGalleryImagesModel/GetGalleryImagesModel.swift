
import Foundation

struct GetGalleryImagesModel: Codable {

	var statusCode: Int
	var message: String
	var data: GetGalleryImagesData

	private enum CodingKeys: String, CodingKey {
		case statusCode = "statusCode"
		case message = "message"
		case data = "data"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		statusCode = try values.decode(Int.self, forKey: .statusCode)
		message = try values.decode(String.self, forKey: .message)
		data = try values.decode(GetGalleryImagesData.self, forKey: .data)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(statusCode, forKey: .statusCode)
		try container.encode(message, forKey: .message)
		try container.encode(data, forKey: .data)
	}

}

struct GetGalleryImagesData: Codable {

    var imageList: [ImageList]
    var totalImages: Int

    private enum CodingKeys: String, CodingKey {
        case imageList = "imageList"
        case totalImages = "totalImages"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        imageList = try values.decode([ImageList].self, forKey: .imageList)
        totalImages = try values.decode(Int.self, forKey: .totalImages)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(imageList, forKey: .imageList)
        try container.encode(totalImages, forKey: .totalImages)
    }

}
