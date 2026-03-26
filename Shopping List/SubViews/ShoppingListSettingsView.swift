//
//  ShoppingListSettingsView.swift
//  DoItAll
//
//  Created by Marc Harvey on 12/02/2026.
//

import SwiftUI

//TODO: Flesh out properly with actual notification settings

struct ShoppingListSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: {
                        // Placeholder action
                        print("Option 1 tapped")
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Text("Setup Location Notification")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        // Placeholder action
                        print("Option 2 tapped")
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Setup Notification Interval")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
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

#Preview {
    ShoppingListSettingsView()
}
