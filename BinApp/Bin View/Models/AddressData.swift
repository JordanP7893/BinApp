//
//  AddressData.swift
//  BinApp
//
//  Created by Jordan Porter on 27/06/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation

struct AddressData: Codable {
    var id: Int
    var title: String
}

struct StoreAddress: Codable {
    var premisesId: Int
    var address1: String
    var address2: String
    var street: String
    var locality: String
    var localAuthority: String
    var town: String
    var postcode: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        premisesId = try values.decode(Int.self, forKey: .premisesId)
        address1 = try values.decode(String.self, forKey: .address1).capitalized
        address2 = try values.decode(String.self, forKey: .address2).capitalized
        street = try values.decode(String.self, forKey: .street).capitalized
        locality = try values.decode(String.self, forKey: .locality).capitalized
        localAuthority = try values.decode(String.self, forKey: .localAuthority).capitalized
        town = try values.decode(String.self, forKey: .town).capitalized
        postcode = try values.decode(String.self, forKey: .postcode).capitalized
    }
    
    private enum CodingKeys : String, CodingKey {
        case premisesId = "PremiseID"
        case address1 = "Address1"
        case address2 = "Address2"
        case street = "Street"
        case locality = "Locality"
        case localAuthority = "LocalAuthority"
        case town = "Town"
        case postcode = "Postcode"
    }
}
