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

    func scheduleMorningReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "Good Morning! 🌅"
        content.body = "Start your day strong! Your habits are waiting for you."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 8  // 8 AM
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "morningHabitReminder",
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Morning reminder scheduled for 8 AM")
        } catch {
            print("Error scheduling morning notification: \(error)")
        }
    }

    func scheduleAfternoonReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "Midday Check-in ☀️"
        content.body = "How's your progress today? Keep the momentum going!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 14  // 2 PM
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "afternoonHabitReminder",
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Afternoon reminder scheduled for 2 PM")
        } catch {
            print("Error scheduling afternoon notification: \(error)")
        }
    }

    func scheduleEveningReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "Evening Reflection 🌙"
        content.body = "Time to log your progress! Did you complete your habits today?"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 21  // 9 PM
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "eveningHabitReminder",
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Evening reminder scheduled for 9 PM")
        } catch {
            print("Error scheduling evening notification: \(error)")
        }
    }

    func cancelMorningReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["morningHabitReminder"])
        print("Morning reminder cancelled")
    }

    func cancelAfternoonReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["afternoonHabitReminder"])
        print("Afternoon reminder cancelled")
    }

    func cancelEveningReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["eveningHabitReminder"])
        print("Evening reminder cancelled")
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            "morningHabitReminder",
            "afternoonHabitReminder",
            "eveningHabitReminder"
        ])
        print("All notifications cancelled")
    }
}
