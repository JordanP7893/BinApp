//
//  EngagementPrompt.swift
//  BinApp
//
//  Created by Jordan Porter on 30/12/2022.
//  Copyright © 2022 Jordan Porter. All rights reserved.
//

import SwiftUI
import StoreKit

enum EngagementPrompt {
    private static let reviewThreshold = 3
    private static let tipThreshold = 6

    @AppStorage("binCompletionsForPrompts") private static var binCompletionsForPrompts = 0
    @AppStorage("versionForLastReviewRequest") private static var versionForLastReviewRequest = ""
    @AppStorage("hasShownTipJarPrompt") private static var hasShownTipJarPrompt = false

    static func handleCompletion() -> Bool {
        binCompletionsForPrompts += 1

        if binCompletionsForPrompts == reviewThreshold {
            requestReviewIfAllowed()
        }

        if binCompletionsForPrompts == tipThreshold {
            binCompletionsForPrompts = 0
            if !hasShownTipJarPrompt {
                hasShownTipJarPrompt = true
                return true
            }
        }

        return false
    }

    private static func requestReviewIfAllowed() {
        let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let thisVersion = "\(appVersion) build: \(appBuild)"

        guard thisVersion != versionForLastReviewRequest else { return }
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

        SKStoreReviewController.requestReview(in: scene)
        versionForLastReviewRequest = thisVersion
    }
}
