//
//  ContentView.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var settingsManager = SettingsManager()
    @State private var showingSettings = false
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Item.journalText, ascending: true)], animation: .default)
    private var items: FetchedResults<Item>
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomLeading) {
                NotesListView(settingsManager: settingsManager)
                    .environment(\.managedObjectContext, viewContext)
                
                FloatingPlusButton(settingsManager: settingsManager)
            }
            .navigationTitle(StringsStore.ContentView.awrite)
            .toolbar {
                ToolbarButtons(showingSettings: $showingSettings)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(settingsManager: settingsManager, sourceView: "Content View")
            }
        }
    }
}

//#Preview {
//    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}


private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
