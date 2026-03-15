//
//  LocationService.swift
//  BinApp
//
//  Created by Jordan Porter on 23/07/2024.
//  Copyright © 2024 Jordan Porter. All rights reserved.
//

import CoreLocation

struct UserAddressComponents: Equatable {
    let postcode: String
    let houseNameOrNumber: String?
    let streetName: String?
}

@Observable
class LocationManager: NSObject {
    @ObservationIgnored private let manager = CLLocationManager()

    var userLocation: CLLocation?
    var userAddressComponents: UserAddressComponents?
    var isAuthorized = false

    override init() {
        super.init()
        manager.delegate = self
    }

    func startLocationServices() {
        userAddressComponents = nil
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

    private func getLocationAddressComponents(for location: CLLocation) async -> UserAddressComponents {
        let placemark = try? await CLGeocoder().reverseGeocodeLocation(location).first
        let postcode = placemark?.postalCode ?? ""
        let houseNameOrNumber = placemark?.subThoroughfare
        let streetName = placemark?.thoroughfare
        return .init(postcode: postcode, houseNameOrNumber: houseNameOrNumber, streetName: streetName)
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task {
            self.userLocation = location
            let addressComponents = await getLocationAddressComponents(for: location)
            self.userAddressComponents = addressComponents
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
