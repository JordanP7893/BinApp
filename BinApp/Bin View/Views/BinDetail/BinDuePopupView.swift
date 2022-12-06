//
//  BinDuePopupView.swift
//  BinApp
//
//  Created by Jordan Porter on 14/11/2022.
//  Copyright © 2022 Jordan Porter. All rights reserved.
//

import SwiftUI

struct BinDuePopupView: View {
    @Binding var showPopup: Bool
    @State var showConfirmation = false
    
    var donePressed: () -> Void
    var remindPressed: (TimeInterval) -> Void
    
    var body: some View {
        VStack {
            Text("Time to put this bin out")
                .font(.headline)
                .foregroundColor(.white)
            HStack(){
                Button(action: {
                    withAnimation {
                        showPopup = false
                        donePressed()
                    }
                }, label: {
                    Label("Done", systemImage: "checkmark.square")
                })
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 100, alignment: .center)
                .background(Color(UIColor(named: "AppColour")!).brightness(-0.1))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Button(action: {
                    showConfirmation = true
                }, label: {
                    Label("Later...", systemImage: "alarm")
                })
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color(UIColor(named: "AppColour")!).brightness(-0.1))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .confirmationDialog("Remind me in:", isPresented: $showConfirmation, titleVisibility: .visible) {
                    Button("10 minutes") {
                        showPopup = false
                        remindPressed(10 * 60)
                    }
                    Button("1 hour") {
                        showPopup = false
                        remindPressed(60 * 60)
                    }
                    Button("2 hours") {
                        showPopup = false
                        remindPressed(2 * 60 * 60)
                    }
                    Button("5 hours") {
                        showPopup = false
                        remindPressed(5 * 60 * 60)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor(named: "AppColour")!))
                .shadow(radius: 10)
        )
    }
}

struct BinDuePopupView_Previews: PreviewProvider {
    static var previews: some View {
        BinDuePopupView(showPopup: .constant(true), donePressed: {}, remindPressed: {_ in })
    }
}
