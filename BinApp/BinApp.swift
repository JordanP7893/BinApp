//
//  BinApp.swift
//  BinApp
//
//  Created by Jordan Porter on 28/08/2023.
//  Copyright © 2023 Jordan Porter. All rights reserved.
//

import CoreLocation
import SwiftUI

@main
struct BinApp: App {
    @StateObject private var binProvider = BinDaysProvider()
    @State var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            TabView {
                BinView()
                    .environmentObject(binProvider)
                    .tabItem { Label("Bin Days", image: "waste") }
                
                MapView(viewModel: MapViewViewModel())
                    .tabItem { Label("Recycling Centres", image: "recycle") }
            }
            .tint(.init("AppColour"))
            .environmentObject(locationManager)
        }
    }
}
