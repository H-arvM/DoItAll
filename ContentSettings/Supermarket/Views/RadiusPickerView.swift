//
//  RadiusPickerView.swift
//  DoItAll
//
//  Created by Marc Harvey on 02/04/2026.
//

import SwiftUI
import CoreLocation

struct RadiusPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedRadius: CLLocationDistance
    let radiusOptions: [CLLocationDistance]
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Radius", selection: $selectedRadius) {
                    ForEach(radiusOptions, id: \.self) { radius in
                        Text("\(Int(radius)) meters").tag(radius)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .navigationTitle("Notification Radius")
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
    @State var previewRadius: CLLocationDistance = 200.0
    return RadiusPickerView(selectedRadius: $previewRadius, radiusOptions: [100.0, 200.0, 300.0])
}
