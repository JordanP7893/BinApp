//
//  RecyclingLocations+ArrayHelpers.swift
//  BinApp
//
//  Created by Jordan Porter on 06/07/2025.
//  Copyright © 2025 Jordan Porter. All rights reserved.
//

import CoreLocation

extension Array where Element == RecyclingLocation {
    func filteredAndSorted(by type: RecyclingType, fromCoordinate: CLLocationCoordinate2D) -> [RecyclingLocation] {
        filtered(by: type).orderedByDistance(from: fromCoordinate)
    }
    
    func orderedByDistance(from point: CLLocationCoordinate2D) -> [RecyclingLocation] {
        sorted { point.distance(to: $0.coordinates) < point.distance(to: $1.coordinates) }
    }
    
    func filtered(by type: RecyclingType) -> [RecyclingLocation] {
        filter { $0.types.contains(type) }
    }
}
