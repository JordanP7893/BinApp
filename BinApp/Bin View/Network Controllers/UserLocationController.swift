//
//  UserLocationController.swift
//  BinApp
//
//  Created by Jordan Porter on 29/03/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class UserLocationController: NSObject {
    
    var locationManager: CLLocationManager?
    let errorAlertController = ErrorAlertController()
    
    public func setupLocationManager(vc: CLLocationManagerDelegate) {
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.startUpdatingLocation()
        locationManager?.delegate = vc
        locationManager?.requestWhenInUseAuthorization()
    }

    public func checkLocationAuthorization(forViewController viewController: CLLocationManagerDelegate) -> Bool? {
        guard let locationManager = locationManager else {
            setupLocationManager(vc: viewController)
            return nil
        }
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        case .denied, .restricted:
            return false
        default:
            locationManager.requestWhenInUseAuthorization()
            return nil
        }
    }
    
    public func getUsersCurrentLocation() -> CLLocation? {
        guard let locationManager = locationManager else { return nil }
        return locationManager.location
    }
}
