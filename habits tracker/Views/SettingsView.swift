//
//  SettingsView.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import StoreKit
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.requestReview) private var requestReview
    @AppStorage("morningReminderEnabled") private var morningReminderEnabled = false
    @AppStorage("afternoonReminderEnabled") private var afternoonReminderEnabled = false
    @AppStorage("eveningReminderEnabled") private var eveningReminderEnabled = false
    @State private var notificationManager = NotificationManager.shared
    @State private var exportDocument: HabitBackupDocument?
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var transferMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section("Your Data") {
                    Button {
                        do {
                            exportDocument = try HabitBackupService.makeDocument(modelContext: modelContext)
                            isExporting = true
                        } catch {
                            transferMessage = error.localizedDescription
                        }
                    } label: {
                        Label("Export Backup", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        isImporting = true
                    } label: {
                        Label("Restore Backup", systemImage: "square.and.arrow.down")
                    }

                    Text("Backups are JSON files you control. Nothing is uploaded by Vibe Habits.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Privacy & Support") {
                    Link(destination: URL(string: "https://raphaelcangucu.github.io/vibe-habits/privacy/")!) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }

                    Link(destination: URL(string: "https://raphaelcangucu.github.io/vibe-habits/support/")!) {
                        Label("Support", systemImage: "questionmark.circle.fill")
                    }

                    Button {
                        requestReview()
                    } label: {
                        Label("Rate Vibe Habits", systemImage: "star.fill")
                    }
                }

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
                            Text(getAppVersion())
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
            .fileExporter(
                isPresented: $isExporting,
                document: exportDocument,
                contentType: .json,
                defaultFilename: "Vibe-Habits-Backup"
            ) { result in
                if case .failure(let error) = result {
                    transferMessage = error.localizedDescription
                }
            }
            .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json]) { result in
                do {
                    let url = try result.get()
                    let hasAccess = url.startAccessingSecurityScopedResource()
                    defer {
                        if hasAccess { url.stopAccessingSecurityScopedResource() }
                    }
                    let data = try Data(contentsOf: url)
                    let restored = try HabitBackupService.restore(data: data, modelContext: modelContext)
                    transferMessage = String(localized: "Restored \(restored) items successfully.")
                } catch {
                    transferMessage = error.localizedDescription
                }
            }
            .alert("Data Transfer", isPresented: Binding(
                get: { transferMessage != nil },
                set: { if !$0 { transferMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(transferMessage ?? "")
            }
        }
    }

    private func getAppVersion() -> String {
        // Get version from Info.plist
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }

        // Fallback to hardcoded version
        return "1.1.0"
    }
}

// MARK: - Tip Row

struct TipRow: View {
    let icon: String
    let text: LocalizedStringKey

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
