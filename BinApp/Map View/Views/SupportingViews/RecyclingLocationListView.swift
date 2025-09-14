//
//  RecyclingLocationList.swift
//  BinApp
//
//  Created by Jordan Porter on 13/10/2024.
//  Copyright © 2024 Jordan Porter. All rights reserved.
//

import SwiftUI
import MapKit

struct RecyclingLocationList: View {
    @Environment(\.locationManager) var locationManager
    @State var selected: RecyclingLocation?
    
    let recyclingTypeName: String
    let recyclingLocations: [RecyclingLocation]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            List(recyclingLocations, id: \.self, selection: $selected) { recyclingLocation in
                RecyclingLocationInfoView(
                    recyclingLocation: recyclingLocation
                )
            }
            .listStyle(.inset)
            
            if let selected {
                if #available(iOS 26.0, *) {
                    RecyclingLocationDirectionButton(recyclingLocation: selected, isCompact: false)
                        .shadow(radius: 20)
                        .padding()
                        .buttonStyle(.glassProminent)
                } else {
                    RecyclingLocationDirectionButton(recyclingLocation: selected, isCompact: false)
                        .shadow(radius: 20)
                        .padding()
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle(recyclingTypeName)
    }
}

#Preview {
    NavigationView {
        RecyclingLocationList(recyclingTypeName: "Glass", recyclingLocations: .mockData)
            .environment(\.locationManager, LocationManager())
    }
}
