//
//  RecyclingIconView.swift
//  BinApp
//
//  Created by Jordan Porter on 13/10/2024.
//  Copyright © 2024 Jordan Porter. All rights reserved.
//

import SwiftUI

struct RecyclingIconView: View {
    let recyclingType: RecyclingType
    
    var body: some View {
        Image(recyclingType.description.lowercased(), label: Text(recyclingType.description))
            .renderingMode(.template)
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(recyclingType.colour)
                    .overlay(
                        Circle()
                            .strokeBorder(lineWidth: 2)
                            .foregroundStyle(.white)
                    )
            }
            .shadow(radius: 4, y: 3)
    }
}

#Preview {
    RecyclingIconView(recyclingType: .glass)
}
