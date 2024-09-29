//
//  Untitled.swift
//  BinApp
//
//  Created by Jordan Porter on 29/09/2024.
//  Copyright © 2024 Jordan Porter. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D {
    func distance(to locationCoordinates: CLLocationCoordinate2D) -> CLLocationDistance {
        let location1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let location2 = CLLocation(latitude: locationCoordinates.latitude, longitude: locationCoordinates.longitude)
        
        return location1.distance(from: location2)
    }
}
