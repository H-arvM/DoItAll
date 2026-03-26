//
//  SettingsView.swift
//  DoItAll
//
//  Created by Marc Harvey on 06/09/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var settingsManager: SettingsManager
    var sourceView: String
    
    let frequencyOptions = [
          1: "Every Day",
          2: "Every 2 Days",
          3: "Every 3 Days",
          4: "Every 4 Days",
          5: "Every 5 Days",
          6: "Every 6 Days",
          7: "Every Week"
      ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                switch sourceView {
                case "Content View":
                    Form {
                        Section(header: Text("Settings")) {
                            Toggle("Placeholder", isOn: $settingsManager.emptyBool)
                        }
                    }
                case "Journal View":
                    Form {
                        Section(header: Text("Settings")) {
                            Toggle("Hide Text Preview", isOn: $settingsManager.isNewEntryHidden)
                        }
                        
                        // New section for notifications
                        Section(header: Text("Notification Reminders")) {
                            Toggle("Enable Reminders", isOn: $settingsManager.notificationsEnabled)
                            
                            if settingsManager.notificationsEnabled {
                                DatePicker("Reminder Time", selection: $settingsManager.notificationTime, displayedComponents: .hourAndMinute)
                                
                                Picker("Frequency", selection: $settingsManager.notificationFrequencyInDays) {
                                    ForEach(frequencyOptions.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                        Text(value).tag(key)
                                    }
                                }
                            }
                        }
                    }
                case "Shopping List View":
                    Text("Shopping list-specific settings would go here.")
                default:
                    Text("General settings would go here.")
                }
            }
            .navigationTitle(StringsStore.SettingsView.navTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(StringsStore.SettingsView.doneButton) {
                        dismiss()
                    }
                }
            }
        }
    }
}

//#Preview {
//    SettingsView()
//}
