//
//  habits_trackerTests.swift
//  habits trackerTests
//
//  Created by Raphael Canguçu on 05/10/25.
//

import Foundation
import SwiftData
import Testing
@testable import habits_tracker

struct habits_trackerTests {

    @Test @MainActor
    func backupRoundTripPreservesHabitsAndLogs() throws {
        let source = try makeContainer()
        let sourceContext = ModelContext(source)

        let habit = Habit(
            name: "Morning walk",
            frequencyType: .daily,
            targetValue: 30,
            reminderEnabled: true,
            reminderHour: 7,
            reminderMinute: 15
        )
        sourceContext.insert(habit)
        sourceContext.insert(HabitLog(
            habitId: habit.id,
            date: Date(timeIntervalSince1970: 1_700_000_000),
            value: 30,
            completed: true,
            note: "Felt great"
        ))
        try sourceContext.save()

        let document = try HabitBackupService.makeDocument(modelContext: sourceContext)
        let destination = try makeContainer()
        let destinationContext = ModelContext(destination)

        let restored = try HabitBackupService.restore(
            data: document.data,
            modelContext: destinationContext
        )

        #expect(restored == 2)
        let habits = try destinationContext.fetch(FetchDescriptor<Habit>())
        let logs = try destinationContext.fetch(FetchDescriptor<HabitLog>())
        #expect(habits.count == 1)
        #expect(logs.count == 1)
        #expect(habits[0].id == habit.id)
        #expect(habits[0].reminderEnabled)
        #expect(habits[0].reminderHour == 7)
        #expect(habits[0].reminderMinute == 15)
        #expect(logs[0].habitId == habit.id)
        #expect(logs[0].note == "Felt great")

        let duplicateRestore = try HabitBackupService.restore(
            data: document.data,
            modelContext: destinationContext
        )
        #expect(duplicateRestore == 0)
    }

    @MainActor
    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([Habit.self, HabitLog.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

}
