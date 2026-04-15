//
//  JournalSettings.swift
//  DoItAll
//
//  Created by Marc Harvey on 15/04/2026.
//

import SwiftUI

struct JournalSettings: View {
    @ObservedObject var settingsManager: SettingsManager
    
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
        Form {
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
    }
}

#Preview {
    let previewManager = SettingsManager()
    JournalSettings(settingsManager: previewManager)
}
