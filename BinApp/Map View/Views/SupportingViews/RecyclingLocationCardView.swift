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
        VStack(alignment: .trailing) {
            HStack(spacing: 20) {
                RecyclingLocationInfoView(recyclingLocation: recyclingLocation)
                
                RecyclingLocationDirectionButton(recyclingLocation: recyclingLocation, isCompact: true)
                    .frame(width: 100)
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

#Preview {
    @Previewable @State var sheetHeight: CGFloat = 0
    
    Color.blue.opacity(0.3)
        .sheet(isPresented: .constant(true)) {
            RecyclingLocationCardView(recyclingLocation: .mockData)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                sheetHeight = max(proxy.size.height, 160)
                            }
                    }
                )
                .presentationDetents([.height(sheetHeight)])
                .environment(\.locationManager, LocationManager())
        }
}
