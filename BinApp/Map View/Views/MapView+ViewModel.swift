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

protocol MapViewProtocol: ObservableObject {
    var locations: [RecyclingLocation] { get set }
    var locationsFiltered: [RecyclingLocation] { get set }
    var selectedRecyclingType: RecyclingType { get set }
    var selectedLocation: RecyclingLocation? { get set }
    var mapCamera: MapCameraPosition { get set }
    var mapCentreTracked: CLLocationCoordinate2D { get set }
    func getLocations() async
    func changeOf(userLocation: CLLocation?)
}

@Observable
class MapViewViewModel: MapViewProtocol {
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
            locationsFiltered = filterAndSort(locations: locations, by: selectedRecyclingType)
        }
    }
    
    let recyclingLocationService = RecyclingLocationService()
    
    func getLocations() async {
        guard locations.isEmpty else { return }
        
        do {
            locations = try await recyclingLocationService.fetchLocations()
            locationsFiltered = filterAndSort(locations: locations, by: selectedRecyclingType)
        } catch {
            print("Handle error \(error)")
        }
    }
    
    func changeMapPinsDisplayed() {
        locationsFiltered = filterAndSort(locations: locations, by: selectedRecyclingType)
        let distance = getDistanceBetween(centre: mapCentreTracked, andFurthestIndex: 4, from: locationsFiltered)
        
        withAnimation {
            mapCamera = .region(MKCoordinateRegion(center: .init(latitude: mapCentreTracked.latitude, longitude: mapCentreTracked.longitude), latitudinalMeters: distance * 2, longitudinalMeters: distance * 2))
        }
    }
    
    func changeOf(userLocation: CLLocation?) {
        if let location = userLocation, mapCamera == .automatic {
            mapCamera = .region( .init(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000))
        }
    }
    
    private func filterAndSort(locations: [RecyclingLocation], by type: RecyclingType) -> [RecyclingLocation] {
        let locationsFiltered = locationsFiltered(locations, by: type)
        return orderLocations(locationsFiltered, asDistanceFrom: mapCentreTracked)
    }
    
    private func getDistanceBetween(centre: CLLocationCoordinate2D, andFurthestIndex furthestIndex: Int, from locations: [RecyclingLocation]) -> CLLocationDistance {
        let closestLocation = locations[furthestIndex]
        return mapCentreTracked.distance(to: closestLocation.coordinates)
    }
    
    private func locationsFiltered(_ locations: [RecyclingLocation], by type: RecyclingType) -> [RecyclingLocation] {
        return locations.filter({ $0.types.contains(type) })
    }
    
    private func orderLocations(_ locations: [RecyclingLocation], asDistanceFrom currentLocation: CLLocationCoordinate2D) -> [RecyclingLocation] {
        return locations.sorted { currentLocation.distance(to: $0.coordinates) < currentLocation.distance(to: $1.coordinates) }
    }
}
