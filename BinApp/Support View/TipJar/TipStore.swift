//
//  TipStore.swift
//  BinApp
//
//  Created by Jordan Porter on 23/12/2025.
//  Copyright © 2025 Jordan Porter. All rights reserved.
//


import StoreKit

@MainActor
class TipStore: ObservableObject {
    @Published var tipProducts: [Product] = []
    @Published var showCompleteAnimation = false {
        didSet {
            Task {
                try await Task.sleep(nanoseconds: 3_000_000_000)
                showCompleteAnimation = false
            }
        }
    }
    
    let productIDs = [
        "tip_small",
        "tip_medium",
        "tip_large",
        "tip_massive"
    ]
    
    func fetchTipProducts() async {
        do {
            let products = try await Product.products(for: productIDs)
            tipProducts = products.sorted(by: { $0.price < $1.price })
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    showCompleteAnimation = true
                    return
                case .unverified(let transaction, _):
                    await transaction.finish()
                    showCompleteAnimation = true
                    return
                }
            case .pending:
                return
            default:
                return
            }
            // Handle result (success, userCancelled, etc.)
        } catch {
            print("Purchase failed: \(error)")
        }
    }
}
