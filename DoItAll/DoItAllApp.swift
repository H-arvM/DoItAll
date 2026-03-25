//
//  DoItAllApp.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import SwiftUI

@main
struct DoItAllApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
