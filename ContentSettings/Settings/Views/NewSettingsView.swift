//
//  NewSettingsView.swift
//  DoItAll
//
//  Created by Marc Harvey on 29/03/2026.
//

import SwiftUI

struct NewSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationStack {
            List {
                noteSettingsSection
                appearanceSettingsSection
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
    
    @ViewBuilder
    private var noteSettingsSection: some View {
        Section {
            SettingsNavigationRow(
                icon: "cart.fill",
                title: "Shopping List",
                iconColours: [.green, .green.opacity(0.7)],
                destination: SupermarketSettingsView()
            )
            
            SettingsNavigationRow(
                icon: "book",
                title: "Journal",
                iconColours: [.green, .green.opacity(0.7)],
                destination: JournalSettings(settingsManager: SettingsManager())
            )
        } header: {
            Text("Note Settings")
        }
    }
    
    @ViewBuilder
    private var appearanceSettingsSection: some View {
        Section {
            themePicker
        } header: {
            Text("Appearance")
        } footer: {
            Text("Choose a background theme for the app")
        }
    }
    
    @ViewBuilder
    private var themePicker: some View {
        Picker(
            "Background theme",
            selection: Binding<BackgroundTheme>(
                get: { viewModel.themeManager.selectedTheme },
                set: { viewModel.updateTheme($0) }
            )
        ) {
            ForEach(BackgroundTheme.allCases, id: \.self) { theme in
                Text(theme.rawValue).tag(theme)
            }
        }
            .pickerStyle(.menu)
    }
}

#Preview {
    NewSettingsView()
}
