//
//  BinAddressDataController.swift
//  BinApp
//
//  Created by Jordan Porter on 27/06/2021.
//  Copyright © 2021 Jordan Porter. All rights reserved.
//

import Foundation

class BinAddressDataController {
    func fetchAddress(postcode: String) async throws -> [StoreAddress] {
        let postcodeToSearch = postcode.replacingOccurrences(of: " ", with: "")
        let paramString = BinAddressDataController.getParamString(params: ["postcode": postcodeToSearch])
        let addressUrl = URL(string: "https://bins.azurewebsites.net/api/getaddress?" + paramString)!

        let data = try await BinDaysDataController.asyncGET(url: addressUrl)
        
        let decoder = JSONDecoder()
        let addresses = try decoder.decode([StoreAddress].self, from: data)

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

    static func callGet(url:URL, complete: @escaping ((message:String, data:Data?)) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        var result:(message:String, data:Data?) = (message: "Fail", data: nil)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if(error != nil)
            {
                result.message = "Fail Error not null : \(error.debugDescription)"
            }
            else
            {
                result.message = "Success"
                result.data = data
            }

            complete(result)
        }
        task.resume()
    }
    
    func saveAddressData(_ addresses: AddressData) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("address_data").appendingPathExtension("plist")
        
        if FileManager.default.fileExists(atPath: archiveURL.path){
            try? FileManager.default.removeItem(atPath: archiveURL.path)
        }
        
        let propertyListEncoder = PropertyListEncoder()
        let encodedLocations = try? propertyListEncoder.encode(addresses)
        try? encodedLocations?.write(to: archiveURL, options: .noFileProtection)
    }
    
    func fetchAddressData() -> AddressData? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("address_data").appendingPathExtension("plist")
        
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedAddresses = try? Data(contentsOf: archiveURL), let decodedAddresses = try? propertyListDecoder.decode(AddressData.self, from: retrievedAddresses){
            return decodedAddresses
        } else {
            return nil
        }
    }
}

