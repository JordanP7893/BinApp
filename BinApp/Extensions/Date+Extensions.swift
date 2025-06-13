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
}
