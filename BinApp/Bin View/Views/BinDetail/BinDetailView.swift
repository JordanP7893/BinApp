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
    @State var binTypeText: BinTypeList?
    
    @Binding var bin: BinDays
    var donePressed: () -> Void
    var remindPressed: (TimeInterval) -> Void
    var tonightPressed: () -> Void
    
    var body: some View {
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
                    BinWhatGoesInView(title: "Yes Please", listText: binTypeText?.yes, markType: .check)
                    Spacer(minLength: 30)
                    BinWhatGoesInView(title: "No Thanks", listText: binTypeText?.no, markType: .cross)
                }
                .padding(.trailing, 10)
            }
            .padding(.horizontal)
        }
        .navigationTitle(bin.type.description)
        .onAppear {
            binTypeText = BinTypeListData().binTypeList[bin.type.rawValue] ?? BinTypeList()
        }
    }
}

struct BinDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            BinDetailView(
                bin: .constant(BinDays.testBin),
                donePressed: {},
                remindPressed: { _ in },
                tonightPressed: {}
            )
        }
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
