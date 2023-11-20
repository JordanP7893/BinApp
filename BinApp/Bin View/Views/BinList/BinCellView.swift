//
//  BinCellView.swift
//  BinApp
//
//  Created by Jordan Porter on 23/07/2023.
//  Copyright © 2023 Jordan Porter. All rights reserved.
//

import SwiftUI

struct BinCellView: View {

    @Binding var bin: BinDays

    var body: some View {
        HStack(spacing: 20.0) {
            Image(bin.type.rawValue.lowercased())
                .resizable()
                .scaledToFit()
                .frame(height: 70)

            VStack(alignment: .leading, spacing: 8.0) {
                Text(bin.type.description)
                    .font(.headline)

                Text(bin.date.formatDateTodayTomorrowOrActual())
            }

            Spacer()

            if bin.isPending {
                Text("1")
                    .padding(3)
                    .foregroundColor(.white)
                    .background {
                        Circle()
                            .foregroundColor(.red)
                            .scaledToFill()
                    }
            }
        }
    }
}

struct BinCellView_Previews: PreviewProvider {
    static var previews: some View {
        BinCellView(bin: .constant(.init(type: .green, date: Date(timeIntervalSinceNow: 1000000), isPending: true)))
            .padding()
    }
}
