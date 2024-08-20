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
    @State var selectedRecyclingType: RecyclingType = .glass
    @State var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            Map() {
                ForEach(viewModel.locations) {
                    Marker(coordinate: $0.coordinates) {
                        Image("glass")
                    }
                    .tint(.green)
                }
            }
                .toolbar(content: {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        Picker("Recycling type", selection: $selectedRecyclingType) {
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
                            
                        } label: {
                            Image(systemName: "list.bullet")
                        }
                    }
                })
                .task {
                    await viewModel.getLocations()
                }
        }
    }
}

#Preview {
    NavigationView {
        MapView()
    }
}
