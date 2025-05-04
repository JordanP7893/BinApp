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
    @Binding var selectedBinID: String?
    @State private var navigationPath = NavigationPath()
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State var showAddressSheet = false
    @State var showNotificationSheet = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if viewModel.address == nil {
                    BinListEmptyView(type: .noAddress) {
                        showAddressSheet = true
                    }
                } else if viewModel.binDays.isEmpty {
                    ScrollView {
                        BinListEmptyView(type: .noBin) {
                            showAddressSheet = true
                        }
                            .containerRelativeFrame(.vertical)
                    }
                } else {
                    List(viewModel.binDays) { bin in
                        NavigationLink(value: bin) {
                            BinCellView(bin: bin)
                        }
                    }
                    .navigationDestination(for: BinDays.self) { bin in
                        BinDetailView(
                            bin: bin,
                            donePressed: { viewModel.onDonePress(for: bin) },
                            remindPressed: { viewModel.onRemindMeLaterPress(at: $0, for: bin) },
                            tonightPressed: { viewModel.onRemindMeTonightPress(for: bin) }
                        )
                    }
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
                    notifications: $viewModel.binNotifications,
                    binTypes: viewModel.binTypes
                )
            }
        }
        .alert("Error", isPresented: $viewModel.showError, presenting: viewModel.errorMessage) { message in
            Button("OK") { viewModel.clearError() }
        } message: { message in
            Text(message)
        }
        .onChange(of: selectedBinID) { _, id in
            let selectedBin = viewModel.binDays.first { $0.id == id }
            guard let selectedBin else { return }
            navigationPath.append(selectedBin)
        }
        .onChange(of: navigationPath) { _, _ in
            selectedBinID = nil
        }
        .onChange(of: viewModel.binDaysDataService.lastUpdate) { _, _ in
            viewModel.onLocalRefresh()
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background: viewModel.cancelTimer()
            case .active: viewModel.scheduleTimer()
            default: break
            }
        }
    }
}

#Preview("Success") {
    let viewModel = BinListViewModel(
        addressDataService: MockBinAddressDataService(),
        binDaysDataService: MockBinDaysDataService(),
        notificationDataService: MockNotificationService()
    )
    
    NavigationView {
        BinListView(viewModel: viewModel, selectedBinID: .constant(nil))
            .environment(LocationManager())
    }
}

#Preview("Empty Address") {
    let viewModel = BinListViewModel(
        addressDataService: MockBinAddressDataService(shouldFail: true),
        binDaysDataService: MockBinDaysDataService(shouldFail: true),
        notificationDataService: MockNotificationService()
    )
    
    return NavigationView {
        BinListView(viewModel: viewModel, selectedBinID: .constant(nil))
            .environment(LocationManager())
    }
}

#Preview("No Bins") {
    let viewModel = BinListViewModel(
        addressDataService: MockBinAddressDataService(),
        binDaysDataService: MockBinDaysDataService(shouldFail: true),
        notificationDataService: MockNotificationService()
    )
    
    return NavigationView {
        BinListView(viewModel: viewModel, selectedBinID: .constant(nil))
            .environment(LocationManager())
    }
}
