//
//  MapView.swift
//  BinApp
//
//  Created by Jordan Porter on 16/08/2024.
//  Copyright © 2024 Jordan Porter. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView<ViewModel: MapViewProtocol>: View {
    @State var viewModel: ViewModel
    @State var locationManager = LocationManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $viewModel.mapCamera) {
                    ForEach(viewModel.locationsFiltered) { location in
                        Marker(location.name, image: viewModel.selectedRecyclingType.description.lowercased(), coordinate: location.coordinates)
                            .tint(viewModel.selectedRecyclingType.colour)
                    }
                    UserAnnotation()
                }
                .onMapCameraChange {
                    viewModel.mapCentreTracked = $0.region.center
                }
                .mapControls {
                    MapUserLocationButton()
                }
            }
            .toolbar(content: {
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
            })
            .task {
                await viewModel.getLocations()
            }
            .task(id: locationManager.userLocation) {
                if let location = locationManager.userLocation, viewModel.mapCamera == .automatic {
                    viewModel.mapCamera = .region(.init(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000))
                }
            }
            .onAppear {
                locationManager.startLocationServices()
            }
        }
    }
}

class MockMapViewModel: MapViewProtocol {
    var locations: [RecyclingLocation] = []
    var locationsFiltered: [RecyclingLocation] = [RecyclingLocation].mockData
    var selectedRecyclingType: RecyclingType = .glass
    var mapCamera: MapCameraPosition = .automatic
    var mapCentreTracked: CLLocationCoordinate2D = .leedsCityCentre
    
    func getLocations() async {
        locations = [RecyclingLocation].mockData
        locationsFiltered = locations
    }
    
    func locationsFiltered(by type: RecyclingType) -> [RecyclingLocation] {
        locations
    }
}

#Preview {
    NavigationView {
        MapView(viewModel: MockMapViewModel())
    }
}
