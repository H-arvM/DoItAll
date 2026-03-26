//
//  Date+Extensions.swift
//  DoItAll
//
//  Created by Marc Harvey on 25/03/2026.
//

import Foundation

extension Date {
    var funFormatString: String {
        let calendar = Calendar.current
        let now = Date()
        
            // Time formatter
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let time = timeFormatter.string(from: self)
        
        // Check if today
        if calendar.isDateInToday(self) {
            return "Today at \(time)"
        }
        
        // Check if yesterday]
        if calendar.isDateInYesterday(self) {
            return "Yesterday at \(time)"
        }
        
        // Check if this week
        if let daysAgo = calendar.dateComponents([.day], from: self, to: now).day, daysAgo < 7 {
            let weekday = calendar.component(.weekday, from: self)
            let weekdayName = calendar.weekdaySymbols[weekday - 1]
            return "Last at \(weekdayName) at \(time)"
        }
        
        // Check if this year
        let createdYear = calendar.component(.year, from: self)
        let currentYear = calendar.component(.year, from: now)
        
        if createdYear == currentYear {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMM d"
            let dateString = dateFormatter.string(from: self)
            return "\(dateString) at \(time)"
        }
        
        // Show full date with year for older entries
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateString = dateFormatter.string(from: self)
        return "\(dateString) at \(time)"
    }
}
