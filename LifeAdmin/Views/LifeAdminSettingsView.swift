//
//  LifeAdminSettingsView.swift
//  DoItAll
//
//  Created by Marc Harvey on 12/02/2026.
//

import SwiftUI


struct LifeAdminSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Settings coming soon...")
                        .foregroundColor(.secondary)
                } header: {
                    Text("General")
                }
                
                Section {
                    Text("Notification preferences")
                    Text("Reminder settings")
                } header: {
                    Text("Preferences")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
