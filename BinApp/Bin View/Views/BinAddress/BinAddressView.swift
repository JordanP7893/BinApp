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
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var binProvider: BinDaysProvider

    @StateObject var viewModel = BinAddressViewModel()

    var body: some View {
        VStack {
            HStack(spacing: 20.0) {
                Button(action: {
                    viewModel.searchText = "LS19 6LF"
                    Task {
                        try await viewModel.retrieveRegionFromPostcode()
                    }
                }, label: {
                    Image(systemName: "location")
                })

                VStack(alignment: .trailing) {
                    TextField("Search", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.characters)
                        .textContentType(.postalCode)
                        .onSubmit {
                            Task {
                                try await viewModel.retrieveRegionFromPostcode()
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

            }
            .padding()

            BinAddressMapView(mapPosition: $viewModel.mapCamera, point: viewModel.point)
        }
        .navigationTitle("Address")
        .navigationBarTitleDisplayMode(.inline)
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
                    Task {
                        guard let addresses = viewModel.addresses else { return }
                        try await binProvider.fetchDataFromTheNetwork(usingId: addresses[viewModel.selectedAddressIndex].premisesId)
                        dismiss()
                    }
                }, label: {
                    Text("Save")
                        .bold()
                })
            }
        })
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
                        BinAddressView()
                    }
                })
        }
    }
    return PreviewView()
}
