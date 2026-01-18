//
//  SupportListView.swift
//  BinApp
//
//  Created by Jordan Porter on 23/12/2025.
//  Copyright © 2025 Jordan Porter. All rights reserved.
//

import SwiftUI

struct SupportListView: View {
    @State private var showTipSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Help with bins 🙋") {
                    Link("Cannot find my address", destination: HelpUrls.cannotFindAddressUrl)
                    Link("Bin day is incorrect", destination: HelpUrls.binDayIncorrectUrl)
                    Link("Report a missed bin collection", destination: HelpUrls.missedCollectionUrl)
                    Link("Other queries", destination: HelpUrls.generalEnquiryUrl)
                }
                
                Section("Bugs in the app 🐛") {
                    Link("Email us", destination: HelpUrls.email)
                }

                Section("Say thank you 🥰") {
                    Button("Leave a review") {
                        UIApplication.shared.open(HelpUrls.leaveReview)
                    }
                    Button("Tip jar") {
                        showTipSheet = true
                    }
                }
            }
            .navigationTitle("Support")
            .sheet(isPresented: $showTipSheet) {
                TipJarView()
            }
        }
    }
}

#Preview {
    SupportListView()
}
