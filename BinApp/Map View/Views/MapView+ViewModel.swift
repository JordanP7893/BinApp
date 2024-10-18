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
}

@Observable
class MapViewViewModel: MapViewProtocol {
    var locations: [RecyclingLocation] = []
    var locationsFiltered: [RecyclingLocation] = []
    var selectedLocation: RecyclingLocation?
    var selectedRecyclingType: RecyclingType = .glass {
        didSet {
            changeMapPinsDisplayed()
        }
    }
    var mapCamera: MapCameraPosition = .automatic
    var mapCentreTracked: CLLocationCoordinate2D = .leedsCityCentre
    
    let locationDataContrller = LocationDataController()
    
    func getLocations() async {
        do {
            locations = try await locationDataContrller.fetchLocations()
            locationsFiltered = locationsFiltered(by: selectedRecyclingType)
        } catch {
            print("Handle error \(error)")
        }
    }
    
    func changeMapPinsDisplayed() {
        locationsFiltered = locationsFiltered(by: selectedRecyclingType)
        let distance = getDistanceBetween(centre: mapCentreTracked, andfurthestIndex: 4, from: locationsFiltered)
        
        withAnimation {
            mapCamera = .region(MKCoordinateRegion(center: .init(latitude: mapCentreTracked.latitude, longitude: mapCentreTracked.longitude), latitudinalMeters: distance * 2, longitudinalMeters: distance * 2))
        }
    }
    
    private func getDistanceBetween(centre: CLLocationCoordinate2D, andfurthestIndex furthestIndex: Int, from locations: [RecyclingLocation]) -> CLLocationDistance {
        let sortedLocations = orderLocations(locations, asDistancefrom: centre)
        let fithClosestLocation = sortedLocations[furthestIndex]
        return mapCentreTracked.distance(to: fithClosestLocation.coordinates)
    }
    
    private func locationsFiltered(by type: RecyclingType) -> [RecyclingLocation] {
        return locations.filter({ $0.types.contains(type) })
    }
    
    private func orderLocations(_ locations: [RecyclingLocation], asDistancefrom currentLocation: CLLocationCoordinate2D) -> [RecyclingLocation] {
        return locations.sorted { currentLocation.distance(to: $0.coordinates) < currentLocation.distance(to: $1.coordinates) }
    }
}
