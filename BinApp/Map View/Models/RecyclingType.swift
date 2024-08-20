//
//  RecyclingType.swift
//  BinApp
//
//  Created by Jordan Porter on 03/07/2019.
//  Copyright © 2019 Jordan Porter. All rights reserved.
//

import Foundation

enum RecyclingType: CustomStringConvertible, CaseIterable {
    case glass
    case paper
    case textiles
    case electronics
    
    var description: String {
        switch self {
        case .glass:
            return "Glass"
        case .paper:
            return "Paper"
        case .textiles:
            return "Textiles"
        case .electronics:
            return "Electronics"
        }
    }
    
    init(rawValue: String) {
        switch rawValue {
        case "paper": self = .paper
        case "textiles": self = .textiles
        case "electronics": self = .electronics
        default: self = .glass
        }
    }
}
