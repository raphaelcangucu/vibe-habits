//
//  SettingsView.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @State private var notificationManager = NotificationManager.shared

    var body: some View {
        NavigationStack {
            List {
                // Notifications Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.blue)
                                .font(.title3)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daily Reminders")
                                    .font(.headline)

                                Text("Get notified at 9 PM to check in on your habits")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: $notificationsEnabled)
                                .labelsHidden()
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Notifications")
                }
                .onChange(of: notificationsEnabled) { _, newValue in
                    if newValue {
                        Task {
                            await notificationManager.requestAuthorization()
                            await notificationManager.scheduleDailyReminder()
                        }
                    } else {
                        notificationManager.cancelNotifications()
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

                                    Text("Tag me @raphaelcangucu and maybe I'll build it!")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
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
