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
        try saveLocationsToDisk(locations)
        return locations
    }
    
    private func getLocalLocationData() -> [RecyclingLocation]? {
        guard archiveURL.isThisURL(lessThanDaysOld: 28) else { return nil }
        
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedLocations = try? Data(contentsOf: archiveURL),
           let decodedLocations = try? propertyListDecoder.decode([RecyclingLocation].self, from: retrievedLocations) {
            return decodedLocations
        } else {
            return nil
        }
    }
}

extension RecyclingLocationService {
    private var archiveURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("recycling_data").appendingPathExtension("plist")
    }

    private func downloadRecyclingData() async throws -> Data {
        guard let url = URL(string: AppConfig.recyclingLocationsUrl) else {
            throw RecyclingLocationService.ServiceErrors.invalidURL
        }
        
        let (data, response) = try await URLSession(configuration: .default).data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw RecyclingLocationService.ServiceErrors.invalidResponse
        }
        return data
    }

    private func saveLocationsToDisk(_ locations: [RecyclingLocation]) throws {
        if FileManager.default.fileExists(atPath: archiveURL.path) {
            try FileManager.default.removeItem(atPath: archiveURL.path)
        }
        let propertyListEncoder = PropertyListEncoder()
        let encodedLocations = try propertyListEncoder.encode(locations)
        try encodedLocations.write(to: archiveURL, options: .noFileProtection)
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
        case invalidResponse
        case stringConversionFailed
        case csvConversionFailed
    }
}

class MockRecyclingLocationService: RecyclingLocationServicing {
    func fetchLocations() async throws -> [RecyclingLocation] {
        .mockData
    }
}
