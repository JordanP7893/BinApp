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
    let recyclingLocation: RecyclingLocation
    
    var body: some View {
        HStack(spacing: 5) {
            VStack(alignment: .leading, spacing: 10) {
                Text(recyclingLocation.name)
                    .font(.title3)
                    .bold()
                    .lineLimit(1)
                HStack {
                    if let address = recyclingLocation.address, let postcode = recyclingLocation.postcode {
                        VStack(alignment: .leading) {
                            Text(address)
                            Text(postcode)
                        }
                        
                        Spacer()
                    }
                        
                    RecyclingIconStackView(recyclingTypes: recyclingLocation.types)
                }
            }
            
            Spacer()
            
            Button {
                let mapItem = MKMapItem(placemark: .init(coordinate: recyclingLocation.coordinates))
                mapItem.name = recyclingLocation.name
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "car.fill")
                    
                    if let distance = recyclingLocation.distance, let drivingTime = recyclingLocation.drivingTime {
                        Text("\(distance) miles")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("\(drivingTime) mins")
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
    }
}

#Preview {
    RecyclingLocationCardView(recyclingLocation: RecyclingLocation.mockData)
        .padding()
}
