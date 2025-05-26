//
//  RecyclingLocationDirectionButton.swift
//  BinApp
//
//  Created by Jordan Porter on 24/11/2024.
//  Copyright © 2024 Jordan Porter. All rights reserved.
//

import MapKit
import SwiftUI

struct RecyclingLocationDirectionButton: View {
    @EnvironmentObject var locationManager: LocationManager
    @State var directionData: DirectionService.DirectionData?
    
    var recyclingLocation: RecyclingLocation
    var isCompact: Bool
    
    var body: some View {
        Button {
            let mapItem = MKMapItem(placemark: .init(coordinate: recyclingLocation.coordinates))
            mapItem.name = recyclingLocation.name
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        } label: {
            Group {
                if isCompact {
                    VStack(spacing: 8) {
                        icon
                        directionText
                    }
                } else {
                    HStack(spacing: 8) {
                        icon
                        directionText
                    }
                }
            }
            .frame(height: 80)
            .frame(maxWidth: 200)
            .foregroundStyle(.white)
            .background(.blue)
            .cornerRadius(isCompact ? 10 : 40)
        }
        .task {
            await calculateDirections()
        }
        .onChange(of: recyclingLocation) {
            Task {
                await calculateDirections()
            }
        }
        .animation(.default, value: directionData)
    }
    
    private var icon: some View {
        Image(systemName: "car.fill")
    }
    
    private var directionText: some View {
        Group {
            if let directionData {
                Text(String(format: "%.1f miles", directionData.distance.converted(to: .miles).value))
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(String(format: "%.0f minutes", directionData.duration / 60))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
    }
    
    private func calculateDirections() async {
        directionData = nil
        guard let userLocation = locationManager.userLocation else { return }
        
        do {
            directionData = try await DirectionService().fetchDirections(for: recyclingLocation, from: userLocation)
        } catch {
            print(error)
        }
    }
}

#Preview {
    RecyclingLocationDirectionButton(recyclingLocation: .mockData, isCompact: false)
        .environmentObject(LocationManager())
}
