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
    
    let networkingService: NetworkingService
    let archivingService: ArchivingService
    
    init(networkingService: NetworkingService = DefaultNetworkingService(), archivingService: ArchivingService = DefaultArchivingService()) {
        self.networkingService = networkingService
        self.archivingService = archivingService
    }
    
    func fetchNetworkBinDays(id: Int) async throws -> [BinDays] {
        let data = try await networkingService.fetchData(from: AppConfig.getCollectionsUrl, withParams: ["premisesid": id, "localauthority": "Leeds"])
        
        let fetchedBinDays = try decodeBinDataFrom(data: data)
        let currentAndNewBins = addOnlyNewFetchedBins(fetchedBinDays)
        
        return currentAndNewBins.sorted { $0.date < $1.date }
    }
    
    func saveBinData(_ binDays: [BinDays]) throws {
        if binDays.isEmpty { throw BinError.emptyBinArray }
        
        try archivingService.save(binDays, to: archiveURL)
        
        lastUpdate = .now
    }
    
    func fetchLocalBinDays() throws -> [BinDays] {
        let decodedBinDays = try archivingService.load(from: archiveURL, as: [BinDays].self)
        if decodedBinDays.isEmpty { throw BinError.emptyBinArray }
        
        let today = Calendar.current.startOfDay(for: Date())
        let binDays = decodedBinDays.filter { $0.date >= today }
        
        if binDays.count < 6 {
            throw BinError.outdatedData
        }
        
        return binDays
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
}

extension BinDaysDataService {
    private func addOnlyNewFetchedBins(_ fetchedBins: [BinDays]) -> [BinDays] {
        guard let currentBins = try? fetchLocalBinDays() else { return fetchedBins }
        if fetchedBins.isEmpty { return currentBins }
        
        let stillValidBins = currentBins.filter { currentBin in
            fetchedBins.contains { $0.id == currentBin.id }
        }
        
        let newFetchedBins = fetchedBins.filter { fetchedBin in
            !currentBins.contains { $0.id == fetchedBin.id }
        }
        
        return stillValidBins + newFetchedBins
    }
    
    private var archiveURL: URL {
        archivingService.getArchiveUrl(withName: "bin_data_v2")
    }
    
    private func decodeBinDataFrom(data: Data) throws -> [BinDays] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Europe/London")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        return try decoder.decode([BinDays].self, from: data)
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
