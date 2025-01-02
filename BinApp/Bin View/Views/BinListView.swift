//
//  BinView.swift
//  BinApp
//
//  Created by Jordan Porter on 28/08/2023.
//  Copyright © 2023 Jordan Porter. All rights reserved.
//

import SwiftUI
import MapKit

struct BinListView: View {
    @StateObject var viewModel: BinListViewModel
    
    @State var showAddressSheet = false
    @State var showNotificationSheet = false

    var body: some View {
        NavigationStack {
            List($viewModel.binDays) { bin in
                NavigationLink {
                    BinDetailView(bin: bin, donePressed: {}, remindPressed: { _ in }, tonightPressed: {})
                } label: {
                    BinCellView(bin: bin)
                }
            }
            .listStyle(.inset)
                .refreshable {
                    await viewModel.onRefresh()
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
                .navigationTitle(viewModel.address?.title ?? "Bin Days")
                .task {
                    await viewModel.onAppear()
                }
                .sheet(isPresented: $showAddressSheet) {
                    NavigationView {
                        BinAddressView(onSavePress: viewModel.onSavePress(address:))
                    }
                }
                .sheet(isPresented: $showNotificationSheet) {
                    NavigationView {
                        BinNotificationList(
                            showNotificationSheet: $showNotificationSheet,
                            notifications: $viewModel.binNotifications
                        )
                    }
                }
        }
    }
}

#Preview {
    NavigationView {
        BinListView(
            viewModel: .init(
                addressDataController: MockBinAddressDataController(),
                binDaysDataController: MockBinDaysDataController(),
                notificationDataController: MockNotificationDataController()
            )
        )
            .environment(LocationManager())
    }
}
