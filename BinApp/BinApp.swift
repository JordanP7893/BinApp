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
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @State var locationManager = LocationManager()
    @State var tipStore = TipStore()
    @State var tabSelection: TabSelection = .binList
    @State var selectBinID: String?
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $tabSelection) {
                BinListView(
                    viewModel: BinListViewModel(
                        addressDataService: BinAddressDataService(),
                        binDaysDataService: delegate.binDaysDataService,
                        notificationDataService: NotificationDataService(),
                        userNotificationService: delegate.notificationDataService,
                    ),
                    selectedBinID: $selectBinID
                )
                    .tabItem { Label("Bin Days", image: "waste") }
                    .tag(TabSelection.binList)
                
                MapView(
                    viewModel: MapViewViewModel(
                        recyclingLocationService: RecyclingLocationService()
                    )
                )
                    .tabItem { Label("Recycling Centres", image: "recycle") }
                    .tag(TabSelection.map)
                
                SupportListView()
                    .tabItem { Label("Support", systemImage: "questionmark.circle") }
                    .tag(TabSelection.support)
            }
            .tint(.init("AppColour"))
            .environment(\.locationManager, locationManager)
            .environmentObject(tipStore)
            .onAppear {
                delegate.app = self
            }
            .task {
                await tipStore.fetchTipProducts()
            }
        }
    }
}

enum TabSelection {
    case binList
    case map
    case support
}
