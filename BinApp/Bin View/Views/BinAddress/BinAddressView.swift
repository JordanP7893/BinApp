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
    @Environment(\.dismiss) var dismiss
    @Environment(\.locationManager) var locationManager

    @StateObject var viewModel: BinAddressViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            BinAddressMapView(mapPosition: $viewModel.mapCamera, point: viewModel.point)

            VStack(alignment: .center) {
                HStack(spacing: 20.0) {
                    Button(action: {
                        locationManager.startLocationServices()
                        Task {
                            await viewModel.onLocationButtonTap()
                        }
                    }, label: {
                        locationButtonLabel
                    })
                    .disabled(viewModel.locationButtonState == .loading)

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
            await viewModel.onUserPostcodeUpdate(userPostcode: locationManager.userPostcode)
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
                    if #available(iOS 26, *) {
                        Image(systemName: "xmark")
                    } else {
                        Text("Cancel")
                    }
                })
            }

            ToolbarItem {
                if #available(iOS 26, *) {
                    Button(action: {
                        dismiss()
                        viewModel.onSaveTap()
                    }, label: {
                        Image(systemName: "checkmark")
                    })
                    .disabled(disabledSaveButton)
                } else {
                    Button(action: {
                        dismiss()
                        viewModel.onSaveTap()
                    }, label: {
                        Text("Save")
                            .bold()
                    })
                    .disabled(disabledSaveButton)
                }
            }
        })
    }

    @ViewBuilder
    var locationButtonLabel: some View {
        switch viewModel.locationButtonState {
        case .active:
            Image(systemName: "location.fill")
        case .loading:
            ProgressView()
        case .notPressed:
            Image(systemName: "location")
        }
    }
    
    var disabledSaveButton: Bool {
        viewModel.addresses?.isEmpty ?? true
    }
}

#Preview {
    @Previewable @State var isPresented = true
    
    Text("Bin Address")
        .sheet(
            isPresented: $isPresented,
            content: {
                NavigationView {
                    BinAddressView(viewModel: .init(onSaveCallback: { _ in }))
                }
            })
        .environment(\.locationManager, LocationManager())
}
