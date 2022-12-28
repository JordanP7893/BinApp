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
    
    public func checkLocationSerivces() async {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.startUpdatingLocation()
            checkLocationAuthorization()
        } else {
            errorAlertController.showErrorAlertInTopViewController(withTitle: "Location Not Found", and: "Could not retrive your current location. Please check your settings.")
        }
    }

    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            fallthrough
        case .authorizedAlways:
            break
        case .denied:
            fallthrough
        case .restricted:
            errorAlertController.showErrorAlertInTopViewController(withTitle: "Location Not Found", and: "Could not retrive your current location. Please check your settings.")
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    public func getUsersCurrentLocation() -> CLLocation? {
        guard let locationManager = locationManager else { return nil }
        return locationManager.location
    }
}

extension UserLocationController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
