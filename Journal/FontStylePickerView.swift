//  FontStylePickerView.swift
//  DoItAll
//
//  Created by Assistant on 11/02/2026.
//

import SwiftUI

struct FontStylePickerView: View {
    @Binding var fontSize: CGFloat
    @Binding var fontColor: Color
    @Binding var fontName: String
    @Binding var fontWeight: Font.Weight
    @Environment(\.dismiss) private var dismiss
    
    let availableFonts = ["System", "Arial", "Georgia", "Courier"]
    let availableFontWeights: [Font.Weight] = [.regular, .bold, .semibold, .thin, .light]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Font Size")) {
                    Slider(value: $fontSize, in: 12...40, step: 1) {
                        Text("Font size")
                    }
                    Text("\(Int(fontSize)) pt")
                }
                Section(header: Text("Font Color")) {
                    ColorPicker("Font Color", selection: $fontColor)
                }
                Section(header: Text("Font")) {
                    Picker("Font", selection: $fontName) {
                        ForEach(availableFonts, id: \.self) { name in
                            Text(name)
                        }
                    }
                }
                Section(header: Text("Weight")) {
                    Picker("Font Weight", selection: $fontWeight) {
                        ForEach(availableFontWeights, id: \.self) { weight in
                            Text(String(describing: weight))
                        }
                    }
                }
            }
            .navigationTitle("Style")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
