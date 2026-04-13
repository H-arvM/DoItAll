//
//  PausePickerView.swift
//  DoItAll
//
//  Created by Marc Harvey on 02/04/2026.
//

import SwiftUI

struct PausePickerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedDuration: TimeInterval = 3600

    let onSelectDuration: (TimeInterval) -> Void
    let durationOptions: [(title: String, duration: TimeInterval)] = [
        ("30 minutes", 1800),
        ("1 hour", 3600),
        ("2 hours", 7200),
        ("4 hours", 14400),
        ("8 hours", 28800),
        ("24 hours", 86400)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Duration", selection: $selectedDuration) {
                    ForEach(durationOptions, id: \.duration) { option in
                        Text(option.title).tag(option.duration)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .navigationTitle("Pause duration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Pause") {
                        onSelectDuration(selectedDuration)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    PausePickerView { duration in
        print("Selected duration: \(duration)")
    }
}
