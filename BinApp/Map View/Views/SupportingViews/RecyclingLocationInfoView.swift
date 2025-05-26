//
//  RecyclingLocationInfo.swift
//  BinApp
//
//  Created by Jordan Porter on 20/12/2024.
//  Copyright © 2024 Jordan Porter. All rights reserved.
//

import SwiftUI

struct RecyclingLocationInfoView: View {
    var recyclingLocation: RecyclingLocation
    
    var body: some View {
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
                }
                Spacer()
                
                RecyclingIconStackView(recyclingTypes: recyclingLocation.types)
            }
        }
    }
}

#Preview {
    RecyclingLocationInfoView(recyclingLocation: .mockData)
        .padding()
}
