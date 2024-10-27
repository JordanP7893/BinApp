//
//  RecyclingLocationCardView.swift
//  BinApp
//
//  Created by Jordan Porter on 13/10/2024.
//  Copyright © 2024 Jordan Porter. All rights reserved.
//

import MapKit
import SwiftUI

struct RecyclingLocationCardView: View {
    @State var viewModel: RecyclingLocationCardViewModel
    
    var body: some View {
        HStack(spacing: 5) {
            VStack(alignment: .leading, spacing: 10) {
                Text(viewModel.recyclingLocation.name)
                    .font(.title3)
                    .bold()
                    .lineLimit(1)
                HStack {
                    if let address = viewModel.recyclingLocation.address, let postcode = viewModel.recyclingLocation.postcode {
                        VStack(alignment: .leading) {
                            Text(address)
                            Text(postcode)
                        }
                        
                        Spacer()
                    }
                        
                    RecyclingIconStackView(recyclingTypes: viewModel.recyclingLocation.types)
                }
            }
            
            Spacer()
            
            Button {
                let mapItem = MKMapItem(placemark: .init(coordinate: viewModel.recyclingLocation.coordinates))
                mapItem.name = viewModel.recyclingLocation.name
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "car.fill")
                    
                    if let drivingDistance = viewModel.recyclingLocation.drivingDistance, let drivingTime = viewModel.recyclingLocation.drivingTime {
                        Text(String(format: "%.1f miles", drivingDistance.converted(to: .miles).value))
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(String(format: "%.0f minutes", drivingTime / 60))
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

        }
        .animation(.default, value: viewModel.recyclingLocation.drivingTime)
        .task {
            await viewModel.getDirections()
        }
    }
}

#Preview {
    RecyclingLocationCardView(viewModel: .init(recyclingLocation: .mockData, locationManger: LocationManager()))
        .padding()
}
