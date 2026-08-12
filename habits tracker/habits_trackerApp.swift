//
//  habits_trackerApp.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import SwiftUI
import SwiftData

@main
struct habits_trackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Habit.self,
            HabitLog.self,
        ])
        let isStoreScreenshotMode = ProcessInfo.processInfo.arguments.contains("-StoreScreenshotMode")
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStoreScreenshotMode)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            if isStoreScreenshotMode {
                seedStoreScreenshotData(in: container)
            }
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .opacity(showSplash ? 0 : 1)

                if showSplash {
                    SplashScreenView(isActive: $showSplash)
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

private func seedStoreScreenshotData(in container: ModelContainer) {
    let context = ModelContext(container)
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    let morningWalk = Habit(name: "Morning Walk", frequencyType: .daily, targetValue: 30)
    morningWalk.createdAt = calendar.date(byAdding: .day, value: -24, to: today) ?? today
    context.insert(morningWalk)

    let reading = Habit(name: "Read Every Day", frequencyType: .daily, targetValue: 20)
    reading.createdAt = calendar.date(byAdding: .day, value: -18, to: today) ?? today
    context.insert(reading)

    let strength = Habit(name: "Strength Training", frequencyType: .timesPerWeek, targetValue: 3)
    strength.createdAt = calendar.date(byAdding: .day, value: -12, to: today) ?? today
    context.insert(strength)

    for dayOffset in 0..<14 {
        guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }

        if ![4, 9].contains(dayOffset) {
            context.insert(HabitLog(
                habitId: morningWalk.id,
                date: date,
                value: Double(24 + (dayOffset % 4) * 3),
                completed: dayOffset % 3 != 0,
                note: dayOffset == 0 ? "Fresh air and a strong start to the day." : nil
            ))
        }

        if dayOffset % 5 != 0 {
            context.insert(HabitLog(
                habitId: reading.id,
                date: date,
                value: Double(20 + (dayOffset % 3) * 5),
                completed: true,
                note: dayOffset == 1 ? "A few pages before bed." : nil
            ))
        }

        if [1, 3, 8, 10].contains(dayOffset) {
            context.insert(HabitLog(
                habitId: strength.id,
                date: date,
                value: 1,
                completed: true
            ))
        }
    }

    try? context.save()
}
