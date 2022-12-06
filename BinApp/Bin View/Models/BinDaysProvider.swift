//
//  BinDaysProvider.swift
//  BinApp
//
//  Created by Jordan Porter on 28/11/2022.
//  Copyright © 2022 Jordan Porter. All rights reserved.
//

import Foundation

@MainActor
class BinDaysProvider: ObservableObject {
    
    @Published var binDays: [BinDays] = []
    
    let binDaysDataController = BinDaysDataController()
    let errorAlertController = ErrorAlertController()
    
    func fetchBinDays(addressID: Int) async throws -> [BinDays] {
        if let binDays = binDaysDataController.fetchBinData() {
            return binDays
        } else {
            return try await fetchDataFromTheNetwork(usingId: addressID)
        }
    }
    
    func fetchDataFromTheNetwork(usingId addressID: Int) async throws -> [BinDays] {
        let binDays = try await binDaysDataController.fetchBinDates(id: addressID)
        return binDays
    }
    
    
}
