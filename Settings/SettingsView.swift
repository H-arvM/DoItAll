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
