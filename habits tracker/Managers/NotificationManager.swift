//
//  NotificationManager.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import Foundation
import UserNotifications

@Observable
class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        } catch {
            print("Error requesting notification authorization: \(error)")
        }
    }

    func scheduleDailyReminder() async {
        // Cancel existing notifications first
        cancelNotifications()

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Habit Check-in"
        content.body = "Did you complete your habits today?"
        content.sound = .default

        // Create date components for 9 PM
        var dateComponents = DateComponents()
        dateComponents.hour = 21  // 9 PM
        dateComponents.minute = 0

        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create request
        let request = UNNotificationRequest(
            identifier: "dailyHabitReminder",
            content: content,
            trigger: trigger
        )

        // Schedule notification
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Daily reminder scheduled for 9 PM")
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }

    func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyHabitReminder"])
        print("Notifications cancelled")
    }
}
