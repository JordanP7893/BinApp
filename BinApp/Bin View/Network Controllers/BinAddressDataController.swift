//
//  BinAddressDataController.swift
//  BinApp
//
//  Created by Jordan Porter on 27/06/2021.
//  Copyright © 2021 Jordan Porter. All rights reserved.
//

import Foundation

class BinAddressDataController {
    
    func fetchAddress(postcode: String, completion: @escaping ([StoreAddress]?) -> Void) {
        let paramString = BinAddressDataController.getParamString(params: ["postcode": postcode])
        let addressUrl = URL(string: "https://bins.azurewebsites.net/api/getaddress?" + paramString)!
        var success = false
        BinAddressDataController.callGet(url: addressUrl) { message, data in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                if !success {
                    completion(nil)
                }
             })
            
            if let jsonData = data {                
                let decoder = JSONDecoder()
                let escapedData = Data(String(data: jsonData, encoding: .utf8)!.replacingOccurrences(of: "\\u0000", with: "").utf8)

                do {
                    let addresses = try decoder.decode([StoreAddress].self, from: escapedData)
                    success = true
                    completion(addresses)
                } catch {
                    print(error)
                }
            }
        }
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

