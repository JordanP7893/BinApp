//
//  BinDaysDataService.swift
//  BinApp
//
//  Created by Jordan Porter on 09/03/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation

protocol BinDaysDataProtocol {
    var lastUpdate: Date? { get }
    func fetchNetworkBinDays(id: Int) async throws -> [BinDays]
    func fetchLocalBinDays() throws -> [BinDays]
    func saveBinData(_ binDays: [BinDays]) throws
}

class BinDaysDataService: BinDaysDataProtocol {
    @Published var lastUpdate: Date?
    
    func fetchNetworkBinDays(id: Int) async throws -> [BinDays] {
        let paramString = BinAddressDataService.getParamString(params: ["premisesid": id, "localauthority": "Leeds"])
        let binDatesUrl = URL(string: "https://bins.azurewebsites.net/api/getcollections?" + paramString)!
        
        let data = try await BinDaysDataService.asyncGET(url: binDatesUrl)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        let fetchedBinDays = try decoder.decode([BinDays].self, from: data)
        let currentAndNewBins = addOnlyNewFetchedBins(fetchedBinDays)
        
        return currentAndNewBins.sorted { $0.date < $1.date }
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
        
        lastUpdate = .now
    }
    
    func fetchLocalBinDays() throws -> [BinDays] {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("bin_data_v2").appendingPathExtension("plist")
        
        let propertyListDecoder = PropertyListDecoder()
        let retrievedBinDays = try Data(contentsOf: archiveURL)
        let decodedBinDays = try propertyListDecoder.decode([BinDays].self, from: retrievedBinDays)
        if decodedBinDays.isEmpty { throw BinError.emptyBinArray }
        
        let today = Calendar.current.startOfDay(for: Date())
        let binDays = decodedBinDays.filter { $0.date >= today }
        
        if binDays.count < 6 {
            throw BinError.outdatedData
        }
        
        return binDays
    }
    
    static func asyncGET(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BinError.invalidResponse
        }
        
        guard httpResponse.statusCode < 300 else {
            throw BinError.errorCode(httpResponse.statusCode)
        }
        
        return data
    }
    
    public func updateBinDateFor(bin id: String, to date: Date, isMorningDate: Bool) throws {
        var bins = try fetchLocalBinDays()
        if let index = bins.firstIndex(where: {$0.id == id}) {
            if isMorningDate {
                bins[index].notificationMorning = date
            } else {
                bins[index].notificationEvening = date
            }
        }
        try saveBinData(bins)
    }
    
    public func markAsDoneFor(bin id: String) throws {
        var bins = try fetchLocalBinDays()
        if let index = bins.firstIndex(where: {$0.id == id}) {
            bins[index].donePressed()
        }
        try saveBinData(bins)
    }
    
    private func addOnlyNewFetchedBins(_ fetchedBins: [BinDays]) -> [BinDays] {
        guard let currentBins = try? fetchLocalBinDays() else { return fetchedBins }
        
        let stillValidBins = currentBins.filter { currentBin in
            fetchedBins.contains { $0.id == currentBin.id }
        }
        
        let newFetchedBins = fetchedBins.filter { fetchedBin in
            !currentBins.contains { $0.id == fetchedBin.id }
        }
        
        return stillValidBins + newFetchedBins
    }
}

enum BinError: Error {
    case emptyBinArray
    case invalidResponse
    case errorCode(Int)
    case outdatedData
}

class MockBinDaysDataService: BinDaysDataProtocol {
    var shouldFail: Bool
    
    init(shouldFail: Bool = false) {
        self.shouldFail = shouldFail
    }
    
    var lastUpdate: Date?
    
    func fetchNetworkBinDays(id: Int) async throws -> [BinDays] {
        guard !shouldFail else {
            throw BinError.emptyBinArray
        }
        
        return BinDays.testBinsArray
    }
    
    func fetchLocalBinDays() throws -> [BinDays] {
        guard !shouldFail else {
            throw BinError.emptyBinArray
        }
        
        return BinDays.testBinsArray
    }
    
    func saveBinData(_ binDays: [BinDays]) throws {}
}
