//
//  RecyclingCardBottomStackView.swift
//  BinApp
//
//  Created by Jordan Porter on 18/10/2024.
//  Copyright © 2024 Jordan Porter. All rights reserved.
//

import SwiftUI

struct RecyclingCardBottomStackView: View {
    var selectedLocation: RecyclingLocation
    
    var body: some View {
        RecyclingLocationCardView(recyclingLocation: selectedLocation)
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 10)
            .padding()
            .safeAreaPadding(.bottom)
    }
}

#Preview {
    RecyclingCardBottomStackView(selectedLocation: .mockData)
}
