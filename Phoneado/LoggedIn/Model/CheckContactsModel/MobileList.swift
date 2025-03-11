
import Foundation

struct MobileList: Codable {

	let mobile: String?
	let userId: String
	let isVoiceCallEnabled: Bool?
    let fullName:String?
    let profilePic:String?
    var isAdmin:Bool?

	private enum CodingKeys: String, CodingKey {
		case mobile = "mobile"
		case userId = "userId"
		case isVoiceCallEnabled = "isVoiceCallEnabled"
        case fullName = "fullName"
        case profilePic = "profilePic"
        case isAdmin = "isAdmin"

	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		mobile = try values.decodeIfPresent(String.self, forKey: .mobile)
		userId = try values.decode(String.self, forKey: .userId)
		isVoiceCallEnabled = try values.decodeIfPresent(Bool.self, forKey: .isVoiceCallEnabled)
        fullName = try values.decodeIfPresent(String.self, forKey: .fullName) ?? ""
        profilePic = try values.decodeIfPresent(String.self, forKey: .profilePic)
        isAdmin = try values.decodeIfPresent(Bool.self, forKey: .isAdmin)

	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(mobile, forKey: .mobile)
		try container.encode(userId, forKey: .userId)
		try container.encode(isVoiceCallEnabled, forKey: .isVoiceCallEnabled)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(profilePic, forKey: .profilePic)
        try container.encode(isAdmin, forKey: .isAdmin)

	}

}
