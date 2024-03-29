//
//  DirectionDataController.swift
//  BinApp
//
//  Created by Jordan Porter on 18/03/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation
import MapKit

class DirectionDataController {
    
    func getDirections(from startPoint: CLLocationCoordinate2D, to endPoint: CLLocationCoordinate2D, completion: @escaping (MKDirections.ETAResponse?) -> Void){
        
        let directionRequest = createDirectionRequest(startingPoint: startPoint, endPoint: endPoint)
        let directions = MKDirections(request: directionRequest)
        
        directions.calculateETA { response, error in
            if let _ = error {
                return completion(nil)
            }
            
            guard let response = response else {
                return completion(nil)
            }
            
            return completion(response)
        }
    }
    
    func createDirectionRequest(startingPoint: CLLocationCoordinate2D, endPoint: CLLocationCoordinate2D) -> MKDirections.Request {
        let source          = MKPlacemark(coordinate: startingPoint)
        let destination     = MKPlacemark(coordinate: endPoint)
        
        let request         = MKDirections.Request()
        request.source      = MKMapItem(placemark: source)
        request.destination = MKMapItem(placemark: destination)
        
        return request
    }
}
