//
//  JournalView.swift
//  DoItAll
//
//  Created by Marc Harvey on 08/04/2026.
//

import SwiftUI
import PhotosUI

enum JournalMode {
    case edit
    case view
}

struct JournalView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var viewModel: JournalViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let mode: JournalMode
    
    init(mode: JournalMode = .edit, entry: JournalEntry? = nil, initialEntryType: EntryType = .journal) {
        self.mode = mode
        _viewModel = StateObject(wrappedValue: JournalViewModel(entry: entry, initialEntryType: initialEntryType))
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    JournalView()
}
