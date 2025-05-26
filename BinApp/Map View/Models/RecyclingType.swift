//
//  RecyclingType.swift
//  BinApp
//
//  Created by Jordan Porter on 03/07/2019.
//  Copyright © 2019 Jordan Porter. All rights reserved.
//

import SwiftUI

enum RecyclingType: CustomStringConvertible, CaseIterable, Codable {
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
    
    var colour: Color {
        switch self {
        case .glass:
            return Color(red: 96/255, green: 194/255, blue: 183/255)
        case .paper:
            return Color(red: 22/255, green: 137/255, blue: 206/255)
        case .textiles:
            return Color(red: 251/255, green: 183/255, blue: 49/255)
        case .electronics:
            return Color(red: 223/255, green: 20/255, blue: 123/255)
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
