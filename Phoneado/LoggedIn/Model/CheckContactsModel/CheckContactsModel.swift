
import Foundation

struct CheckContactsModel: Codable {

	let statusCode: Int
	let message: String
	let data: CheckContactsData

	private enum CodingKeys: String, CodingKey {
		case statusCode = "statusCode"
		case message = "message"
		case data = "data"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		statusCode = try values.decode(Int.self, forKey: .statusCode)
		message = try values.decode(String.self, forKey: .message)
		data = try values.decode(CheckContactsData.self, forKey: .data)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(statusCode, forKey: .statusCode)
		try container.encode(message, forKey: .message)
		try container.encode(data, forKey: .data)
	}

}

struct CheckContactsData: Codable {
    let mobileList: [MobileList]

    private enum CodingKeys: String, CodingKey {
        case mobileList = "mobileList"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        mobileList = try values.decode([MobileList].self, forKey: .mobileList)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mobileList, forKey: .mobileList)
    }
}
