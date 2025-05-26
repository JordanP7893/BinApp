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

struct StoreAddress: Codable, Hashable {
    var premisesId: Int
    var address1: String
    var address2: String
    var street: String
    var locality: String
    var localAuthority: String
    var town: String
    var postcode: String

    var formattedAddress: String {
        [address1 + ",", address2, street].filter { $0 != "" && $0 != "," }.joined(separator: " ")
    }

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

extension StoreAddress {
    init(premisesId: Int,
         address1: String,
         address2: String,
         street: String,
         locality: String,
         localAuthority: String,
         town: String,
         postcode: String) {
        self.premisesId = premisesId
        self.address1 = address1
        self.address2 = address2
        self.street = street
        self.locality = locality
        self.localAuthority = localAuthority
        self.town = town
        self.postcode = postcode
    }

    static var dummy: Self {
        .init(premisesId: 1, address1: "6 Cragg", address2: "", street: "", locality: "", localAuthority: "", town: "", postcode: "")
    }
    static var dummy2: Self {
        .init(premisesId: 2, address1: "7 Cragg", address2: "", street: "", locality: "", localAuthority: "", town: "", postcode: "")
    }
    static var dummy3: Self {
        .init(premisesId: 3, address1: "8 Cragg", address2: "", street: "", locality: "", localAuthority: "", town: "", postcode: "")
    }
}
