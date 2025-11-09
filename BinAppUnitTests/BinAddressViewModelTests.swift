//
//  BinAddressViewModelTests.swift
//  BinAppUnitTests
//
//  Created by Jordan Porter on 21/09/2025.
//  Copyright © 2025 Jordan Porter. All rights reserved.
//

import Testing
@testable import Bins___Recycling

@MainActor
struct BinAddressViewModelTests {
    
    @Test("On save tap correct address sent in callback")
    func testSaveTap() async throws {
        var receivedAddress: StoreAddress? = nil
        let viewModel = BinAddressViewModel(onSaveCallback: { address in
            receivedAddress = address
        })
        viewModel.addresses = [.dummy, .dummy2, .dummy3]
        viewModel.selectedAddressIndex = 1
        
        viewModel.onSaveTap()
        
        #expect(receivedAddress == .dummy2)
    }

    
    @Test("On location button tap, the button state is updated")
    func testLocationButtonTap() async throws {
        let viewModel = BinAddressViewModel(onSaveCallback: { _ in })
        #expect(viewModel.locationButtonState == .notPressed)

        let task = Task { await viewModel.onLocationButtonTap() }
        await Task.yield()

        #expect(viewModel.locationButtonState == .loading)

        await task.value
        #expect(viewModel.locationButtonState == .notPressed)
    }
    
    @Test("On user postcode update values are set")
    func testUserPostcodeUpdate() async throws {
        let viewModel = BinAddressViewModel(binAddressDataService: MockBinAddressDataService(), onSaveCallback: { _ in})
        viewModel.locationButtonState = .loading
        
        await viewModel.onUserPostcodeUpdate(userPostcode: "LS1 ABC")
        
        #expect(viewModel.searchText == "LS1 ABC")
        #expect(viewModel.addresses?.count == 3)
        #expect(viewModel.locationButtonState == .active)
    }
}
