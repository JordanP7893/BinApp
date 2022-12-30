//
//  AppReviewRequest.swift
//  BinApp
//
//  Created by Jordan Porter on 30/12/2022.
//  Copyright © 2022 Jordan Porter. All rights reserved.
//

import SwiftUI
import StoreKit

enum AppReviewRequest {
    static var threshold = 3
    @AppStorage("runsSinceLastRequest") static var runsSinceLastRequest = 0
    @AppStorage("versionForLastRequest") static var versionForLastRequest = ""
    
    static func requestReviewIfNeeded() {
        runsSinceLastRequest += 1
        
        let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let thisVersion = "\(appVersion) build: \(appBuild)"
        
        guard thisVersion != versionForLastRequest else {
            runsSinceLastRequest = 0
            return
        }
        
        guard runsSinceLastRequest >= threshold else { return }
        
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        SKStoreReviewController.requestReview(in: scene)
        versionForLastRequest = thisVersion
        runsSinceLastRequest = 0
    }
    
}
