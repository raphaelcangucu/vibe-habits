import Foundation
import SwiftData
import WidgetKit

struct WidgetHabitSnapshot: Codable, Equatable {
    let habitName: String?
    let completedToday: Int
    let totalHabits: Int
    let updatedAt: Date
}

@MainActor
enum WidgetSnapshotStore {
    static let appGroup = "group.app.vibehabits.ios"
    static let snapshotKey = "widgetHabitSnapshot"

    static func update(modelContext: ModelContext) {
        let habits = (try? modelContext.fetch(
            FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
        )) ?? []
        let logs = (try? modelContext.fetch(FetchDescriptor<HabitLog>())) ?? []
        let completedToday = logs.filter {
            $0.completed && Calendar.current.isDateInToday($0.date)
        }.count

        let snapshot = WidgetHabitSnapshot(
            habitName: habits.first?.name,
            completedToday: completedToday,
            totalHabits: habits.count,
            updatedAt: Date()
        )

        guard
            let defaults = UserDefaults(suiteName: appGroup),
            let data = try? JSONEncoder().encode(snapshot)
        else { return }

        defaults.set(data, forKey: snapshotKey)
        WidgetCenter.shared.reloadTimelines(ofKind: "VibeHabitsWidget")
    }
}
