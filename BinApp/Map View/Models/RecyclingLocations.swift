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
    let id: UUID
    let name: String
    let types: [RecyclingType]
    let coordinates: CLLocationCoordinate2D
    let address: String?
    let postcode: String?
    var distance: Double?
    var drivingDistance: Double?
    var drivingTime: Double?
    
    init(name: String, types: [RecyclingType], coordinates: CLLocationCoordinate2D, address: String?, postcode: String?) {
        self.id = UUID()
        self.name = name
        self.types = types
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

extension RecyclingLocation {
    static var mockData: RecyclingLocation {
        .init(
            name: "Leeds City Center",
            types: [.glass],
            coordinates: CLLocationCoordinate2D(latitude: 53.7997, longitude: -1.5492),
            address: "123 Main Street\nLeeds",
            postcode: "LS1 1UR"
        )
    }
}

extension Array where Element == RecyclingLocation {
    static var mockData: Self {
        [
            RecyclingLocation(
                name: "Leeds City Center",
                types: [.glass],
                coordinates: CLLocationCoordinate2D(latitude: 53.7997, longitude: -1.5492),
                address: "123 Main Street, Leeds",
                postcode: "LS1 1UR"
            ),
            RecyclingLocation(
                name: "Headingley Taps",
                types: [.glass, .paper],
                coordinates: CLLocationCoordinate2D(latitude: 53.8194, longitude: -1.5804),
                address: "456 Paper Lane, Headingley, Leeds",
                postcode: "LS6 3AA"
            ),
            RecyclingLocation(
                name: "Holbeck Recycling Centre",
                types: [.glass, .textiles],
                coordinates: CLLocationCoordinate2D(latitude: 53.7842, longitude: -1.5556),
                address: "789 Cloth Street, Holbeck, Leeds",
                postcode: "LS11 5HJ"
            ),
            RecyclingLocation(
                name: "Seacroft Station",
                types: [.glass, .paper, .textiles, .electronics],
                coordinates: CLLocationCoordinate2D(latitude: 53.8184, longitude: -1.4661),
                address: "654 Tech Avenue, Seacroft, Leeds",
                postcode: "LS14 6HS"
            )
        ]
    }
}
