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
    @EnvironmentObject var locationManager: LocationManager
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
                RecyclingLocationDirectionButton(recyclingLocation: selected)
                    .padding()
            }
        }
    }
}

#Preview {
    NavigationView {
        RecyclingLocationList(recyclingLocations: .mockData)
            .environmentObject(LocationManager())
    }
}
