//
//  ScribbleEntry.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import SwiftUI

struct ScribbleEntry: View {
    @State private var lines: [Line] = []
    @State private var currentLine: Line?
    @State private var showSettings = false
    @State private var selectedColor: Color = .black
    @State private var lineWidth: CGFloat = 3.0
    @State private var penType: PenType = .pen
    
    var body: some View {
        ZStack {
            // Drawing Canvas
            Canvas { context, size in
                for line in lines {
                    var path = Path()
                    path.addLines(line.points)
                    
                    context.stroke(
                        path,
                        with: .color(line.color),
                        style: StrokeStyle(
                            lineWidth: line.width,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                }
                
                // Draw current line being drawn
                if let currentLine = currentLine {
                    var path = Path()
                    path.addLines(currentLine.points)
                    
                    context.stroke(
                        path,
                        with: .color(currentLine.color),
                        style: StrokeStyle(
                            lineWidth: currentLine.width,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                }
            }
            .background(Color.white)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let point = value.location
                        
                        if currentLine == nil {
                            currentLine = Line(
                                points: [point],
                                color: selectedColor,
                                width: lineWidth,
                                type: penType
                            )
                        } else {
                            currentLine?.points.append(point)
                        }
                    }
                    .onEnded { _ in
                        if let line = currentLine {
                            lines.append(line)
                            currentLine = nil
                        }
                    }
            )
        }
        .navigationTitle("Scribble Pad")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    // Settings Button
                    Button(action: {
                        showSettings.toggle()
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 18))
                    }
                    
                    // Save Button (placeholder)
                    Button(action: {
                        // Placeholder for save functionality
                        print("Save tapped")
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 18))
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    lines.removeAll()
                    currentLine = nil
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 18))
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            ScribbleEntrySettingsView(
                selectedColor: $selectedColor,
                lineWidth: $lineWidth,
                penType: $penType
            )
        }
    }
}

#Preview {
    NavigationView {
        ScribbleEntry()
    }
}
