//
//  Date+Extensions.swift
//  BinApp
//
//  Created by Jordan Porter on 08/06/2025.
//  Copyright © 2025 Jordan Porter. All rights reserved.
//

import Foundation

extension Date {
    func addDay(noOfDays: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: noOfDays, to: self)!
    }
    
    func combineWith(time: Date) -> Date? {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        combinedComponents.second = timeComponents.second
        
        return calendar.date(from: combinedComponents)
    }
}
