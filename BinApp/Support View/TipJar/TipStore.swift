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
    @Published var isLoading = false
    @Published var purchaseInProgress: Product?
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
            isLoading = true
            let products = try await Product.products(for: productIDs)
            tipProducts = products.sorted(by: { $0.price < $1.price })
            isLoading = false
        } catch {
            isLoading = false
            print("Failed to fetch products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async {
        do {
            purchaseInProgress = product
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    showCompleteAnimation = true
                    purchaseInProgress = nil
                    return
                case .unverified(let transaction, _):
                    await transaction.finish()
                    showCompleteAnimation = true
                    purchaseInProgress = nil
                    return
                }
            case .pending:
                purchaseInProgress = nil
                return
            default:
                purchaseInProgress = nil
                return
            }
        } catch {
            purchaseInProgress = nil
            print("Purchase failed: \(error)")
        }
    }
}
