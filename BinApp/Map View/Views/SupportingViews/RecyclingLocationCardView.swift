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
    var recyclingLocation: RecyclingLocation
    
    var body: some View {
        HStack(spacing: 5) {
            RecyclingLocationInfoView(recyclingLocation: recyclingLocation)
            
            Spacer()
            
            RecyclingLocationDirectionButton(recyclingLocation: recyclingLocation)
                .frame(width: 80)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 10)
        .padding()
        .safeAreaPadding(.bottom)
        .transition(.offset(y: 200).combined(with: .opacity))
    }
}

#Preview {
    RecyclingLocationCardView(recyclingLocation: .mockData)
        .environmentObject(LocationManager())
}
