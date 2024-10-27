//
//  Untitled.swift
//  BinApp
//
//  Created by Jordan Porter on 20/10/2024.
//  Copyright © 2024 Jordan Porter. All rights reserved.
//

import Foundation

@Observable
class RecyclingLocationCardViewModel {
    var recyclingLocation: RecyclingLocation
    
    let locationManger: LocationManager
    
    init(
        recyclingLocation: RecyclingLocation,
        locationManger: LocationManager
    ) {
        self.recyclingLocation = recyclingLocation
        self.locationManger = locationManger
    }
    
    func getDirections() async {
        guard let userLocation = locationManger.userLocation else { return }
        
        do {
            let recyclingLocation = self.recyclingLocation
            let directions = try await DirectionDataController().getDirections(from: userLocation.coordinate, to: recyclingLocation.coordinates)
            recyclingLocation.drivingDistance = .init(value: directions.distance, unit: .meters)
            recyclingLocation.drivingTime = directions.expectedTravelTime
            self.recyclingLocation = recyclingLocation
        } catch {
            print(error)
        }
    }
}
