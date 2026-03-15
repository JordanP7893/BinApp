//
//  AddressMatcher.swift
//  BinApp
//
//  Created by Jordan Porter on 21/09/2025.
//

import Foundation

struct AddressMatcher {
    static func bestAddressIndex(in addresses: [StoreAddress], houseNameOrNumber: String?, streetName: String?) -> Int {
        let trimmedHouse = houseNameOrNumber?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trimmedStreet = streetName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if trimmedHouse.isEmpty && trimmedStreet.isEmpty {
            return 0
        }

        let normalizedHouse = normalized(trimmedHouse)
        let normalizedStreet = normalized(trimmedStreet)
        let houseNumber = firstNumber(in: trimmedHouse)

        var bestIndex = 0
        var bestScore = -1

        for (index, address) in addresses.enumerated() {
            let combined = normalized([address.address1, address.address2, address.street].joined(separator: " "))
            let addressStreet = normalized(address.street)
            let addressHouse1 = normalized(address.address1)
            let addressHouse2 = normalized(address.address2)
            let addressHouseNumber = firstNumber(in: address.address1) ?? firstNumber(in: address.address2)

            var score = 0

            if !normalizedStreet.isEmpty {
                if addressStreet == normalizedStreet {
                    score += 6
                } else if combined.contains(normalizedStreet) {
                    score += 3
                }
            }

            if let houseNumber, let addressHouseNumber, houseNumber == addressHouseNumber {
                score += 6
            } else if !normalizedHouse.isEmpty {
                if addressHouse1 == normalizedHouse {
                    score += 3
                } else if addressHouse2 == normalizedHouse {
                    score += 2
                } else if combined.contains(normalizedHouse) {
                    score += 1
                }
            }

            if score > bestScore {
                bestScore = score
                bestIndex = index
            }
        }

        return bestIndex
    }

    private static func normalized(_ value: String) -> String {
        value.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private static func firstNumber(in value: String) -> String? {
        let digits = value.filter { $0.isNumber }
        return digits.isEmpty ? nil : digits
    }
}
