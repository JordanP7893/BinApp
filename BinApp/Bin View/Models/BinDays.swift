//
//  BinDays.swift
//  BinApp
//
//  Created by Jordan Porter on 05/03/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation
import UIKit

struct BinDays: Codable, Hashable, Identifiable {
    let type: BinType
    let date: Date
    var notificationDate: Date?
    var isPending: Bool
    
    var id: String {
        return "\(date.description) \(type.description)"
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "BinType"
        case date = "CollectionDate"
        case isPending
        case id
    }
    
    init(type: BinType, date: Date) {
        self.type = type
        self.date = date
        self.isPending = false
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(BinType.self, forKey: .type)
        self.date = try container.decode(Date.self, forKey: .date)
        self.isPending = try container.decodeIfPresent(Bool.self, forKey: .isPending) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(date, forKey: .date)
        try container.encode(isPending, forKey: .isPending)
        try container.encode(id, forKey: .id)
    }

    mutating func donePressed() {
        isPending = false
    }

    static let testBin = BinDays(type: .green, date: Date(timeIntervalSinceNow: 10000))
    static let testBinsArray: [BinDays] = [
        .init(type: .green, date: Date(timeIntervalSinceNow: 1)),
        .init(type: .black, date: Date(timeIntervalSinceNow: 100000)),
        .init(type: .green, date: Date(timeIntervalSinceNow: 200000)),
        .init(type: .black, date: Date(timeIntervalSinceNow: 300000)),
        .init(type: .brown, date: Date(timeIntervalSinceNow: 400000)),
        .init(type: .green, date: Date(timeIntervalSinceNow: 500000)),
        .init(type: .black, date: Date(timeIntervalSinceNow: 600000)),
        .init(type: .green, date: Date(timeIntervalSinceNow: 700000)),
    ]
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

