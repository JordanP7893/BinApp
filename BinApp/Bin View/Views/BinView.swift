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

                } label: {
                    Image(systemName: "bell.fill")
                }

            }
        })
        .navigationTitle("6 Cragg Terrace")
        .task {
            try? await binProvider.fetchBinDays(addressID: 740711)
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
