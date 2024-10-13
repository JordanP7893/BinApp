//
//  RecyclingLocationList.swift
//  BinApp
//
//  Created by Jordan Porter on 13/10/2024.
//  Copyright © 2024 Jordan Porter. All rights reserved.
//

import SwiftUI

struct RecyclingLocationList: View {
    let recyclingLocations: [RecyclingLocation]
    
    var body: some View {
        List(recyclingLocations) { recyclingLocation in
            RecyclingLocationCardView(recyclingLocation: recyclingLocation)
                .buttonStyle(PlainButtonStyle())
        }
        .listStyle(.inset)
    }
}

#Preview {
    RecyclingLocationList(recyclingLocations: .mockData)
}
