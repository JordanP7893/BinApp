//
//  URL+Extensions.swift
//  BinApp
//
//  Created by Jordan Porter on 08/06/2025.
//  Copyright © 2025 Jordan Porter. All rights reserved.
//

import Foundation

extension URL {
    func isThisURL(lessThanDaysOld: Int) -> Bool {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: self.path) as [FileAttributeKey: Any],
            let creationDate = attributes[FileAttributeKey.creationDate] as? Date {

            if creationDate.addDay(noOfDays: lessThanDaysOld) > Date() {
                return true
            }
        }
        return false
    }
}
