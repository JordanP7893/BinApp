//
//  BinNotifications.swift
//  BinApp
//
//  Created by Jordan Porter on 20/11/2023.
//  Copyright © 2023 Jordan Porter. All rights reserved.
//

import SwiftUI

struct BinNotificationList: View {
    @Binding var showNotificationSheet: Bool

    @ObservedObject var notifications: BinNotifications

    var body: some View {
        List {
            Section {
                Toggle(isOn: $notifications.evening, label: {
                    Text("Day before collection")
                })
                DatePicker("Time", selection: $notifications.eveningTime, displayedComponents: .hourAndMinute)
                    .disabled(!notifications.evening)
                    .opacity(notifications.evening ? 1 : 0.5)
            }

            Section {
                Toggle(isOn: $notifications.morning, label: {
                    Text("Day of collection")
                })
                DatePicker("Time", selection: $notifications.morningTime, displayedComponents: .hourAndMinute)
                    .disabled(!notifications.morning)
                    .opacity(notifications.morning ? 1 : 0.5)
            } footer: {
                Text("Note: Bins should be placed out by 7am")
            }

            Section {
                binTypeListButton(index: 0, text: "Black")
                binTypeListButton(index: 1, text: "Green")
                binTypeListButton(index: 2, text: "Brown")
            } header: {
                Text("Bin Types")
            } footer: {
                Text("Choose which bin types to recieve notifications for.")
            }
        }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem {
                    Button(action: {
                        showNotificationSheet = false
                    }, label: {
                        Text("Done")
                            .bold()
                    })
                }
            })
    }

    func binTypeListButton(index: Int, text: String) -> some View {
        Button(action: {
            notifications.types[index]?.toggle()
        }, label: {
            HStack {
                Text(text)
                    .foregroundStyle(.foreground)
                Spacer()
                Image(systemName: "checkmark")
                    .opacity(notifications.types[index] ?? false ? 1 : 0)
            }
        })
    }
}

#Preview {
    Text("Bin Notification List")
        .sheet(isPresented: .constant(true),
               content: {
            NavigationView {
                BinNotificationList(
                    showNotificationSheet: .constant(
                        true
                    ),
                    notifications: .init(
                        morning: false,
                        morningTime: .now,
                        evening: true,
                        eveningTime: .now,
                        types: [0:true, 1:true, 2:false]
                    )
                )
                
            }
        })
}
