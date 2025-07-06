//
//  MapView+ViewModel.swift
//  BinApp
//
//  Created by Jordan Porter on 18/08/2024.
//  Copyright © 2024 Jordan Porter. All rights reserved.
//

import CoreLocation
import MapKit
import SwiftUI

@Observable
class MapViewViewModel {
    var locations: [RecyclingLocation] = []
    var locationsFiltered: [RecyclingLocation] = []
    var selectedLocation: RecyclingLocation?
    var selectedRecyclingType: RecyclingType = .glass {
        didSet {
            selectedLocation = nil
            changeMapPinsDisplayed()
        }
    }
    var mapCamera: MapCameraPosition = .automatic
    var mapCentreTracked: CLLocationCoordinate2D = .leedsCityCentre {
        didSet {
            locationsFiltered = locations.filteredAndSorted(by: selectedRecyclingType, fromCoordinate: mapCentreTracked)
        }
    }
    var showError = false
    var errorMessage: String? {
        didSet {
            if errorMessage == nil {
                showError = false
            } else {
                showError = true
            }
        }
    }
    
    let recyclingLocationService: RecyclingLocationServicing
    
    init(recyclingLocationService: RecyclingLocationServicing) {
        self.recyclingLocationService = recyclingLocationService
    }
    
    func loadLocations() async {
        guard locations.isEmpty else { return }
        
        do {
            locations = try await recyclingLocationService.fetchLocations()
            locationsFiltered = locations.filteredAndSorted(by: selectedRecyclingType, fromCoordinate: mapCentreTracked)
        } catch {
            errorMessage = "Failed to load locations. Please try again later."
        }
    }
    
    func changeMapPinsDisplayed() {
        locationsFiltered = locations.filteredAndSorted(by: selectedRecyclingType, fromCoordinate: mapCentreTracked)
        let distance = getDistanceBetween(centre: mapCentreTracked, andFurthestIndex: 4, from: locationsFiltered)
        
        withAnimation {
            mapCamera = .region(
                MKCoordinateRegion(
                    center: .init(
                        latitude: mapCentreTracked.latitude,
                        longitude: mapCentreTracked.longitude
                    ),
                    latitudinalMeters: distance * 2,
                    longitudinalMeters: distance * 2
                )
            )
        }
    }
    
    func changeOf(userLocation: CLLocation?) {
        if let location = userLocation, mapCamera == .automatic {
            mapCamera = .region( .init(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000))
        }
    }
    
    private func getDistanceBetween(centre: CLLocationCoordinate2D, andFurthestIndex furthestIndex: Int, from locations: [RecyclingLocation]) -> CLLocationDistance {
        let closestLocation = locations[furthestIndex]
        return centre.distance(to: closestLocation.coordinates)
    }
}
