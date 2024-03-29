//
//  BinDetailView.swift
//  BinApp
//
//  Created by Jordan Porter on 07/11/2022.
//  Copyright © 2022 Jordan Porter. All rights reserved.
//

import SwiftUI

struct BinDetailView: View {
    @State var showPopup = true
    
    var bin: BinDays
    var donePressed: () -> Void
    var remindPressed: (TimeInterval) -> Void
    var tonightPressed: () -> Void
    
    var body: some View {
        let binListTypeText: BinTypeList = {
            let binListData = BinTypeListData().binTypeList
            return binListData[bin.type.rawValue] ?? BinTypeList()
        }()
        
        ScrollView {
            VStack {
                if showPopup && bin.isPending{
                    BinDuePopupView(showPopup: $showPopup, donePressed: donePressed, remindPressed: remindPressed, tonightPressed: tonightPressed)
                        .transition(AnyTransition.opacity.combined(with: .move(edge: .trailing)))
                        .padding(.bottom)
                }
                
                HStack {
                    Text(bin.date.formatDateTodayTomorrowOrActual())
                            .font(.headline)
                    
                    Spacer()
                    Image(bin.type.rawValue.lowercased())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 80)
                        .padding(.trailing)
                }
                .padding(.bottom)
                
                VStack {
                    BinWhatGoesInView(title: "Yes Please", listText: binListTypeText.yes, markType: .check)
                    Spacer(minLength: 30)
                    BinWhatGoesInView(title: "No Thanks", listText: binListTypeText.no, markType: .cross)
                }
                .padding(.trailing, 10)
            }
            .padding(.horizontal)
        }
    }
}

struct BinDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        BinDetailView(bin: BinDays(type: BinType(rawValue: "GREEN")!, date: Date(timeIntervalSinceNow: 10000), isPending: true), donePressed: {}, remindPressed: {_ in }, tonightPressed: {})
    }
}

extension Date {
    func formatDateTodayTomorrowOrActual() -> String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(self) {
            return "Tomorrow"
        } else {
            let calendar = Calendar.current
            let dateComponents = calendar.component(.day, from: self)
            
            let numberFormatter = NumberFormatter()
            
            numberFormatter.numberStyle = .ordinal
            let day = numberFormatter.string(from: dateComponents as NSNumber)
            
            let weekDayFormatterPrint = DateFormatter()
            weekDayFormatterPrint.dateFormat = "EEEE"
            
            let monthFormatterPrint = DateFormatter()
            monthFormatterPrint.dateFormat = "MMMM"
            
            return "\(weekDayFormatterPrint.string(from: self)), \(day!) \(monthFormatterPrint.string(from: self))"
        }
    }
}
