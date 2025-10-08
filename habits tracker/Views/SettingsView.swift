//
//  SettingsView.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("morningReminderEnabled") private var morningReminderEnabled = false
    @AppStorage("afternoonReminderEnabled") private var afternoonReminderEnabled = false
    @AppStorage("eveningReminderEnabled") private var eveningReminderEnabled = false
    @State private var notificationManager = NotificationManager.shared

    var body: some View {
        NavigationStack {
            List {
                // Notifications Section
                Section {
                    // Morning Reminder
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sunrise.fill")
                                .foregroundColor(.orange)
                                .font(.title3)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Morning Reminder")
                                    .font(.headline)

                                Text("8:00 AM - Start your day strong")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: $morningReminderEnabled)
                                .labelsHidden()
                        }
                    }
                    .padding(.vertical, 4)

                    // Afternoon Reminder
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(.yellow)
                                .font(.title3)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Midday Check-in")
                                    .font(.headline)

                                Text("2:00 PM - Keep the momentum going")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: $afternoonReminderEnabled)
                                .labelsHidden()
                        }
                    }
                    .padding(.vertical, 4)

                    // Evening Reminder
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "moon.stars.fill")
                                .foregroundColor(.indigo)
                                .font(.title3)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Evening Reflection")
                                    .font(.headline)

                                Text("9:00 PM - Log your daily progress")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: $eveningReminderEnabled)
                                .labelsHidden()
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Daily Reminders")
                }
                .onChange(of: morningReminderEnabled) { _, newValue in
                    if newValue {
                        Task {
                            await notificationManager.requestAuthorization()
                            await notificationManager.scheduleMorningReminder()
                        }
                    } else {
                        notificationManager.cancelMorningReminder()
                    }
                }
                .onChange(of: afternoonReminderEnabled) { _, newValue in
                    if newValue {
                        Task {
                            await notificationManager.requestAuthorization()
                            await notificationManager.scheduleAfternoonReminder()
                        }
                    } else {
                        notificationManager.cancelAfternoonReminder()
                    }
                }
                .onChange(of: eveningReminderEnabled) { _, newValue in
                    if newValue {
                        Task {
                            await notificationManager.requestAuthorization()
                            await notificationManager.scheduleEveningReminder()
                        }
                    } else {
                        notificationManager.cancelEveningReminder()
                    }
                }

                // About Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title3)

                            Text("About")
                                .font(.headline)
                        }

                        Text("Vibe Habits helps you build consistency through intuitive progress tracking, visual streaks, and meaningful insights.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack {
                            Text("Version")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.primary)
                        }
                        .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("About")
                }

                // Tips Section
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                                .font(.title3)

                            Text("Tips for Success")
                                .font(.headline)
                        }

                        TipRow(
                            icon: "1.circle.fill",
                            text: "Start small – Focus on 2–3 habits"
                        )

                        TipRow(
                            icon: "2.circle.fill",
                            text: "Be consistent – Daily actions build momentum"
                        )

                        TipRow(
                            icon: "3.circle.fill",
                            text: "Track honestly – Missing a day is okay"
                        )
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Tips")
                }

                // Talk to the Dev Section
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .foregroundColor(.purple)
                                .font(.title3)

                            Text("Talk to the Dev")
                                .font(.headline)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Got ideas? Want a new feature?")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "1.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.body)

                                    Text("Take a screenshot of your idea")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "2.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.body)

                                    Text("Post it on Twitter/X with your suggestions")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "3.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.body)

                                    HStack(spacing: 4) {
                                        Text("Tag me")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)

                                        Link("@raphaelcangucu", destination: URL(string: "https://twitter.com/raphaelcangucu")!)
                                            .font(.subheadline)
                                            .fontWeight(.medium)

                                        Text("and maybe I'll build it!")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }

                            Divider()
                                .padding(.vertical, 4)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Feeling ambitious?")
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                Text("Fork the project on GitHub and build it yourself! Open-source vibes ✨")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Feedback")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Tip Row

struct TipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.body)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    SettingsView()
}
