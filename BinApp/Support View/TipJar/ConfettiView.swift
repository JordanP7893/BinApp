//
//  ConfettiView.swift
//  BinApp
//
//  Created by Jordan Porter on 09/01/2026.
//  Copyright © 2026 Jordan Porter. All rights reserved.
//
import SwiftUI

struct ConfettiView: View {
    @Binding var isPresented: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<80, id: \.self) { i in
                    if isPresented {
                        ConfettiParticle(
                            frameWidth: geometry.size.width,
                            yEnd: geometry.size.height + 30
                        )
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct ConfettiParticle: View {
    // Get the frame width for each particle
    let frameWidth: CGFloat
    // Randomize each particle's start and end positions
    let startX: CGFloat = CGFloat.random(in: 0...1)
    let endX: CGFloat = CGFloat.random(in: -0.2...1.2)
    let yEnd: CGFloat
    private let color = [Color.red, .blue, .green, .yellow, .purple, .orange].randomElement()!
    @State private var animationTrigger = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 12, height: 12)
            .position(x: frameWidth * (animationTrigger ? endX : startX),
                      y: animationTrigger ? yEnd : -200)
            .onAppear {
                withAnimation(.easeOut(duration: Double.random(in: 1...2))) {
                    animationTrigger = true
                }
            }
    }
}

#Preview {
    ConfettiView(isPresented: .constant(true))
}
