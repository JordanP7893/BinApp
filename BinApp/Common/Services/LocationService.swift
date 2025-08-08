//
//  LocationService.swift
//  BinApp
//
//  Created by Jordan Porter on 23/07/2024.
//  Copyright © 2024 Jordan Porter. All rights reserved.
//

import CoreLocation

@Observable
class LocationManager: NSObject {
    @ObservationIgnored private let manager = CLLocationManager()

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
            isAuthorized = true
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            manager.requestLocation()
        default:
            isAuthorized = false
            manager.requestWhenInUseAuthorization()
        }
    }

    private func getLocationPostcode(for location: CLLocation) async -> String {
        let postcode = try? await CLGeocoder().reverseGeocodeLocation(location).first?.postalCode
        return postcode ?? ""
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task {
            self.userLocation = location
            self.userPostcode = await getLocationPostcode(for: location)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            startLocationServices()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
