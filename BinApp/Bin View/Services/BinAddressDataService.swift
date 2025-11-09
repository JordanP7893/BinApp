//
//  BinAddressDataService.swift
//  BinApp
//
//  Created by Jordan Porter on 27/06/2021.
//  Copyright © 2021 Jordan Porter. All rights reserved.
//

import Foundation

protocol BinAddressDataProtocol {
    func fetchAddress(postcode: String) async throws -> [StoreAddress]
    func fetchAddressData() throws -> AddressData
    func saveAddressData(_ addresses: AddressData) throws
}

class BinAddressDataService: BinAddressDataProtocol {
    let networkingService: NetworkingService
    let archivingService: ArchivingService
    
    init(networkingService: NetworkingService = DefaultNetworkingService(), archivingService: ArchivingService = DefaultArchivingService()) {
        self.networkingService = networkingService
        self.archivingService = archivingService
    }
    
    func fetchAddress(postcode: String) async throws -> [StoreAddress] {
        let postcodeToSearch = postcode.replacingOccurrences(of: " ", with: "")
        let data = try await networkingService.fetchData(from: AppConfig.getAddressUrl, withParams: ["postcode": postcodeToSearch])
        
        let decoder = JSONDecoder()
        let escapedData = Data(String(data: data, encoding: .utf8)!.replacingOccurrences(of: "\\u0000", with: "").utf8)
        let addresses = try decoder.decode([StoreAddress].self, from: escapedData)

        return addresses
    }
    
    func saveAddressData(_ addresses: AddressData) throws {
        try archivingService.save(addresses, to: archiveURL)
    }
    
    func fetchAddressData() throws -> AddressData {
        try archivingService.load(from: archiveURL, as: AddressData.self)
    }
}

extension BinAddressDataService {
    private var archiveURL: URL {
        archivingService.getArchiveUrl(withName: "address_data")
    }
}

class MockBinAddressDataService: BinAddressDataProtocol {
    var shouldFail: Bool
    
    init(shouldFail: Bool = false) {
        self.shouldFail = shouldFail
    }
    
    func fetchAddress(postcode: String) async throws -> [StoreAddress] {
        guard !shouldFail else {
            throw DecodingError.typeMismatch(String.self, .init(codingPath: [], debugDescription: ""))
        }
        
        return [.dummy, .dummy2, .dummy3]
    }
    
    
    func fetchAddressData() throws -> AddressData {
        guard !shouldFail else {
            throw DecodingError.typeMismatch(String.self, .init(codingPath: [], debugDescription: ""))
        }
        
        return AddressData(id: 1, title: "1 Leeds Road")
    }
    
    func saveAddressData(_ addresses: AddressData) throws {}
}
