//
//  MapView+ViewModel.swift
//  BinApp
//
//  Created by Jordan Porter on 18/08/2024.
//  Copyright © 2024 Jordan Porter. All rights reserved.
//

import Foundation

extension MapView {
    @Observable
    class ViewModel {
        var locations: [RecyclingLocation] = []
        
        let locationDataContrller = LocationDataController()
        
        func getLocations() async {
            do {
                locations = try await locationDataContrller.fetchLocations()
            } catch {
                print("Handle error \(error)")
            }
        }
    }
}
