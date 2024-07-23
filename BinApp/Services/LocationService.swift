//
//  LocationService.swift
//  BinApp
//
//  Created by Jordan Porter on 23/07/2024.
//  Copyright © 2024 Jordan Porter. All rights reserved.
//

import CoreLocation

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    @ObservationIgnored let manager = CLLocationManager()
    var userLocation: CLLocation?
    var userPostcode: String?
    var isAuthorized = false

    override init() {
        super.init()
        manager.delegate = self
    }

    func startLocationServices() {
        userPostcode = nil
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
            isAuthorized = true
        default:
            isAuthorized = false
            manager.requestWhenInUseAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
        if let userLocation {
            Task {
                let postcode = await getLocationPostcode(for: userLocation)
                userPostcode = postcode
            }
        }

    }

    func getLocationPostcode(for location: CLLocation) async -> String {
        let postcode = try? await CLGeocoder().reverseGeocodeLocation(location).first?.postalCode
        return postcode ?? ""
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            isAuthorized = true
        case .notDetermined:
            isAuthorized = false
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            isAuthorized = false
        default:
            print("Unknown")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

enum LocationError: Error {
    case locationNotFound
    case noLocatonPermissions
}
