//
//  RecyclingType.swift
//  BinApp
//
//  Created by Jordan Porter on 03/07/2019.
//  Copyright © 2019 Jordan Porter. All rights reserved.
//

import Foundation

enum RecyclingType: CustomStringConvertible {
    case glass
    case paper
    case textiles
    case electronics
    
    var description: String {
        switch self {
        case .glass:
            return "glass"
        case .paper:
            return "paper"
        case .textiles:
            return "textiles"
        case .electronics:
            return "electronics"
        }
    }
    
    var pickerIndex: Int {
        switch self {
        case .glass:
            return 0
        case .paper:
            return 1
        case .textiles:
            return 2
        case .electronics:
            return 3
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
