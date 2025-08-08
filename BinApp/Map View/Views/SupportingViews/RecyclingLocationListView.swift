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
                RecyclingLocationDirectionButton(recyclingLocation: selected, isCompact: false)
                    .shadow(radius: 20)
                    .padding()
            }
        }
    }
}

#Preview {
    NavigationView {
        RecyclingLocationList(recyclingLocations: .mockData)
            .environment(\.locationManager, LocationManager())
    }
}
