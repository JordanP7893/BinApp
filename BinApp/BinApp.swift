//
//  BinApp.swift
//  BinApp
//
//  Created by Jordan Porter on 28/08/2023.
//  Copyright © 2023 Jordan Porter. All rights reserved.
//

import SwiftUI

@main
struct BinApp: App {
    @StateObject private var binProvider = BinDaysProvider()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                BinView()
                    .environmentObject(binProvider)
            }
            .tint(.init("AppColour"))
        }
    }
}
