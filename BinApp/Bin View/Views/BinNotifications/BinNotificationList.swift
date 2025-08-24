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
    
    @Binding var notifications: BinNotifications
    var binTypes: [BinType]
    
    var body: some View {
        List {
            Section {
                Toggle(isOn: eveningOn, label: {
                    Text("Day before collection")
                })
                DatePicker("Time", selection: eveningTime, displayedComponents: .hourAndMinute)
                    .disabled(notifications.eveningTime == nil)
                    .opacity(notifications.eveningTime == nil ? 0.5 : 1)
            }
            
            Section {
                Toggle(isOn: morningOn, label: {
                    Text("Day of collection")
                })
                DatePicker("Time", selection: morningTime, displayedComponents: .hourAndMinute)
                    .disabled(notifications.morningTime == nil)
                    .opacity(notifications.morningTime == nil ? 0.5 : 1)
            } footer: {
                Text("Note: Bins should be placed out by 7am")
            }
            
            Section {
                ForEach(binTypes) {
                    binTypeListButton(type: $0)
                }
            } header: {
                Text("Bin Types")
            } footer: {
                Text("Choose which bin types to receive notifications for.")
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem {
                Button(action: {
                    showNotificationSheet = false
                }, label: {
                    if #available(iOS 26, *) {
                        Image(systemName: "checkmark")
                    } else {
                        Text("Done")
                            .bold()
                    }
                })
            }
        })
    }
    
    func binTypeListButton(type: BinType) -> some View {
        Button(action: {
            if notifications.types.contains(where: { $0 == type }) {
                notifications.types.removeAll { $0 == type }
            } else {
                notifications.types.append(type)
            }
            if notifications.types.isEmpty {
                notifications.eveningTime = nil
                notifications.morningTime = nil
            }
        }, label: {
            HStack {
                Text(type.description)
                    .foregroundStyle(.foreground)
                Spacer()
                Image(systemName: "checkmark")
                    .opacity(notifications.types.contains(where: { $0 == type }) ? 1 : 0)
            }
        })
    }
}

extension BinNotificationList {
    var eveningOn: Binding<Bool> {
        Binding {
            notifications.eveningTime != nil
        } set: {
            notifications.eveningTime = $0 ? .now : nil
        }
    }
    
    var eveningTime: Binding<Date> {
        Binding {
            notifications.eveningTime ?? .now
        } set: {
            notifications.eveningTime = $0
        }

    }
    
    var morningOn: Binding<Bool> {
        Binding {
            notifications.morningTime != nil
        } set: {
            notifications.morningTime = $0 ? .now : nil
        }
    }
    
    var morningTime: Binding<Date> {
        Binding {
            notifications.morningTime ?? .now
        } set: {
            notifications.morningTime = $0
        }

    }
}

#Preview {
    @Previewable
    @State var notifications: BinNotifications = .init()
    
    Text("Bin Notification List")
        .sheet(
            isPresented: .constant(true),
            content: {
                NavigationView {
                    BinNotificationList(
                        showNotificationSheet: .constant(
                            true
                        ),
                        notifications: $notifications,
                        binTypes: [.black, .green, .brown]
                )
                
            }
        })
}
