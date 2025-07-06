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
    
    @State var card1: RecyclingLocation?
    @State var card2: RecyclingLocation?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $viewModel.mapCamera, selection: $viewModel.selectedLocation) {
                    ForEach(viewModel.locationsFiltered) { location in
                        Marker(
                            location.name,
                            image: viewModel.selectedRecyclingType.description.lowercased(),
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
                
                ZStack {
                    if let card1 {
                        RecyclingLocationCardView(recyclingLocation: card1)
                    }
                    
                    if let card2 {
                        RecyclingLocationCardView(recyclingLocation: card2)
                    }
                }
            }
            .onChange(of: viewModel.selectedLocation) {
                if $1 == nil {
                    card1 = nil
                    card2 = nil
                } else if card1 == nil {
                    card1 = $1
                    card2 = nil
                } else {
                    card2 = $1
                    card1 = nil
                }
            }
            .navigationTitle("Recycling Centres")
            .navigationBarTitleDisplayMode(.inline)
            .animation(.easeInOut, value: card1)
            .animation(.easeInOut, value: card2)
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
            Picker("Recycling type", selection: $viewModel.selectedRecyclingType) {
                ForEach(RecyclingType.allCases, id: \.self) { type in
                    HStack {
                        Text(type.description)
                        Spacer()
                    }
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            NavigationLink {
                RecyclingLocationList(recyclingLocations: viewModel.locationsFiltered)
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
