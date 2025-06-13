//
//  DirectionService.swift
//  BinApp
//
//  Created by Jordan Porter on 18/03/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation
import MapKit

class DirectionService {
    func fetchDirections(for recyclingLocation: RecyclingLocation, from userLocation: CLLocation) async throws -> DirectionData {
        let directionRequest = createDirectionRequest(startingPoint: userLocation.coordinate, endPoint: recyclingLocation.coordinates)
        let directions = MKDirections(request: directionRequest)
        let result = try await directions.calculateETA()
        
        return .init(
            distance: .init(value: result.distance, unit: .meters),
            duration: result.expectedTravelTime
        )
    }
    
    private func createDirectionRequest(startingPoint: CLLocationCoordinate2D, endPoint: CLLocationCoordinate2D) -> MKDirections.Request {
        let request = MKDirections.Request()
        request.source = .init(placemark: .init(coordinate: startingPoint))
        request.destination = .init(placemark: .init(coordinate: endPoint))
        
        return request
    }
}


extension DirectionService{
    struct DirectionData: Equatable {
        let distance: Measurement<UnitLength>
        let duration: TimeInterval
    }
}
