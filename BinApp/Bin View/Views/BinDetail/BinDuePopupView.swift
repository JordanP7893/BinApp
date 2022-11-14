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
    
    var body: some View {
        VStack {
            Text("Time to put this bin out")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(){
                BinDueButtonView(showPopup: $showPopup, buttonText: "Done")
                
                BinDueButtonView(showPopup: $showPopup, buttonText: "Remind Me Later")
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
        BinDuePopupView(showPopup: .constant(true))
    }
}

struct BinDueButtonView: View {
    @Binding var showPopup: Bool
    var buttonText: String
    
    var body: some View {
        Button(buttonText) {
            withAnimation {
                showPopup = false
            }
        }
        .font(.callout)
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color(UIColor(named: "AppColour")!).brightness(-0.1))
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
