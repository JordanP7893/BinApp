//
//  BinView.swift
//  BinApp
//
//  Created by Jordan Porter on 28/08/2023.
//  Copyright © 2023 Jordan Porter. All rights reserved.
//

import SwiftUI

struct BinView: View {
    @EnvironmentObject var binProvider: BinDaysProvider
    @State var showNotificationSheet = false

    var body: some View {
        BinListView(bins: $binProvider.binDays)
        .refreshable {
            _ = try? await binProvider.fetchDataFromTheNetwork(usingId: 740711)
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {

                } label: {
                    Image(systemName: "location.magnifyingglass")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showNotificationSheet = true
                } label: {
                    Image(systemName: "bell.fill")
                }

            }
        })
        .navigationTitle("6 Cragg Terrace")
        .task {
            binProvider.fetchNotifications()
            try? await binProvider.fetchBinDays(addressID: 740711)
        }
        .onChange(of: binProvider.binNotifications) { _ in
            Task {
                await binProvider.updateNotifications()
            }
        }
        .sheet(isPresented: $showNotificationSheet,
               content: {
            NavigationView {
                BinNotificationList(
                    showNotificationSheet: $showNotificationSheet,
                    notifications: binProvider.binNotifications
                )
            }
        })
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
