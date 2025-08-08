//
//  EnvironmentValues+Extensions.swift
//  BinApp
//
//  Created by Jordan Porter on 15/06/2025.
//  Copyright © 2025 Jordan Porter. All rights reserved.
//
import SwiftUI

private struct LocationManagerKey: EnvironmentKey {
    static let defaultValue = LocationManager()
}

extension EnvironmentValues {
    var locationManager: LocationManager {
        get { self[LocationManagerKey.self] }
        set { self[LocationManagerKey.self] = newValue }
    }
}
