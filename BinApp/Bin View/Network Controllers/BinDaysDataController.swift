//
//  BinDaysDataController.swift
//  BinApp
//
//  Created by Jordan Porter on 09/03/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation


class BinDaysDataController {
    
    func fetchBinDates(id: Int) async throws -> [BinDays] {
        let paramString = BinAddressDataController.getParamString(params: ["premisesid": id, "localauthority": "Leeds"])
        let binDatesUrl = URL(string: "https://bins.azurewebsites.net/api/getcollections?" + paramString)!
        
        do {
            let data = try await asyncGET(url: binDatesUrl)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(formatter)
            
            let binDates = try decoder.decode([BinDays].self, from: data)
            self.saveBinData(binDates)
            return binDates
            
        } catch {
            
            throw error
        }
    }
    
    func saveBinData(_ binDays: [BinDays]) {
        if binDays.isEmpty { return }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("bin_data").appendingPathExtension("plist")
        
        if FileManager.default.fileExists(atPath: archiveURL.path){
            try? FileManager.default.removeItem(atPath: archiveURL.path)
        }
        
        let propertyListEncoder = PropertyListEncoder()
        let encodedBinDays = try? propertyListEncoder.encode(binDays)
        try? encodedBinDays?.write(to: archiveURL, options: .noFileProtection)
    }
    
    func fetchBinData() -> [BinDays]? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("bin_data").appendingPathExtension("plist")
        
        guard (archiveURL.isThisURL(lessThanDaysOld: 7)) else { return nil }
        
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedBinDays = try? Data(contentsOf: archiveURL), let decodedBinDays = try? propertyListDecoder.decode([BinDays].self, from: retrievedBinDays){
            if decodedBinDays.isEmpty { return nil }
            
            return decodedBinDays
        } else {
            return nil
        }
    }
    
    func asyncGET(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw AlertError(title: "Network Connection Error", body: "Could not retrieve bin data. Please check your connection and try again")
            }
            return data
        } catch {
            throw AlertError(title: "Network Connection Error", body: "Could not retrieve bin data. Please check your connection and try again")
        }
    }
}

