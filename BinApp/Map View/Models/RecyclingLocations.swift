//
//  RecyclingLocations.swift
//  BinApp
//
//  Created by Jordan Porter on 09/04/2019.
//  Copyright © 2019 Jordan Porter. All rights reserved.
//

import Foundation

class RecyclingLocation: NSObject, Codable {
    var name: String
    var type: String
    var typeDescription: String
    var longitude: Double
    var latitude: Double
    var address: String?
    var postcode: String?
    var distance: Double?
    
    init(name: String, type: String, typeDescription: String, longitude: Double, latitude: Double, address: String?, postcode: String?) {
        self.name = name
        self.type = type
        self.typeDescription = typeDescription
        self.longitude = longitude
        self.latitude = latitude
        self.address = address
        self.postcode = postcode
    }
}
