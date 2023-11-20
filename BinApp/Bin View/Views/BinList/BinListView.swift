//
//  BinListView.swift
//  BinApp
//
//  Created by Jordan Porter on 23/07/2023.
//  Copyright © 2023 Jordan Porter. All rights reserved.
//

import SwiftUI

struct BinListView: View {

    @Binding var bins: [BinDays]

    var body: some View {
        List($bins) { bin in
            NavigationLink {
                BinDetailView(bin: bin, donePressed: {}, remindPressed: { _ in }, tonightPressed: {})
            } label: {
                BinCellView(bin: bin)
            }
        }
        .listStyle(.inset)
    }
}

struct BinListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BinListView(bins: .constant(BinDays.testBinsArray))
        }
    }
}
