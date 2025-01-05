//
//  BinDaysDataController.swift
//  BinApp
//
//  Created by Jordan Porter on 09/03/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation

protocol BinDaysDataProtocol {
    func fetchNetworkBinDays(id: Int) async throws -> [BinDays]
    func fetchLocalBinDays() throws -> [BinDays]
    func saveBinData(_ binDays: [BinDays]) throws
}

class BinDaysDataController: BinDaysDataProtocol {
    func fetchNetworkBinDays(id: Int) async throws -> [BinDays] {
        let paramString = BinAddressDataController.getParamString(params: ["premisesid": id, "localauthority": "Leeds"])
        let binDatesUrl = URL(string: "https://bins.azurewebsites.net/api/getcollections?" + paramString)!
        
        do {
            let data = try await BinDaysDataController.asyncGET(url: binDatesUrl)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(formatter)
            
            let binDates = try decoder.decode([BinDays].self, from: data)
//            let uniqueBinDates = Array(Set(binDates))
//            let binsWithPending = updateFetchedBinsWithPendingStates(uniqueBinDates)
//            self.saveBinData(binsWithPending)
//            UserDefaults.standard.setValue(Date(), forKey: "binDaysLastFetchedDate")
            return binDates.sorted { $0.date < $1.date }
            
        } catch {
            
            throw error
        }
    }
    
    func saveBinData(_ binDays: [BinDays]) throws {
        if binDays.isEmpty { return }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("bin_data_v2").appendingPathExtension("plist")
        
        if FileManager.default.fileExists(atPath: archiveURL.path){
            try FileManager.default.removeItem(atPath: archiveURL.path)
        }
        
        let propertyListEncoder = PropertyListEncoder()
        let encodedBinDays = try propertyListEncoder.encode(binDays)
        try encodedBinDays.write(to: archiveURL, options: .noFileProtection)
    }
    
    func fetchLocalBinDays() throws -> [BinDays] {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("bin_data_v2").appendingPathExtension("plist")
        
        let propertyListDecoder = PropertyListDecoder()
        let retrievedBinDays = try Data(contentsOf: archiveURL)
        let decodedBinDays = try propertyListDecoder.decode([BinDays].self, from: retrievedBinDays)
        if decodedBinDays.isEmpty { throw BinError.emptyBinArray }
        print("fetch \(decodedBinDays.first?.notificationEvening?.description)")
        return decodedBinDays
    }
    
    static func asyncGET(url: URL) async throws -> Data {
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
    
//    private func updateFetchedBinsWithPendingStates(_ fetchedBins: [BinDays]) -> [BinDays] {
//        var newBins = fetchedBins
//        guard let currentBins = fetchBinData(skipDateCheck: true) else { return newBins }
//        
//        let pendingBinIds = currentBins.filter({ $0.isPending }).map({$0.id})
//        
//        pendingBinIds.forEach { id in
//            if let index = newBins.firstIndex(where: {$0.id == id}) {
//                newBins[index].isPending = true
//            }
//        }
//        
//        return newBins
//    }
}

enum BinError: Error {
    case emptyBinArray
}

class MockBinDaysDataController: BinDaysDataProtocol {
    func fetchNetworkBinDays(id: Int) async throws -> [BinDays] {
        BinDays.testBinsArray
    }
    
    func fetchLocalBinDays() throws -> [BinDays] {
        BinDays.testBinsArray
    }
    
    func saveBinData(_ binDays: [BinDays]) throws {}
}
