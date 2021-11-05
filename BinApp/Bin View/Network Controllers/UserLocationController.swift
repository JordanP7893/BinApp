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

class UserLocationController: CLLocationManager, CLLocationManagerDelegate {
    
    public func checkLocationSerivces(completion: @escaping (Bool) -> Void){
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization { (result) in
                if result {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
    }

    private func setupLocationManager() {
        self.delegate = self
        self.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    private func checkLocationAuthorization(completion: @escaping (Bool) -> Void) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            fallthrough
        case .authorizedAlways:
            completion(true)
        case .denied:
            fallthrough
        case .restricted:
            completion(false)
        default:
            self.requestWhenInUseAuthorization()
        }
    }
}
