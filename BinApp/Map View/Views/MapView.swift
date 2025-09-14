//
//  MapView.swift
//  BinApp
//
//  Created by Jordan Porter on 16/08/2024.
//  Copyright © 2024 Jordan Porter. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Environment(\.locationManager) var locationManager
    @State var viewModel: MapViewViewModel
    
    @State var sheetHeight: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $viewModel.mapCamera, selection: $viewModel.selectedLocation) {
                    ForEach(viewModel.locationsFiltered) { location in
                        Marker(
                            location.name,
                            image: viewModel.selectedRecyclingType.rawValue,
                            coordinate: location.coordinates
                        )
                            .tint(viewModel.selectedRecyclingType.colour)
                            .tag(location)
                    }
                    UserAnnotation()
                }
                .onMapCameraChange { viewModel.mapCentreTracked = $0.region.center }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
            }
            .sheet(item: $viewModel.selectedLocation) {
                RecyclingLocationCardView(recyclingLocation: $0)
                    .presentationDetents([.height(sheetHeight)])
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    sheetHeight = max(proxy.size.height, 160)
                                }
                        }
                    )
            }
            .navigationTitle("Recycling Centres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: toolbarContent)
            .alert("Error", isPresented: $viewModel.showError, presenting: viewModel.errorMessage) { _ in
                Button("OK") { viewModel.errorMessage = nil }
            } message: { message in
                Text(message)
            }
            .task {
                locationManager.startLocationServices()
                await viewModel.loadLocations()
            }
            .task(id: locationManager.userLocation) {
                viewModel.changeOf(userLocation: locationManager.userLocation)
            }
        }
    }
}

extension MapView {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Menu {
                ForEach(RecyclingType.allCases, id: \.self) { type in
                    Button {
                        viewModel.selectedRecyclingType = type
                    } label: {
                        Label(type.description, systemImage: type.iconName)
                    }
                }
            } label: {
                Label(
                    viewModel.selectedRecyclingType.description,
                    systemImage: viewModel.selectedRecyclingType.iconName
                )
            }
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            NavigationLink {
                RecyclingLocationList(
                    recyclingTypeName: viewModel.selectedRecyclingType.description,
                    recyclingLocations: viewModel.locationsFiltered
                )
            } label: {
                Image(systemName: "list.bullet")
            }
        }
    }
}

#Preview {
    NavigationView {
        MapView(viewModel: MapViewViewModel(recyclingLocationService: MockRecyclingLocationService()))
    }
    .environment(\.locationManager, LocationManager())
}
