//
//  JournalEntry.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import SwiftUI
import CoreData

struct JournalEntry: View {
    @Environment(\.dismiss) private var dismiss
    
    // Inject the ViewModel with the Core Data context
    @StateObject private var viewModel: JournalEntryViewModel

    @FocusState private var isJournalTextFocused: Bool

    // Custom initializer to pass the context to the ViewModel
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: JournalEntryViewModel(context: context))
    }

    var body: some View {
        VStack {
            TextEditor(text: $viewModel.journalText)
                .focused($isJournalTextFocused)
                .padding()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        isJournalTextFocused = true
                    }
                }
        }
        .navigationTitle("New Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    viewModel.saveJournalEntry()
                    dismiss()
                }
            }
        }
    }
}

//#Preview {
//    JournalEntry(context: )
//}
