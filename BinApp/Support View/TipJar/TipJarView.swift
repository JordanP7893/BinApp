//
//  TipJarView.swift
//  BinApp
//
//  Created by Jordan Porter on 09/01/2026.
//  Copyright © 2026 Jordan Porter. All rights reserved.
//

import SwiftUI

struct TipJarView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var tipStore = TipStore()
    @State var showThankYouText = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "gift.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.accentColor)
                            .padding(16)
                        Text("Enjoying the app?")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                        Text("Your tip helps support ongoing development. Thank you for supporting an independent app!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)

                    VStack(spacing: 0) {
                        ForEach(Array(tipStore.tipProducts.enumerated()), id: \.element.id) { idx, product in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(product.displayName)
                                        .font(.headline)
                                }
                                Spacer()
                                Button {
                                    Task {
                                        await tipStore.purchase(product)
                                    }
                                } label: {
                                    Text(product.displayPrice)
                                        .fontWeight(.semibold)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.accentColor)
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal)
                            if idx < tipStore.tipProducts.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                    
                    if tipStore.showCompleteAnimation {
                        Text("Thank you! 🥳")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .shadow(radius: 10)
                            .opacity(showThankYouText ? 1 : 0)
                            .scaleEffect(showThankYouText ? 1.5 : 0.3)
                            .rotationEffect(.degrees(showThankYouText ? 360 : 0))
                            .transition(.scale.combined(with: .opacity))
                            .animation(.easeInOut(duration: 0.8), value: showThankYouText)
                            .onAppear {
                                withAnimation {
                                    showThankYouText = true
                                }
                            }
                            .onDisappear {
                                showThankYouText = false
                            }
                    }

                    Spacer(minLength: 10)
                }
                .padding(.top, 32)
                .padding(.bottom)
                
                ConfettiView(isPresented: $tipStore.showCompleteAnimation)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "checkmark")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .task {
                await tipStore.fetchTipProducts()
            }
        }
    }
}

#Preview {
    Text("Sheet view").sheet(isPresented: .constant(true)) {
        TipJarView()
    }
}
