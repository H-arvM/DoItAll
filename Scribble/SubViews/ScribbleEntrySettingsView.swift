//
//  TestView.swift
//  DoItAll
//
//  Created by Marc Harvey on 12/02/2026.
//

import SwiftUI

struct ScribbleEntrySettingsView: View {
    @Binding var selectedColor: Color
    @Binding var lineWidth: CGFloat
    @Binding var penType: PenType
    @Environment(\.dismiss) var dismiss
    
    let predefinedColors: [Color] = [
        .black, .gray, .red, .orange, .yellow,
        .green, .blue, .purple, .pink, .brown
    ]
    
    var body: some View {
        NavigationView {
            Form {
                // Pen Type Section
                Section(header: Text("Pen Type")) {
                    ForEach(PenType.allCases) { type in
                        Button(action: {
                            penType = type
                        }) {
                            HStack {
                                Image(systemName: type.icon)
                                    .frame(width: 30)
                                Text(type.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if penType == type {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                // Color Section
                Section(header: Text("Color")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(predefinedColors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Custom Color Picker
                    ColorPicker("Custom Color", selection: $selectedColor)
                }
                
                // Thickness Section
                Section(header: Text("Thickness")) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Size:")
                            Spacer()
                            Text("\(Int(lineWidth))")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $lineWidth, in: 1...20, step: 1)
                        
                        // Preview
                        HStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: lineWidth / 2)
                                .fill(selectedColor)
                                .frame(width: 100, height: lineWidth)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Drawing Settings")
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

//#Preview {
//    ScribbleEntrySettingsView(selectedColor: <#Binding<Color>#>, lineWidth: <#Binding<CGFloat>#>, penType: <#Binding<PenType>#>)
//}

// MARK: - Line Model
struct Line: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var width: CGFloat
    var type: PenType
}

// MARK: - Pen Type
enum PenType: String, CaseIterable, Identifiable {
    case pen = "Pen"
    case pencil = "Pencil"
    case marker = "Marker"
    case brush = "Brush"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .pen: return "pencil"
        case .pencil: return "pencil.tip"
        case .marker: return "highlighter"
        case .brush: return "paintbrush"
        }
    }
}
