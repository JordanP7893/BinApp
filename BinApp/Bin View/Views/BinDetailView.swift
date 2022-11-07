//
//  BinDetailView.swift
//  BinApp
//
//  Created by Jordan Porter on 07/11/2022.
//  Copyright © 2022 Jordan Porter. All rights reserved.
//

import SwiftUI

struct BinDetailView: View {
    var bin: BinDays
    
    var body: some View {
        let binListTypeText: BinTypeList = {
            let binListData = BinTypeListData().binTypeList
            return binListData[bin.type.rawValue] ?? BinTypeList()
        }()
        
        ScrollView {
            VStack {
                HStack {
                    VStack {
                        Text(bin.date.formatDateTodayTomorrowOrActual())
                            .font(.title)
                            .bold()
                        Spacer()
                    }
                    Spacer()
                    Image(bin.type.rawValue.lowercased())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 80)
                }
                .padding()
                VStack {
                    BinListComponent(title: "Yes Please", listText: binListTypeText.yes, markType: .check)
                    Spacer(minLength: 30)
                    BinListComponent(title: "No Thanks", listText: binListTypeText.no, markType: .cross)
                }
                .padding(.trailing, 10)
            }
            .padding()
        }
    }
}

struct BinDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        BinDetailView(bin: BinDays(type: BinType(rawValue: "GREEN")!, date: Date(timeIntervalSinceNow: 0)))
    }
}

extension Date {
    func formatDateTodayTomorrowOrActual() -> String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(self) {
            return "Tomorrow"
        } else {
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "EEEE, d MMMM"
            return "\(dateFormatterPrint.string(from: self))"
        }
    }
}

struct BinListComponent: View {
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
