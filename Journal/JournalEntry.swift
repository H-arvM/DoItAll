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
    @StateObject private var viewModel: JournalEntryViewModel
    @FocusState private var isJournalTextFocused: Bool
    @State private var showingSettings = false

    init(context: NSManagedObjectContext, settingsManager: SettingsManager) {
        _viewModel = StateObject(wrappedValue: JournalEntryViewModel(context: context, settingsManager: settingsManager))
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            TextEditor(text: $viewModel.journalText)
                .focused($isJournalTextFocused)
                .padding()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        isJournalTextFocused = true
                    }
                }
            
            Button {
                showingSettings.toggle()
            } label: {
                Image(systemName: "gearshape.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                    .padding()
                    .shadow(radius: 10)
            }
            .padding(.leading, 10)
            .padding(.bottom, 10)
        }
        .navigationTitle(StringsStore.JournalEntry.navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(StringsStore.JournalEntry.saveTitle) {
                    viewModel.saveJournalEntry()
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(settingsManager: viewModel.settingsManager, sourceView: "Journal View")
        }
    }
}

//#Preview {
//    JournalEntry(context: )
//}
