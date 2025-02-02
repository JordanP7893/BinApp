//
//  BinListEmptyView.swift
//  BinApp
//
//  Created by Jordan Porter on 02/02/2025.
//  Copyright © 2025 Jordan Porter. All rights reserved.
//

import SwiftUI

struct BinListEmptyView: View {
    var type: BinListEmptyType
    var showAddressSheet: () -> Void
    
    var body: some View {
        ContentUnavailableView {
            Label(type.title, systemImage: type.imageName)
        } description: {
            Text(type.description)
        } actions: {
            Button(type.buttonText) {
                showAddressSheet()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

extension BinListEmptyView {
    enum BinListEmptyType {
        case noAddress
        case noBin
        
        var title: String {
            switch self {
            case .noAddress: "No Address Entered"
            case .noBin: "No Bins Found"
            }
        }
        
        var imageName: String {
            switch self {
            case .noAddress: "location.slash"
            case .noBin: "trash.slash"
            }
        }
        
        var description: String {
            switch self {
            case .noAddress: "Enter the address you wish to view bin collection days for."
            case .noBin: "No bins found for this location. Pull to refresh or try another address."
            }
        }
        
        var buttonText: String {
            switch self {
            case .noAddress: "Enter an address"
            case .noBin: "Try another address"
            }
        }
    }
}

#Preview("No Address Entered") {
    BinListEmptyView(type: .noAddress, showAddressSheet: {})
}

#Preview("No Bins Found") {
    BinListEmptyView(type: .noBin, showAddressSheet: {})
}
