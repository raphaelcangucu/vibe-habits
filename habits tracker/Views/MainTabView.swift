//
//  MainTabView.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var habits: [Habit]
    @Query private var logs: [HabitLog]

    var body: some View {
        TabView {
            HabitsListView()
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle.fill")
                }

            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "photo.stack.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear(perform: refreshWidget)
        .onChange(of: habits.count) { _, _ in refreshWidget() }
        .onChange(of: logs.count) { _, _ in refreshWidget() }
        .onReceive(NotificationCenter.default.publisher(for: .habitCompleted)) { _ in
            refreshWidget()
        }
    }

    private func refreshWidget() {
        WidgetSnapshotStore.update(modelContext: modelContext)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Habit.self, HabitLog.self], inMemory: true)
}
