// ArchivingService.swift
// BinApp
//
// Created to provide generic, reusable archiving (saving/loading) of Codable types to disk at any URL.

import Foundation

protocol ArchivingService {
    func save<T: Codable>(_ object: T, to url: URL) throws
    func load<T: Codable>(from url: URL, as type: T.Type) throws -> T
    func getArchiveUrl(withName name: String) -> URL
}

class DefaultArchivingService: ArchivingService {
    func save<T: Codable>(_ object: T, to url: URL) throws {
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(object)
        try data.write(to: url, options: .noFileProtection)
    }

    func load<T: Codable>(from url: URL, as type: T.Type) throws -> T {
        guard FileManager.default.fileExists(atPath: url.path) else { throw ServiceErrors.invalidURL }
        let data = try Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        return try decoder.decode(type, from: data)
    }
    
    func getArchiveUrl(withName name: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(name).appendingPathExtension("plist")
    }
}

extension DefaultArchivingService {
    enum ServiceErrors: Error {
        case invalidURL
    }
}
