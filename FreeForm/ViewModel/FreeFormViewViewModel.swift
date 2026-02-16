//
//  FreeFormViewViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 16/02/2026.
//

import SwiftUI
import Combine

class FreeFormViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var wordCount: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Debounce word count calculations to avoid computing on every keystroke
        $text
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { text in
                text.split(whereSeparator: \.isWhitespace).count
            }
            .assign(to: &$wordCount)
    }
    
    func saveEntry() {
        // TODO: Save to CoreData
        print("Save tapped - Text length: \(text.count)")
    }
}
