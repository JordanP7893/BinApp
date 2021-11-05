//
//  BinNotifications.swift
//  BinApp
//
//  Created by Jordan Porter on 13/04/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import Foundation
import NotificationCenter

class BinNotifications: NSObject, Codable {
    var morning: Bool
    var morningTime: Date
    var evening: Bool
    var eveningTime: Date
    var types: [Int: Bool]
    
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
}
