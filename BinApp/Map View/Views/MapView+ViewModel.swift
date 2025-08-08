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
    var selectedRecyclingType: RecyclingType = .glass { didSet { changeOfSelectedRecyclingType() } }
    
    var mapCamera: MapCameraPosition = .automatic
    var mapCentreTracked: CLLocationCoordinate2D = .leedsCityCentre { didSet { changeOfMapCentreTracked() } }
    
    var showError = false
    var errorMessage: String? { didSet { changeOf(errorMessage: errorMessage) } }
    
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
    
    func changeOf(userLocation: CLLocation?) {
        if let location = userLocation, mapCamera == .automatic {
            mapCamera = .region( .init(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000))
        }
    }
    
    private func changeOfSelectedRecyclingType() {
        selectedLocation = nil
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
    
    private func changeOfMapCentreTracked() {
        locationsFiltered = locations.filteredAndSorted(by: selectedRecyclingType, fromCoordinate: mapCentreTracked)
    }
    
    private func changeOf(errorMessage: String?) {
        if errorMessage == nil {
            showError = false
        } else {
            showError = true
        }
    }
    
    private func getDistanceBetween(centre: CLLocationCoordinate2D, andFurthestIndex furthestIndex: Int, from locations: [RecyclingLocation]) -> CLLocationDistance {
        let closestLocation = locations[furthestIndex]
        return centre.distance(to: closestLocation.coordinates)
    }
}
