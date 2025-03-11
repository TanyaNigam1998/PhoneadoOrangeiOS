//
//  GetFavouriteContactsData.swift
//  Phoneado
//
//  Created by Zimble on 4/18/22.
//

import Foundation

struct GetFavouriteContactsData: Codable {
    
    var contactFavList: [ContactFavList]
    
    private enum CodingKeys: String, CodingKey {
        case contactFavList = "contactFavList"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        contactFavList = try values.decode([ContactFavList].self, forKey: .contactFavList)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(contactFavList, forKey: .contactFavList)
    }
    
}
