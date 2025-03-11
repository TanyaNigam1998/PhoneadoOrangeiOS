
import Foundation

struct ImageList: Codable {

	var url: String
	var key: String
	var id: String
	var insertDate: Int
	var imageId: String
    var cameraUpload: Bool

	private enum CodingKeys: String, CodingKey {
		case url = "url"
		case key = "key"
		case id = "id"
		case insertDate = "insertDate"
		case imageId = "imageId"
        case cameraUpload = "cameraUpload"
	}

    init(fromDictionary dict: [String: Any]) {
        url = dict["url"] as? String ?? ""
        key = dict["key"] as? String ?? ""
        id = dict["id"] as? String ?? ""
        insertDate = dict["insertDate"] as? Int ?? 0
        imageId = dict["imageId"] as? String ?? ""
        cameraUpload = dict["cameraUpload"] as? Bool ?? false
    }
    
    func toDictionary() -> [String: Any] {
        var jsonDict = [String: Any]()
        jsonDict["url"] = url
        jsonDict["key"] = key
        jsonDict["id"] = id
        jsonDict["insertDate"] = insertDate
        jsonDict["imageId"] = imageId
        jsonDict["cameraUpload"] = cameraUpload
        return jsonDict
    }
    
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		url = try values.decode(String.self, forKey: .url)
		key = try values.decode(String.self, forKey: .key)
		id = try values.decode(String.self, forKey: .id)
		insertDate = try values.decode(Int.self, forKey: .insertDate)
        imageId = try values.decode(String.self, forKey: .imageId)
        cameraUpload = try values.decode(Bool.self, forKey: .cameraUpload)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(url, forKey: .url)
		try container.encode(key, forKey: .key)
		try container.encode(id, forKey: .id)
		try container.encode(insertDate, forKey: .insertDate)
        try container.encode(imageId, forKey: .imageId)
		try container.encode(cameraUpload, forKey: .cameraUpload)
	}

}
