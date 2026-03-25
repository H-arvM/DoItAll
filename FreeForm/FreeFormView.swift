//
//  FreeFormView.swift
//  DoItAll
//
//  Created by Marc Harvey on 12/02/2026.
//

import SwiftUI

struct FreeFormView: View {
    @StateObject private var viewModel = FreeFormViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    textEditorSection
                    
                    if !viewModel.text.isEmpty {
                        wordCountFooter
                    }
                }
            }
            .navigationTitle("Free Form")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.saveEntry()
                    } label: {
                        Text("Save")
                            .fontWeight(.medium)
                    }
                    .disabled(viewModel.text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextFieldFocused = true
                }
            }
        }
    }
    
    private var textEditorSection: some View {
        TextEditor(text: $viewModel.text)
            .focused($isTextFieldFocused)
            .font(.body)
            .scrollContentBackground(.hidden)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
    }
    
    private var wordCountFooter: some View {
        HStack {
            Text("\(viewModel.wordCount) words")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .animation(.easeInOut(duration: 0.2), value: viewModel.wordCount)
    }
}

#Preview {
    FreeFormView()
}
