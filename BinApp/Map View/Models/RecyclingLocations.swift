//
//  RecyclingLocations.swift
//  BinApp
//
//  Created by Jordan Porter on 09/04/2019.
//  Copyright © 2019 Jordan Porter. All rights reserved.
//

import Foundation
import CoreLocation

class RecyclingLocation: NSObject, Codable, Identifiable {
    var name: String
    var type: String
    var typeDescription: String
    var coordinates: CLLocationCoordinate2D
    var address: String?
    var postcode: String?
    var distance: Double?
    var drivingDistance: Double?
    var drivingTime: Double?
    
    init(name: String, type: String, typeDescription: String, coordinates: CLLocationCoordinate2D, address: String?, postcode: String?) {
        self.name = name
        self.type = type
        self.typeDescription = typeDescription
        self.coordinates = coordinates
        self.address = address
        self.postcode = postcode
    }
}

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
    }
     
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let longitude = try container.decode(CLLocationDegrees.self)
        let latitude = try container.decode(CLLocationDegrees.self)
        self.init(latitude: latitude, longitude: longitude)
    }
}
