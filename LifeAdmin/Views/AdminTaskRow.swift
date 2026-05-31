//
//  AdminTaskRow.swift
//  DoItAll
//
//  Created by Marc Harvey on 12/02/2026.
//

import SwiftUI

struct AdminTaskRow: View {
    let task: TaskItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(.glass)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title ?? "")
                    .font(.body)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: task.category ?? "")
                            .font(.caption2)
                        Text(task.category ?? "")
                            .font(.caption)
                    }
                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text(formatDate(task.dueDate ?? Date()))
                        .font(.caption)
                        .foregroundColor(isOverdue(task.dueDate ?? Date()) ? .red : .secondary)
                }
            }
            
            Spacer()
            
            if isOverdue(task.dueDate ?? Date()) && !task.isCompleted {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
    
    func isOverdue(_ date: Date) -> Bool {
        return date < Date() && !Calendar.current.isDateInToday(date)
    }
}
