//
//  MainTabView.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
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
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Habit.self, HabitLog.self], inMemory: true)
}
