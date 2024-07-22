//
//  BinAddressMapView.swift
//  BinApp
//
//  Created by Jordan Porter on 04/12/2023.
//  Copyright © 2023 Jordan Porter. All rights reserved.
//

import SwiftUI
import MapKit

struct BinAddressMapView: View {
    @Binding var mapPosition: MapCameraPosition

    var point: MapPoint?

    var body: some View {
        Map(position: $mapPosition) {
            if let point = point {
                Marker(point.title, coordinate: point.coordinates)
            }
        }
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

#Preview {
    BinAddressMapView(
        mapPosition: .constant(.automatic),
        point: .init(
            title: "6 Cragg",
            coordinates: .init(latitude: 53.8446783, longitude: -1.6895351)
        )
    )
}
