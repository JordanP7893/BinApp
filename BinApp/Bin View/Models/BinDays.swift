//
//  BinDays.swift
//  BinApp
//
//  Created by Jordan Porter on 05/03/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation
import UIKit

struct BinDays: Codable {
    var type: BinType
    var date: Date
    var isPending = false
    
    var id: String {
        return "\(date.description) \(type.description)"
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "BinType"
        case date = "CollectionDate"
    }
}

enum BinType: String, Codable{
    
    case green = "GREEN"
    case black = "BLACK"
    case brown = "BROWN"
    case food = "FOOD"
    
    var description: String {
        switch self {
        case .green:
            return "Green"
        case .black:
            return "Black"
        case .brown:
            return "Brown"
        case .food:
            return "Food"
        }
    }
    
    var position: Int {
        switch self {
        case .black:
            return 0
        case .green:
            return 1
        case .food:
            return 2
        case .brown:
            return 3
        }
    }
    
    var color: UIColor {
        switch self {
        case .green:
            return UIColor(red: 81/255, green: 148/255, blue: 124/255, alpha: 1)
        case .black:
            return #colorLiteral(red: 0.2757396524, green: 0.2757396524, blue: 0.2757396524, alpha: 1)
        case .brown:
            return #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1)
        case .food:
            return #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        }
    }
}

