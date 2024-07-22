//
//  BinAddressViewModel.swift
//  BinApp
//
//  Created by Jordan Porter on 12/12/2023.
//  Copyright © 2023 Jordan Porter. All rights reserved.
//
import CoreLocation
import Foundation
import MapKit
import SwiftUI

@MainActor
class BinAddressViewModel: ObservableObject {
    @Published var mapCamera: MapCameraPosition = .camera(.init(centerCoordinate: .leedsCityCentre, distance: 100000))
    @Published var point: MapPoint?
    @Published var searchText: String = ""
    @Published var addresses: [StoreAddress]?
    @Published var selectedAddressIndex: Int = 0 {
        didSet {
            selectAddress(at: selectedAddressIndex)
        }
    }

    let geocoder = CLGeocoder()
    let binAddressDataController = BinAddressDataController()

    func retrieveRegionFromPostcode() async throws {
        let location = try await geocoder.geocodeAddressString(searchText)
        let addresses = try await binAddressDataController.fetchAddress(postcode: searchText)

        self.addresses = addresses.sorted { $0.formattedAddress.localizedStandardCompare($1.formattedAddress) == .orderedAscending }

        let circularRegion = location.first?.region as? CLCircularRegion
        guard let region = circularRegion?.center else { return }

        self.mapCamera = .camera(.init(centerCoordinate: region, distance: 1000))
    }

    func selectAddress(at index: Int) {
        guard let addresses else { return }

        let selectedAddress = addresses[index]

        Task {
            try await retrievePointFromAddress(selectedAddress.formattedAddress)
        }
    }

    func retrievePointFromAddress(_ address: String) async throws {
        let location = try await geocoder.geocodeAddressString(address + " " + searchText)

        let circularRegion = location.first?.region as? CLCircularRegion
        guard let coordinates = circularRegion?.center else { return }
        self.point = .init(title: address, coordinates: coordinates)
        self.mapCamera = .camera(.init(centerCoordinate: coordinates, distance: 500))
    }
}

extension CLLocationCoordinate2D {
    static var leedsCityCentre: Self {
        .init(latitude: 53.799660, longitude: -1.549790)
    }
}

struct MapPoint {
    let title: String
    let coordinates: CLLocationCoordinate2D
}
