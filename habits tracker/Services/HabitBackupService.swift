import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct HabitBackup: Codable {
    let schemaVersion: Int
    let exportedAt: Date
    let habits: [HabitRecord]
    let logs: [HabitLogRecord]
}

struct HabitRecord: Codable {
    let id: UUID
    let name: String
    let frequencyType: FrequencyType
    let targetValue: Double
    let createdAt: Date
    let reminderEnabled: Bool
    let reminderHour: Int
    let reminderMinute: Int
}

struct HabitLogRecord: Codable {
    let id: UUID
    let habitId: UUID
    let date: Date
    let value: Double
    let completed: Bool
    let note: String?
    let photoData: Data?
}

struct HabitBackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

@MainActor
enum HabitBackupService {
    static let schemaVersion = 1

    static func makeDocument(modelContext: ModelContext) throws -> HabitBackupDocument {
        let habits = try modelContext.fetch(
            FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
        )
        let logs = try modelContext.fetch(
            FetchDescriptor<HabitLog>(sortBy: [SortDescriptor(\.date, order: .forward)])
        )

        let backup = HabitBackup(
            schemaVersion: schemaVersion,
            exportedAt: Date(),
            habits: habits.map {
                HabitRecord(
                    id: $0.id,
                    name: $0.name,
                    frequencyType: $0.frequencyType,
                    targetValue: $0.targetValue,
                    createdAt: $0.createdAt,
                    reminderEnabled: $0.reminderEnabled,
                    reminderHour: $0.reminderHour,
                    reminderMinute: $0.reminderMinute
                )
            },
            logs: logs.map {
                HabitLogRecord(
                    id: $0.id,
                    habitId: $0.habitId,
                    date: $0.date,
                    value: $0.value,
                    completed: $0.completed,
                    note: $0.note,
                    photoData: $0.photoData
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return HabitBackupDocument(data: try encoder.encode(backup))
    }

    static func restore(data: Data, modelContext: ModelContext) throws -> Int {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let backup = try decoder.decode(HabitBackup.self, from: data)

        guard backup.schemaVersion == schemaVersion else {
            throw BackupError.unsupportedVersion
        }

        let existingHabits = try modelContext.fetch(FetchDescriptor<Habit>())
        let existingLogs = try modelContext.fetch(FetchDescriptor<HabitLog>())
        let existingHabitIDs = Set(existingHabits.map(\.id))
        let existingLogIDs = Set(existingLogs.map(\.id))

        var restoredCount = 0

        for record in backup.habits where !existingHabitIDs.contains(record.id) {
            let habit = Habit(
                name: record.name,
                frequencyType: record.frequencyType,
                targetValue: record.targetValue,
                reminderEnabled: record.reminderEnabled,
                reminderHour: record.reminderHour,
                reminderMinute: record.reminderMinute
            )
            habit.id = record.id
            habit.createdAt = record.createdAt
            modelContext.insert(habit)
            restoredCount += 1
        }

        let validHabitIDs = existingHabitIDs.union(backup.habits.map(\.id))
        for record in backup.logs
        where !existingLogIDs.contains(record.id) && validHabitIDs.contains(record.habitId) {
            let log = HabitLog(
                habitId: record.habitId,
                date: record.date,
                value: record.value,
                completed: record.completed,
                note: record.note,
                photoData: record.photoData
            )
            log.id = record.id
            modelContext.insert(log)
            restoredCount += 1
        }

        try modelContext.save()
        return restoredCount
    }
}

enum BackupError: LocalizedError {
    case unsupportedVersion

    var errorDescription: String? {
        String(localized: "This backup was created by an unsupported version of Vibe Habits.")
    }
}
