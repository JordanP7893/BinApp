//
//  BinDays.swift
//  BinApp
//
//  Created by Jordan Porter on 05/03/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation

struct BinDays: Codable, Hashable, Identifiable {
    let type: BinType
    let date: Date
    var notificationEvening: Date?
    var notificationMorning: Date?
    var isPending: Bool
    
    var isMorningPending: Bool {
        if let notificationMorning, notificationMorning < Date() && isPending {
            return true
        } else {
            return false
        }
    }
    
    var isEveningPending: Bool {
        if let notificationEvening, notificationEvening < Date() && isPending {
            return true
        } else {
            return false
        }
    }
    
    var showNotification: Bool {
        if isMorningPending || isEveningPending {
            return true
        } else {
            return false
        }
    }
    
    var id: String {
        return "\(date.description) \(type.description)"
    }
    
    mutating func donePressed() {
        isPending = false
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "BinType"
        case date = "CollectionDate"
        case notificationEvening
        case notificationMorning
        case isPending
        case id
    }
    
    init(type: BinType, date: Date) {
        self.type = type
        self.date = date
        self.isPending = true
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(BinType.self, forKey: .type)
        self.date = try container.decode(Date.self, forKey: .date)
        self.notificationEvening = try container.decodeIfPresent(Date.self, forKey: .notificationEvening)
        self.notificationMorning = try container.decodeIfPresent(Date.self, forKey: .notificationMorning)
        self.isPending = try container.decodeIfPresent(Bool.self, forKey: .isPending) ?? true
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(date, forKey: .date)
        try container.encode(notificationEvening, forKey: .notificationEvening)
        try container.encode(notificationMorning, forKey: .notificationMorning)
        try container.encode(isPending, forKey: .isPending)
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

enum BinType: String, Codable, CaseIterable, Identifiable {
    case green = "GREEN"
    case black = "BLACK"
    case brown = "BROWN"
    case food = "FOOD"
    
    var id: String { rawValue }
    
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
}

