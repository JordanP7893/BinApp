//
//  BinWhatGoesInView.swift
//  BinApp
//
//  Created by Jordan Porter on 14/11/2022.
//  Copyright © 2022 Jordan Porter. All rights reserved.
//

import SwiftUI

struct BinWhatGoesInView: View {
    var title: String
    var listText: String
    var markType: MarkType
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text(title)
                        .font(.title)
                        .bold()
                        .padding(.bottom)
                    Spacer()
                }
                HStack {
                    Text(listText)
                        .lineSpacing(6)
                    Spacer()
                }
            }
            .padding()
            .border(markType.color, width: 4)
            .background(Color(UIColor.secondarySystemBackground))
            HStack {
                Spacer()
                VStack {
                    Image(systemName: markType.systemImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(markType.color)
                        .offset(CGSize(width: 10, height: -10))
                    Spacer()
                }
            }
        }
    }
}

struct BinWhatGoesInView_Previews: PreviewProvider {
    
    static var binListTypeText: BinTypeList = {
        let binListData = BinTypeListData().binTypeList
        return binListData["GREEN"] ?? BinTypeList()
    }()
    
    static var previews: some View {
        BinWhatGoesInView(title: "Yes please", listText: binListTypeText.yes, markType: .check)
            .previewLayout(.fixed(width: 500, height: 400))
    }
}

enum MarkType {
    case check
    case cross
    
    var systemImageName: String {
        switch self {
        case .check:
            return "checkmark.circle.fill"
        case .cross:
            return "xmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case.check:
            return .green
        case .cross:
            return .red
        }
    }
}
