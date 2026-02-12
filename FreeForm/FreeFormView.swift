//
//  FreeFormView.swift
//  DoItAll
//
//  Created by Marc Harvey on 12/02/2026.
//

import SwiftUI

struct FreeFormView: View {
    @State private var text: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Subtle background
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Main text editor
                    TextEditor(text: $text)
                        .focused($isTextFieldFocused)
                        .font(.body)
                        .scrollContentBackground(.hidden)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.clear)
                    
                    // Subtle word count footer
                    if !text.isEmpty {
                        HStack {
                            Text("\(wordCount) words")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }
            }
            .navigationTitle("Free Form")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // TODO: Save to CoreData
                        print("Save tapped")
                    } label: {
                        Text("Save")
                            .fontWeight(.medium)
                    }
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
    
    private var wordCount: Int {
        let words = text.split(whereSeparator: \.isWhitespace)
        return words.count
    }
}

#Preview {
    FreeFormView()
}
