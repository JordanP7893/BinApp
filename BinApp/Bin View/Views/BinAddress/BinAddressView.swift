//
//  BinAddressView.swift
//  BinApp
//
//  Created by Jordan Porter on 27/11/2023.
//  Copyright © 2023 Jordan Porter. All rights reserved.
//

import SwiftUI
import CoreLocation

@MainActor
struct BinAddressView: View {
    enum LocationButtonState {
        case active
        case loading
        case notPressed
    }

    @Environment(\.dismiss) var dismiss
    @Environment(\.locationManager) var locationManager

    @StateObject var viewModel = BinAddressViewModel()
    
    var onSavePress: (_ saveAddress: StoreAddress) -> Void
    
    @State var locationButtonState: LocationButtonState = .notPressed

    var body: some View {
        ZStack(alignment: .bottom) {
            BinAddressMapView(mapPosition: $viewModel.mapCamera, point: viewModel.point)

            VStack(alignment: .center) {
                HStack(spacing: 20.0) {
                    Button(action: {
                        locationButtonState = .loading
                        locationManager.startLocationServices()
                        Task {
                            try? await Task.sleep(nanoseconds: 5_000_000_000)
                            if self.locationButtonState == .loading {
                                self.locationButtonState = .notPressed
                            }
                        }
                    }, label: {
                        locationButtonLabel
                    })
                    .disabled(locationButtonState == .loading)

                    TextField("Search", text: $viewModel.searchText)
                        .textInputAutocapitalization(.characters)
                        .textContentType(.postalCode)
                        .onSubmit {
                            Task {
                                await viewModel.searchFor(postcode: viewModel.searchText)
                            }
                        }
                }
                if let addresses = viewModel.addresses {
                    Picker("Choose Address", selection: $viewModel.selectedAddressIndex) {
                        ForEach(addresses.indices, id: \.self) { index in
                            Text(addresses[index].formattedAddress)
                        }
                    }
                }
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding()
        }
        .navigationTitle("Find Your Address")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: locationManager.userPostcode) {
            if let userPostcode = locationManager.userPostcode, locationButtonState == .loading {
                viewModel.searchText = userPostcode
                Task {
                    await viewModel.searchFor(postcode: userPostcode)
                    locationButtonState = .active
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError, presenting: viewModel.errorMessage) { message in
            Button("OK") { viewModel.clearError() }
        } message: { message in
            Text(message)
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Cancel")
                })
            }

            ToolbarItem {
                Button(action: {
                    dismiss()
                    
                    guard let addresses = viewModel.addresses else { return }
                    let address = addresses[viewModel.selectedAddressIndex]
                    onSavePress(address)
                }, label: {
                    Text("Save")
                        .bold()
                })
                .disabled(viewModel.addresses?.isEmpty ?? true)
            }
        })
    }

    @ViewBuilder
    var locationButtonLabel: some View {
        switch locationButtonState {
        case .active:
            Image(systemName: "location.fill")
        case .loading:
            ProgressView()
        case .notPressed:
            Image(systemName: "location")
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    
    Text("Bin Address")
        .sheet(
            isPresented: $isPresented,
            content: {
                NavigationView {
                    BinAddressView(onSavePress: { _ in })
                }
            })
        .environment(\.locationManager, LocationManager())
}
