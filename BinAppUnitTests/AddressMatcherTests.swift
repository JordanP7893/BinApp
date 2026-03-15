//
//  AddressMatcherTests.swift
//  BinAppUnitTests
//
//  Created by Jordan Porter on 21/09/2025.
//

import Testing
@testable import Bins___Recycling

@MainActor
struct AddressMatcherTests {
    @Test("Best match falls back to first address when no inputs")
    func testNoInputsReturnsFirst() async throws {
        let addresses = [
            StoreAddress(premisesId: 1, address1: "1 Test", address2: "", street: "Alpha Street", locality: "", localAuthority: "", town: "", postcode: ""),
            StoreAddress(premisesId: 2, address1: "2 Test", address2: "", street: "Beta Street", locality: "", localAuthority: "", town: "", postcode: "")
        ]

        let index = AddressMatcher.bestAddressIndex(in: addresses, houseNameOrNumber: nil, streetName: nil)

        #expect(index == 0)
    }

    @Test("Best match prefers exact street and house number")
    func testExactStreetAndHouseNumber() async throws {
        let addresses = [
            StoreAddress(premisesId: 1, address1: "10", address2: "", street: "High Street", locality: "", localAuthority: "", town: "", postcode: ""),
            StoreAddress(premisesId: 2, address1: "12", address2: "", street: "High Street", locality: "", localAuthority: "", town: "", postcode: "")
        ]

        let index = AddressMatcher.bestAddressIndex(in: addresses, houseNameOrNumber: "12", streetName: "High Street")

        #expect(index == 1)
    }

    @Test("Best match picks street match when house name is non-numeric")
    func testStreetMatchWithHouseName() async throws {
        let addresses = [
            StoreAddress(premisesId: 1, address1: "Rose Cottage", address2: "", street: "Church Lane", locality: "", localAuthority: "", town: "", postcode: ""),
            StoreAddress(premisesId: 2, address1: "2", address2: "", street: "Mill Road", locality: "", localAuthority: "", town: "", postcode: "")
        ]

        let index = AddressMatcher.bestAddressIndex(in: addresses, houseNameOrNumber: "Rose Cottage", streetName: "Church Lane")

        #expect(index == 0)
    }
}
