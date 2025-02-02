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
    @State var selectedBin: BinDays?
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State var notificationTime: Date?
    @State var showAddressSheet = false
    @State var showNotificationSheet = false

    var body: some View {
        NavigationStack {
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
                        Button {
                            selectedBin = bin
                        } label: {
                            BinCellView(bin: bin)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedBin != nil },
                set: { if !$0 { selectedBin = nil } }
            )) {
                if let selectedBin = selectedBin {
                    BinDetailView(
                        bin: Binding(
                            get: { selectedBin },
                            set: { self.selectedBin = $0 }
                        ),
                        donePressed: {
                            viewModel.onDonePress(for: selectedBin)
                        },
                        remindPressed: {
                            viewModel.onRemindMeLaterPress(at: $0, for: selectedBin)
                        },
                        tonightPressed: {
                            viewModel.onRemindMeTonightPress(for: selectedBin)
                        }
                    )
                }
            }
            .listStyle(.inset)
            .task {
                await viewModel.onAppear()
            }
            .refreshable {
                await viewModel.onRefresh()
            }
            .onChange(of: scenePhase) { _, phase in
                switch phase {
                case .background: viewModel.cancelTimer()
                case .active: viewModel.scheduleTimer()
                default: break
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
            .navigationTitle(viewModel.address?.title ?? "Bin Days")
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
        .onChange(of: selectedBinID) { _, id in
            selectedBin = viewModel.binDays.first { $0.id == id }
        }
        .onChange(of: selectedBin) { _, bin in
            selectedBinID = bin?.id
        }
        .onChange(of: viewModel.binDaysDataService.lastUpdate) { _, _ in
            viewModel.onLocalRefresh()
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
