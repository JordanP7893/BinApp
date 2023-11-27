//
//  BinNotifications.swift
//  BinApp
//
//  Created by Jordan Porter on 13/04/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation
import NotificationCenter

class BinNotifications: NSObject, Codable, ObservableObject {
    enum CodingKeys: CodingKey {
        case morning
        case morningTime
        case evening
        case eveningTime
        case types
    }

    @Published var morning: Bool
    @Published var morningTime: Date
    @Published var evening: Bool
    @Published var eveningTime: Date
    @Published var types: [Int: Bool]

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateFormat = .none
        return formatter
    }()
    
    init(morning: Bool, morningTime: Date, evening: Bool, eveningTime: Date, types: [Int: Bool]) {
        self.morning = morning
        self.morningTime = morningTime
        self.evening = evening
        self.eveningTime = eveningTime
        self.types = types
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        morning = try container.decode(Bool.self, forKey: .morning)
        morningTime = try container.decode(Date.self, forKey: .morningTime)
        evening = try container.decode(Bool.self, forKey: .evening)
        eveningTime = try container.decode(Date.self, forKey: .eveningTime)
        types = try container.decode([Int: Bool].self, forKey: .types)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(morning, forKey: .morning)
        try container.encode(morningTime, forKey: .morningTime)
        try container.encode(evening, forKey: .evening)
        try container.encode(eveningTime, forKey: .eveningTime)
        try container.encode(types, forKey: .types)
    }
}
