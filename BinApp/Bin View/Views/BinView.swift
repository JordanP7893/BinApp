//
//  BinView.swift
//  BinApp
//
//  Created by Jordan Porter on 28/08/2023.
//  Copyright © 2023 Jordan Porter. All rights reserved.
//

import SwiftUI
import MapKit

struct BinView: View {
    @EnvironmentObject var binProvider: BinDaysProvider
    @State var showAddressSheet = false
    @State var showNotificationSheet = false

    var body: some View {
        BinListView(bins: $binProvider.binDays)
        .refreshable {
            if let address = binProvider.address {
                _ = try? await binProvider.fetchDataFromTheNetwork(usingId: address.id)
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showAddressSheet = true
                } label: {
                    Image(systemName: "location.magnifyingglass")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showNotificationSheet = true
                } label: {
                    Image(systemName: "bell")
                }

            }
        })
        .navigationTitle(binProvider.address?.title ?? "Bin Days")
        .task {
            if let address = binProvider.address {
                binProvider.fetchNotifications()
                try? await binProvider.fetchBinDays(addressID: address.id)
            }
        }
        .sheet(isPresented: $showAddressSheet) {
            NavigationView {
                BinAddressView()
            }
        }
        .sheet(isPresented: $showNotificationSheet) {
            NavigationView {
                BinNotificationList(
                    showNotificationSheet: $showNotificationSheet,
                    notifications: binProvider.binNotifications
                )
            }
        }
    }
}

struct BinView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BinView()
                .environmentObject(BinDaysProvider())
        }
    }
}
