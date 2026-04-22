//
//  EmptyStateView.swift
//  DoItAll
//
//  Created by Marc Harvey on 12/02/2026.
//

import SwiftUI


// MARK: - Empty State View
struct EmptyStateView: View {
    let category: TaskCategory?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: category?.icon ?? "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(category == nil ? "No Tasks Yet" : "No \(category!.rawValue) Tasks")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)
            
            Text("Tap the + button to add a new task")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
