//
//  SettingsManager.swift
//  DoItAll
//
//  Created by Marc Harvey on 06/09/2025.
//

import Foundation
import UserNotifications

@MainActor
class SettingsManager: ObservableObject {
    @Published var hidePreview: Bool = false
    @Published var emptyBool: Bool = false
    @Published var isNewEntryHidden: Bool = false
    @Published var notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: "notificationsEnabled") {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            updateNotifications()
        }
    }
    
    @Published var notificationTime: Date = {
        if let savedDate = UserDefaults.standard.object(forKey: "notificationTime") as? Date {
            return savedDate
        }
        return Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
    }() {
        didSet {
            UserDefaults.standard.set(notificationTime, forKey: "notificationTime")
            updateNotifications()
        }
    }
    
    @Published var notificationFrequencyInDays: Int = UserDefaults.standard.integer(forKey: "notificationFrequencyInDays") > 0 ? UserDefaults.standard.integer(forKey: "notificationFrequencyInDays") : 1 {
        didSet {
            UserDefaults.standard.set(notificationFrequencyInDays, forKey: "notificationFrequencyInDays")
            updateNotifications()
        }
    }
    
    // Method to handle scheduling and removing notifications
    private func updateNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        guard notificationsEnabled else { return }
        
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            guard success else {
                print("Notification permission denied.")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Time to Write!"
            content.body = "Don't forget to write your journal entry today."
            content.sound = .default
            
            // Schedule multiple notifications for the next 7 occurrences
            for i in 0..<7 {
                guard let notificationDate = Calendar.current.date(byAdding: .day, value: i * self.notificationFrequencyInDays, to: self.notificationTime) else { continue }
                
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request)
            }
            print("Notifications scheduled every \(self.notificationFrequencyInDays) day(s).")
        }
    }
}
