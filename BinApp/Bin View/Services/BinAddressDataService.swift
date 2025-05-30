//
//  BinAddressDataService.swift
//  BinApp
//
//  Created by Jordan Porter on 27/06/2021.
//  Copyright © 2021 Jordan Porter. All rights reserved.
//

import Foundation

protocol BinAddressDataProtocol {
    func fetchAddressData() throws -> AddressData
    func saveAddressData(_ addresses: AddressData) throws
}

class BinAddressDataService: BinAddressDataProtocol {
    func fetchAddress(postcode: String) async throws -> [StoreAddress] {
        let postcodeToSearch = postcode.replacingOccurrences(of: " ", with: "")
        let paramString = BinAddressDataService.getParamString(params: ["postcode": postcodeToSearch])
        let addressUrl = URL(string: "https://bins.azurewebsites.net/api/getaddress?" + paramString)!

        let data = try await BinDaysDataService.asyncGET(url: addressUrl)
        
        let decoder = JSONDecoder()
        let escapedData = Data(String(data: data, encoding: .utf8)!.replacingOccurrences(of: "\\u0000", with: "").utf8)
        let addresses = try decoder.decode([StoreAddress].self, from: escapedData)

        return addresses
    }
    
    static func getParamString(params:[String:Any]) -> String {
        var data = [String]()
        for(key, value) in params
        {
            data.append(key + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }
    
    func saveAddressData(_ addresses: AddressData) throws {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("address_data").appendingPathExtension("plist")
        
        if FileManager.default.fileExists(atPath: archiveURL.path){
            try? FileManager.default.removeItem(atPath: archiveURL.path)
        }
        
        let propertyListEncoder = PropertyListEncoder()
        let encodedLocations = try propertyListEncoder.encode(addresses)
        try encodedLocations.write(to: archiveURL, options: .noFileProtection)
    }
    
    func fetchAddressData() throws -> AddressData {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("address_data").appendingPathExtension("plist")
        
        let propertyListDecoder = PropertyListDecoder()
        let retrievedAddresses = try Data(contentsOf: archiveURL)
        let decodedAddresses = try propertyListDecoder.decode(AddressData.self, from: retrievedAddresses)
        return decodedAddresses
    }
}

class MockBinAddressDataService: BinAddressDataProtocol {
    var shouldFail: Bool
    
    init(shouldFail: Bool = false) {
        self.shouldFail = shouldFail
    }
    
    func fetchAddressData() throws -> AddressData {
        guard !shouldFail else {
            throw DecodingError.typeMismatch(String.self, .init(codingPath: [], debugDescription: ""))
        }
        
        return AddressData(id: 1, title: "1 Leeds Road")
    }
    
    func saveAddressData(_ addresses: AddressData) throws {}
}
