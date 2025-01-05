//
//  BinNotifications.swift
//  BinApp
//
//  Created by Jordan Porter on 13/04/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation

struct BinNotifications: Codable, Equatable {
    enum CodingKeys: CodingKey {
        case morningTime
        case eveningTime
        case types
    }

    var morningTime: Date?
    var eveningTime: Date?
    var types: [BinType]
    
    init(morningTime: Date? = nil, eveningTime: Date? = nil, types: [BinType] = BinType.allCases) {
        self.morningTime = morningTime
        self.eveningTime = eveningTime
        self.types = types
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        morningTime = try container.decode(Date?.self, forKey: .morningTime)
        eveningTime = try container.decode(Date.self, forKey: .eveningTime)
        types = try container.decode([BinType].self, forKey: .types)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(morningTime, forKey: .morningTime)
        try container.encode(eveningTime, forKey: .eveningTime)
        try container.encode(types, forKey: .types)
    }
}
