//
//  RecyclingIconViewStack.swift
//  BinApp
//
//  Created by Jordan Porter on 13/10/2024.
//  Copyright © 2024 Jordan Porter. All rights reserved.
//

import SwiftUI

struct RecyclingIconStackView: View {
    let recyclingTypes: [RecyclingType]
    
    @State var isOpen: Bool = false
    @State var currentTask: (Task<(), any Error>)?
    
    var body: some View {
        ZStack {
            ForEach(0..<recyclingTypes.count, id: \.self) { index in
                RecyclingIconView(recyclingType: recyclingTypes[index])
                    .offset(x: CGFloat(index) * (isOpen ? -35 : -15))
            }
        }
        .onTapGesture {
            currentTask?.cancel()
            currentTask = Task {
                withAnimation {
                    isOpen.toggle()
                }
                
                try await Task.sleep(for: .milliseconds(2000))
                
                withAnimation {
                    isOpen = false
                }
            }
        }
    }
}

#Preview {
    RecyclingIconStackView(recyclingTypes: [.glass, .paper, .textiles, .electronics])
}
