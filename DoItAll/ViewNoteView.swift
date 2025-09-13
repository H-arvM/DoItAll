//
//  ViewNoteView.swift
//  DoItAll
//
//  Created by Marc Harvey on 13/09/2025.
//

import SwiftUI
import CoreData

struct ViewNoteView: View {
    var item: Item
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var journalText: String
    @State private var journalImages: [UIImage]

    // Define the grid layout
    let gridLayout = [GridItem(.adaptive(minimum: 100))]
    
    init(item: Item) {
        self.item = item
        _journalText = State(initialValue: item.journalText ?? "")
        
        if let imageDataArray = item.imageData as? [Data] {
            _journalImages = State(initialValue: imageDataArray.compactMap { UIImage(data: $0) })
        } else {
            _journalImages = State(initialValue: [])
        }
    }
    
    var body: some View {
        VStack {
            // Text editor
            TextEditor(text: $journalText)
                .frame(maxHeight: .infinity)
                .padding()
            
            // Image grid section
            if !journalImages.isEmpty {
                ScrollView {
                    LazyVGrid(columns: gridLayout, spacing: 10) {
                        ForEach(journalImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: 200)
            }
        }
        .navigationTitle("HERRO")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
