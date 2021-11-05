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
    var id: Int
    var premisesId: Int
    var addressJoined: String
    var address1: String
    var address2: String
    var street: String
    var locality: String
    var town: String
    var postcode: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let idInt = Int(try values.decode(String.self, forKey: .id)) else {fatalError("The id is not an Int")}
        id = idInt
        guard let premInt = Int(try values.decode(String.self, forKey: .premisesId)) else {fatalError("The premises id is not an Int")}
        premisesId = premInt
        addressJoined = try values.decode(String.self, forKey: .addressJoined).capitalized
        address1 = try values.decode(String.self, forKey: .address1).capitalized
        address2 = try values.decode(String.self, forKey: .address2).capitalized
        street = try values.decode(String.self, forKey: .street).capitalized
        locality = try values.decode(String.self, forKey: .locality).capitalized
        town = try values.decode(String.self, forKey: .town).capitalized
        postcode = try values.decode(String.self, forKey: .postcode).capitalized
    }
    
    private enum CodingKeys : String, CodingKey {
        case id = "ID"
        case premisesId = "PremisesID"
        case addressJoined = "AddressJoined"
        case address1 = "Address1"
        case address2 = "Address2"
        case street = "Street"
        case locality = "Locality"
        case town = "Town"
        case postcode = "Postcode"
    }
}
