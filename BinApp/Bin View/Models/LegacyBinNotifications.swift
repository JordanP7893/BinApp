//
//  LegacyBinNotifications.swift
//  BinApp
//
//  Created by Jordan Porter on 29/12/2024.
//  Copyright © 2024 Jordan Porter. All rights reserved.
//

import Foundation

class LegacyBinNotifications: NSObject, Codable {
    var morning: Bool
    var morningTime: Date
    var evening: Bool
    var eveningTime: Date
    var types: [Int: Bool]
    
    init(morning: Bool, morningTime: Date, evening: Bool, eveningTime: Date, types: [Int: Bool]) {
        self.morning = morning
        self.morningTime = morningTime
        self.evening = evening
        self.eveningTime = eveningTime
        self.types = types
    }
}
