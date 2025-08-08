//
//  RecyclingLocationService.swift
//  BinApp
//
//  Created by Jordan Porter on 15/04/2019.
//  Copyright © 2019 Jordan Porter. All rights reserved.
//

import Foundation
import CoreLocation

protocol RecyclingLocationServicing {
    func fetchLocations() async throws -> [RecyclingLocation]
}

class RecyclingLocationService: RecyclingLocationServicing {
    let networkingService: NetworkingService
    let archivingService: ArchivingService
    
    init(networkingService: NetworkingService = DefaultNetworkingService(), archivingService: ArchivingService = DefaultArchivingService()) {
        self.networkingService = networkingService
        self.archivingService = archivingService
    }
    
    func fetchLocations() async throws -> [RecyclingLocation] {
        if let locations = getLocalLocationData() {
            return locations
        } else {
            return try await getRemoteLocationData()
        }
    }
    
    private func getRemoteLocationData() async throws -> [RecyclingLocation] {
        let data = try await downloadRecyclingData()
        guard let string = String(data: data, encoding: .isoLatin1) else {
            throw RecyclingLocationService.ServiceErrors.stringConversionFailed
        }
        let locations = try convertCsvStringToRecyclingLocation(string: string)
        try archivingService.save(locations, to: archiveURL)
        return locations
    }
    
    private func getLocalLocationData() -> [RecyclingLocation]? {
        guard archiveURL.isThisURL(lessThanDaysOld: 28) else { return nil }
        return try? archivingService.load(from: archiveURL, as: [RecyclingLocation].self)
    }
}

extension RecyclingLocationService {
    private var archiveURL: URL {
        archivingService.getArchiveUrl(withName: "recycling_data")
    }

    private func downloadRecyclingData() async throws -> Data {
        return try await networkingService.fetchData(from: AppConfig.recyclingLocationsUrl)
    }
    
    private func convertCsvStringToRecyclingLocation(string: String) throws -> [RecyclingLocation] {
        let rows = try parseCsvRows(from: string)
        return rows.compactMap { location(from: $0) }
    }
    
    private func parseCsvRows(from string: String) throws -> [[String: String]] {
        let csv = CSwiftV(with: string)
        guard let keyedRows = csv.keyedRows else {
            throw ServiceErrors.csvConversionFailed
        }
        return keyedRows
    }
    
    private func location(from row: [String: String]) -> RecyclingLocation? {
        guard let name = row["Site Name"],
              let longitudeString = row["Longitude"],
              let latitudeString = row["Latitude"],
              var longitude = Double(longitudeString),
              let latitude = Double(latitudeString)
        else { return nil }
        
        // Fix for incorrect longitudes, Leeds locations are always negative longitude
        longitude = longitude > 0 ? -longitude : longitude

        let address = row["Address"]
        let postcode = row["Post Code"]
        let glass = row["Recyclables-Mixed Glass"] == "Y"
        let paper = row["Recyclables-Paper"] == "Y"
        let textiles = row["Recyclables-Textiles"] == "Y"
        let electronics = row["Recyclables Small Electrical"] == "Y"

        let types: [RecyclingType] = [
            glass ? .glass : nil,
            paper ? .paper : nil,
            textiles ? .textiles : nil,
            electronics ? .electronics : nil
        ].compactMap { $0 }

        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return RecyclingLocation(
            name: name,
            types: types,
            coordinates: coordinates,
            address: address,
            postcode: postcode
        )
    }
}

extension RecyclingLocationService {
    enum ServiceErrors: Error {
        case invalidURL
        case stringConversionFailed
        case csvConversionFailed
    }
}

class MockRecyclingLocationService: RecyclingLocationServicing {
    func fetchLocations() async throws -> [RecyclingLocation] {
        .mockData
    }
}
