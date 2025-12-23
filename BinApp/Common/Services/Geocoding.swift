//
//  Geocoding.swift
//  BinApp
//
//  Created by Jordan Porter on 21/09/2025.
//  Copyright © 2025 Jordan Porter. All rights reserved.
//
import CoreLocation

protocol Geocoding {
    func geocodeString(_ addressString: String) async throws -> [CLPlacemark]
}

extension CLGeocoder: Geocoding {
    func geocodeString(_ addressString: String) async throws -> [CLPlacemark] {
        try await self.geocodeAddressString(addressString)
    }
}

class MockGeocoder: Geocoding {
    var result: [CLPlacemark]
    var error: Error?

    init(result: [CLPlacemark] = [], error: Error? = nil) {
        self.result = result
        self.error = error
    }

    func geocodeString(_ addressString: String) async throws -> [CLPlacemark] {
        if let error = error { throw error }
        return result
    }
}
