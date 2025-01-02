//
//  BinAddressView.swift
//  BinApp
//
//  Created by Jordan Porter on 27/11/2023.
//  Copyright © 2023 Jordan Porter. All rights reserved.
//

import SwiftUI
import CoreLocation

struct BinAddressView: View {
    enum LocationButtonState {
        case active
        case loading
        case notPressed
    }

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var locationManager: LocationManager

    @StateObject var viewModel = BinAddressViewModel()
    
    var onSavePress: (_ saveAddress: StoreAddress) -> Void
    
    @State var locationButtonState: LocationButtonState = .notPressed

    var body: some View {
        ZStack(alignment: .top) {
            BinAddressMapView(mapPosition: $viewModel.mapCamera, point: viewModel.point)

            VStack(alignment: .trailing) {
                HStack(spacing: 20.0) {
                    Button(action: {
                        locationButtonState = .loading
                        locationManager.startLocationServices()
                    }, label: {
                        locationButtonLabel
                    })
                    .disabled(locationButtonState == .loading)

                    TextField("Search", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.characters)
                        .textContentType(.postalCode)
                        .onSubmit {
                            Task {
                                try await viewModel.searchFor(postcode: viewModel.searchText)
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
            .background(content: {
                Rectangle()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(.background)
                    .shadow(radius: 5)
            })
            .padding()
        }
        .navigationTitle("Find Your Address")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: locationManager.userPostcode) {
            if let userPostcode = locationManager.userPostcode {
                viewModel.searchText = userPostcode
                Task {
                    try await viewModel.searchFor(postcode: userPostcode)
                    locationButtonState = .active
                }
            }
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
    struct PreviewView: View {
        @State var isPresented = true

        var body: some View {
            Text("Bin Address")
                .sheet(
                    isPresented: $isPresented,
                       content: {
                    NavigationView {
                        BinAddressView(onSavePress: { _ in })
                    }
                })
        }
    }
    return PreviewView()
}
