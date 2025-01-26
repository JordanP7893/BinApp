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
            List(viewModel.binDays) { bin in
                Button {
                    selectedBin = bin
                } label: {
                    BinCellView(bin: bin)
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
        .onChange(of: viewModel.binDaysDataController.lastUpdate) { _, _ in
            viewModel.onLocalRefresh()
        }
    }
}

#Preview {
    let viewModel = BinListViewModel(
        addressDataController: MockBinAddressDataController(),
        binDaysDataController: MockBinDaysDataController(),
        notificationDataController: MockNotificationDataController()
    )
    
    NavigationView {
        BinListView(viewModel: viewModel, selectedBinID: .constant(nil))
            .environment(LocationManager())
    }
}
