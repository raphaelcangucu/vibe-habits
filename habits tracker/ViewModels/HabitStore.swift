//
//  HabitStore.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import Foundation
import SwiftData

extension Notification.Name {
    static let habitCompleted = Notification.Name("habitCompleted")
}

@Observable
class HabitStore {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Habit Management

    @discardableResult
    func addHabit(
        name: String,
        frequencyType: FrequencyType,
        targetValue: Double,
        reminderEnabled: Bool = false,
        reminderHour: Int = 8,
        reminderMinute: Int = 0
    ) -> Habit {
        let habit = Habit(
            name: name,
            frequencyType: frequencyType,
            targetValue: targetValue,
            reminderEnabled: reminderEnabled,
            reminderHour: reminderHour,
            reminderMinute: reminderMinute
        )
        modelContext.insert(habit)
        try? modelContext.save()
        return habit
    }

    func updateHabitName(habit: Habit, newName: String) {
        habit.name = newName
        try? modelContext.save()
    }

    func deleteHabit(_ habit: Habit) {
        // Delete all associated logs first
        let logs = getLogs(for: habit)
        logs.forEach { modelContext.delete($0) }

        // Delete the habit
        modelContext.delete(habit)
        try? modelContext.save()
        NotificationManager.shared.cancelReminder(for: habit.id)
    }

    // MARK: - Log Management

    func logProgress(for habit: Habit, date: Date = Date(), value: Double, note: String? = nil, photoData: Data? = nil) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        // Check if log already exists for this date
        let logs = getLogs(for: habit)
        let existingLog = logs.first { calendar.isDate($0.date, inSameDayAs: startOfDay) }

        // For times/hours per week, completed = true if value > 0
        // For daily habits, completed = true if value >= target
        let isCompleted: Bool
        if habit.frequencyType == .timesPerWeek || habit.frequencyType == .hoursPerWeek {
            isCompleted = value > 0
        } else {
            isCompleted = value >= habit.targetValue
        }

        if let existingLog = existingLog {
            existingLog.value = value
            existingLog.completed = isCompleted
            if let note = note {
                existingLog.note = note
            }
            if let photoData = photoData {
                existingLog.photoData = photoData
            }
        } else {
            let log = HabitLog(
                habitId: habit.id,
                date: startOfDay,
                value: value,
                completed: isCompleted,
                note: note,
                photoData: photoData
            )
            modelContext.insert(log)
        }

        try? modelContext.save()

        if isCompleted {
            NotificationCenter.default.post(name: .habitCompleted, object: habit.id)
        }
    }

    func markComplete(for habit: Habit, date: Date = Date()) {
        // For times/hours per week, each completion counts as 1
        // For daily habits with targets, mark as target value
        let value: Double
        if habit.frequencyType == .daily {
            value = habit.targetValue
        } else {
            value = 1.0
        }
        logProgress(for: habit, date: date, value: value)
    }

    func deleteLog(for habit: Habit, date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        if let log = getLog(for: habit, date: startOfDay) {
            modelContext.delete(log)
            try? modelContext.save()
        }
    }

    func getLogs(for habit: Habit) -> [HabitLog] {
        let habitId = habit.id
        let descriptor = FetchDescriptor<HabitLog>(
            predicate: #Predicate<HabitLog> { log in
                log.habitId == habitId
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func getAllLogs() -> [HabitLog] {
        let descriptor = FetchDescriptor<HabitLog>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func getAllHabits() -> [Habit] {
        let descriptor = FetchDescriptor<Habit>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func getHabit(for log: HabitLog) -> Habit? {
        let habitId = log.habitId
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate<Habit> { habit in
                habit.id == habitId
            }
        )

        return try? modelContext.fetch(descriptor).first
    }

    func getLog(for habit: Habit, date: Date) -> HabitLog? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        let logs = getLogs(for: habit)
        return logs.first { calendar.isDate($0.date, inSameDayAs: startOfDay) }
    }

    // MARK: - Statistics

    func getTodayValue(for habit: Habit) -> Double {
        getLog(for: habit, date: Date())?.value ?? 0
    }

    func getWeekValue(for habit: Habit) -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!

        let logs = getLogs(for: habit).filter { $0.date >= weekAgo }
        return logs.reduce(0) { $0 + $1.value }
    }

    func getTotalDays(for habit: Habit) -> Int {
        let logs = getLogs(for: habit)
        return logs.filter { $0.completed }.count
    }

    func getCurrentStreak(for habit: Habit) -> Int {
        let calendar = Calendar.current
        let logs = getLogs(for: habit)
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        for _ in 0..<365 {
            if let log = logs.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }),
               log.completed {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }

        return streak
    }

    func getLongestStreak(for habit: Habit) -> Int {
        // For times/hours per week, calculate streak in weeks
        if habit.frequencyType == .timesPerWeek || habit.frequencyType == .hoursPerWeek {
            return getLongestWeekStreak(for: habit)
        }

        // For daily habits, calculate streak in days
        let logs = getLogs(for: habit).filter { $0.completed }.sorted { $0.date < $1.date }
        guard !logs.isEmpty else { return 0 }

        let calendar = Calendar.current
        var maxStreak = 1
        var currentStreak = 1

        for i in 1..<logs.count {
            let previousDate = logs[i - 1].date
            let currentDate = logs[i].date

            if let daysBetween = calendar.dateComponents([.day], from: previousDate, to: currentDate).day,
               daysBetween == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }

        return maxStreak
    }

    func getLongestWeekStreak(for habit: Habit) -> Int {
        let logs = getLogs(for: habit).filter { $0.completed }
        guard !logs.isEmpty else { return 0 }

        let calendar = Calendar.current

        // Group logs by week
        var weeklyCompletion: Set<Date> = []
        for log in logs {
            if let weekStart = calendar.dateInterval(of: .weekOfYear, for: log.date)?.start {
                weeklyCompletion.insert(weekStart)
            }
        }

        // Sort weeks and calculate streak
        let sortedWeeks = Array(weeklyCompletion).sorted()
        guard !sortedWeeks.isEmpty else { return 0 }

        var maxStreak = 1
        var currentStreak = 1

        for i in 1..<sortedWeeks.count {
            let previousWeek = sortedWeeks[i - 1]
            let currentWeek = sortedWeeks[i]

            if let weeksBetween = calendar.dateComponents([.weekOfYear], from: previousWeek, to: currentWeek).weekOfYear,
               weeksBetween == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }

        return maxStreak
    }

    func getCompletionRate(for habit: Habit) -> Double {
        let calendar = Calendar.current
        let daysSinceCreation = calendar.dateComponents([.day], from: habit.createdAt, to: Date()).day ?? 0
        let totalDays = max(daysSinceCreation + 1, 1)
        let completedDays = getTotalDays(for: habit)

        return Double(completedDays) / Double(totalDays)
    }

    func getPerfectDays(for habit: Habit) -> Int {
        // For this implementation, perfect days = completed days
        return getTotalDays(for: habit)
    }

    func getTotalCompleted(for habit: Habit) -> Double {
        let logs = getLogs(for: habit)
        return logs.reduce(0) { $0 + $1.value }
    }

    // MARK: - Week/Period Data

    func getCurrentWeek(for habit: Habit) -> [DayData] {
        let calendar = Calendar.current
        let today = Date()

        // Get the start of the current week (Sunday)
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return []
        }

        var days: [DayData] = []

        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                let log = getLog(for: habit, date: date)
                let intensity = calculateIntensity(habit: habit, log: log)
                let isToday = calendar.isDateInToday(date)

                days.append(DayData(date: date, intensity: intensity, isToday: isToday, log: log, isCurrentMonth: true))
            }
        }

        return days
    }

    func getWeeksForPeriod(for habit: Habit, period: TimePeriod) -> [WeekData] {
        let calendar = Calendar.current
        let today = Date()
        var weeks: [WeekData] = []

        let startDate: Date
        let weeksToShow: Int

        switch period {
        case .week:
            // Current week starting from Sunday
            guard let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
                return []
            }
            startDate = currentWeekStart
            weeksToShow = 1

        case .month:
            // Last 4 weeks from current week
            guard let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start,
                  let fourWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -3, to: currentWeekStart) else {
                return []
            }
            startDate = fourWeeksAgo
            weeksToShow = 4

        case .year:
            // Start from Sunday of current week, go back 52 weeks
            guard let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start,
                  let yearStart = calendar.date(byAdding: .weekOfYear, value: -51, to: currentWeekStart) else {
                return []
            }
            startDate = yearStart
            weeksToShow = 52
        }

        for weekOffset in 0..<weeksToShow {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startDate) else {
                continue
            }
            let weekStartDay = calendar.startOfDay(for: weekStart)

            var days: [DayData] = []

            for dayOffset in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStartDay) {
                    let log = getLog(for: habit, date: date)
                    let intensity = calculateIntensity(habit: habit, log: log)
                    let isToday = calendar.isDateInToday(date)

                    days.append(DayData(date: date, intensity: intensity, isToday: isToday, log: log, isCurrentMonth: true))
                }
            }

            weeks.append(WeekData(days: days))
        }

        return weeks
    }

    func getCurrentMonthCalendar(for habit: Habit) -> [WeekData] {
        let calendar = Calendar.current
        let today = Date()

        // Get the first day of the current month
        guard let monthInterval = calendar.dateInterval(of: .month, for: today),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthInterval.start)) else {
            return []
        }

        // Get the first day we should display (Sunday of the week containing the 1st)
        guard let firstWeekday = calendar.dateInterval(of: .weekOfYear, for: firstDayOfMonth)?.start else {
            return []
        }

        var weeks: [WeekData] = []
        var currentDate = firstWeekday

        // Generate up to 6 weeks to cover any month layout
        for _ in 0..<6 {
            var days: [DayData] = []

            for _ in 0..<7 {
                let log = getLog(for: habit, date: currentDate)
                let intensity = calculateIntensity(habit: habit, log: log)
                let isToday = calendar.isDateInToday(currentDate)
                let isCurrentMonth = calendar.isDate(currentDate, equalTo: today, toGranularity: .month)

                days.append(DayData(
                    date: currentDate,
                    intensity: intensity,
                    isToday: isToday,
                    log: log,
                    isCurrentMonth: isCurrentMonth
                ))

                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }

            weeks.append(WeekData(days: days))

            // Stop if we've passed the current month
            if !calendar.isDate(currentDate, equalTo: today, toGranularity: .month) {
                break
            }
        }

        return weeks
    }

    // MARK: - Weekly Statistics for Times/Hours Per Week Habits

    func getWeeklyStats(for habit: Habit, period: TimePeriod) -> [WeeklyStatistic] {
        let calendar = Calendar.current
        let today = Date()
        var stats: [WeeklyStatistic] = []

        let weeksToShow: Int
        switch period {
        case .week:
            weeksToShow = 1
        case .month:
            weeksToShow = 4
        case .year:
            weeksToShow = 52
        }

        // Get current week start
        guard let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return []
        }

        for weekOffset in (0..<weeksToShow).reversed() {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: currentWeekStart) else {
                continue
            }
            guard let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
                continue
            }

            // Get logs for this week
            let logs = getLogs(for: habit).filter { log in
                log.date >= weekStart && log.date <= calendar.startOfDay(for: weekEnd)
            }

            let totalValue = logs.reduce(0) { $0 + $1.value }
            let isComplete = totalValue >= habit.targetValue

            // Format week label
            let weekLabel: String
            if weekOffset == 0 {
                weekLabel = "This Week"
            } else if weekOffset == 1 {
                weekLabel = "Last Week"
            } else {
                weekLabel = "Week of \(formatShortDate(weekStart))"
            }

            // Format date range
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d"
            let startString = dateFormatter.string(from: weekStart)
            let endString = dateFormatter.string(from: weekEnd)
            let dateRange = "\(startString) - \(endString)"

            // Format completion text
            let completionText = isComplete ? "Complete" : "\(Int((totalValue / habit.targetValue) * 100))% complete"

            stats.append(WeeklyStatistic(
                weekLabel: weekLabel,
                dateRange: dateRange,
                totalValue: totalValue,
                targetValue: habit.targetValue,
                isComplete: isComplete,
                completionText: completionText
            ))
        }

        return stats
    }

    private func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    // MARK: - Period Statistics

    func getStatisticsForPeriod(for habit: Habit, period: TimePeriod) -> PeriodStatistics {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // For times/hours per week habits, calculate statistics based on weeks
        if habit.frequencyType == .timesPerWeek || habit.frequencyType == .hoursPerWeek {
            return getWeekBasedStatistics(for: habit, period: period)
        }

        // For daily habits with month period, use actual month boundaries
        if period == .month {
            return getDailyMonthStatistics(for: habit)
        }

        // For daily habits with week period, use current week boundaries
        if period == .week {
            return getDailyWeekStatistics(for: habit)
        }

        // For daily habits with year, use last 365 days
        let startDate = calendar.date(byAdding: .day, value: -365, to: today)!
        let daysInPeriod = 365

        let logs = getLogs(for: habit).filter { $0.date >= startDate }
        let completedDays = logs.filter { $0.completed }.count
        let totalValue = logs.reduce(0) { $0 + $1.value }

        let completionRate = Double(completedDays) / Double(daysInPeriod)

        return PeriodStatistics(
            completedDays: completedDays,
            totalValue: totalValue,
            completionRate: completionRate,
            longestStreak: getLongestStreakInPeriod(for: habit, startDate: startDate)
        )
    }

    private func getDailyWeekStatistics(for habit: Habit) -> PeriodStatistics {
        let calendar = Calendar.current
        let today = Date()

        // Get the current week boundaries (Sunday to Saturday)
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else {
            return PeriodStatistics(completedDays: 0, totalValue: 0, completionRate: 0, longestStreak: 0)
        }

        let weekStart = weekInterval.start
        let weekEnd = weekInterval.end

        // Get logs within the current week
        let logs = getLogs(for: habit).filter { log in
            log.date >= weekStart && log.date < weekEnd
        }

        let completedDays = logs.filter { $0.completed }.count
        let totalValue = logs.reduce(0) { $0 + $1.value }

        let daysInWeek = 7
        let completionRate = Double(completedDays) / Double(daysInWeek)

        // Get longest streak within this week
        let longestStreak = getLongestStreakInDateRange(for: habit, startDate: weekStart, endDate: weekEnd)

        return PeriodStatistics(
            completedDays: completedDays,
            totalValue: totalValue,
            completionRate: completionRate,
            longestStreak: longestStreak
        )
    }

    private func getDailyMonthStatistics(for habit: Habit) -> PeriodStatistics {
        let calendar = Calendar.current
        let today = Date()

        // Get the first and last day of the current month
        guard let monthInterval = calendar.dateInterval(of: .month, for: today) else {
            return PeriodStatistics(completedDays: 0, totalValue: 0, completionRate: 0, longestStreak: 0)
        }

        let monthStart = monthInterval.start
        let monthEnd = monthInterval.end

        // Get logs within the current month
        let logs = getLogs(for: habit).filter { log in
            log.date >= monthStart && log.date < monthEnd
        }

        let completedDays = logs.filter { $0.completed }.count
        let totalValue = logs.reduce(0) { $0 + $1.value }

        // Calculate number of days in this month
        let daysInMonth = calendar.dateComponents([.day], from: monthStart, to: monthEnd).day ?? 30

        let completionRate = Double(completedDays) / Double(daysInMonth)

        // Get longest streak within this month
        let longestStreak = getLongestStreakInDateRange(for: habit, startDate: monthStart, endDate: monthEnd)

        return PeriodStatistics(
            completedDays: completedDays,
            totalValue: totalValue,
            completionRate: completionRate,
            longestStreak: longestStreak
        )
    }

    private func getLongestStreakInDateRange(for habit: Habit, startDate: Date, endDate: Date) -> Int {
        let logs = getLogs(for: habit)
            .filter { $0.completed && $0.date >= startDate && $0.date < endDate }
            .sorted { $0.date < $1.date }

        guard !logs.isEmpty else { return 0 }

        let calendar = Calendar.current
        var maxStreak = 1
        var currentStreak = 1

        for i in 1..<logs.count {
            let previousDate = logs[i - 1].date
            let currentDate = logs[i].date

            if let daysBetween = calendar.dateComponents([.day], from: previousDate, to: currentDate).day,
               daysBetween == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }

        return maxStreak
    }

    private func getWeekBasedStatistics(for habit: Habit, period: TimePeriod) -> PeriodStatistics {
        let calendar = Calendar.current
        let today = Date()

        // For month, get weeks within the current month
        if period == .month {
            return getMonthWeekBasedStatistics(for: habit)
        }

        // For week and year, use the simple offset approach
        let weeksToShow: Int
        switch period {
        case .week:
            weeksToShow = 1
        case .month:
            weeksToShow = 4  // This won't be reached due to the check above
        case .year:
            weeksToShow = 52
        }

        // Get current week start
        guard let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return PeriodStatistics(completedDays: 0, totalValue: 0, completionRate: 0, longestStreak: 0)
        }

        var completedWeeks = 0
        var totalValue: Double = 0

        // Calculate for each week in the period
        for weekOffset in (0..<weeksToShow).reversed() {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: currentWeekStart),
                  let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
                continue
            }

            // Get logs for this week
            let logs = getLogs(for: habit).filter { log in
                log.date >= weekStart && log.date <= calendar.startOfDay(for: weekEnd)
            }

            let weekTotal = logs.reduce(0) { $0 + $1.value }
            totalValue += weekTotal

            // A week is "completed" if it meets the target
            if weekTotal >= habit.targetValue {
                completedWeeks += 1
            }
        }

        let completionRate = Double(completedWeeks) / Double(weeksToShow)

        // Get longest week streak for the period
        let longestStreak = getLongestWeekStreakInPeriod(for: habit, weeksToShow: weeksToShow)

        return PeriodStatistics(
            completedDays: completedWeeks,
            totalValue: totalValue,
            completionRate: completionRate,
            longestStreak: longestStreak
        )
    }

    private func getMonthWeekBasedStatistics(for habit: Habit) -> PeriodStatistics {
        let calendar = Calendar.current
        let today = Date()

        // Get the first and last day of the current month
        guard let monthInterval = calendar.dateInterval(of: .month, for: today) else {
            return PeriodStatistics(completedDays: 0, totalValue: 0, completionRate: 0, longestStreak: 0)
        }

        let monthStart = monthInterval.start
        let monthEnd = monthInterval.end

        // Get all weeks that overlap with this month
        var weekStarts: [Date] = []
        var currentDate = monthStart

        // Find the first Sunday of or before the month start
        if let firstWeekStart = calendar.dateInterval(of: .weekOfYear, for: monthStart)?.start {
            currentDate = firstWeekStart
        }

        // Collect all week starts that overlap with the month
        while currentDate < monthEnd {
            weekStarts.append(currentDate)
            guard let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextWeek
        }

        var completedWeeks = 0
        var totalValue: Double = 0

        // Calculate statistics for each week
        for weekStart in weekStarts {
            guard let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
                continue
            }

            // Get logs for this week that are also within the month
            let logs = getLogs(for: habit).filter { log in
                log.date >= max(weekStart, monthStart) &&
                log.date < min(calendar.date(byAdding: .day, value: 1, to: weekEnd)!, monthEnd) &&
                log.date >= monthStart && log.date < monthEnd
            }

            let weekTotal = logs.reduce(0) { $0 + $1.value }
            totalValue += weekTotal

            // A week is "completed" if it meets the target
            if weekTotal >= habit.targetValue {
                completedWeeks += 1
            }
        }

        let weeksCount = weekStarts.count
        let completionRate = weeksCount > 0 ? Double(completedWeeks) / Double(weeksCount) : 0

        // Get longest week streak within this month
        let longestStreak = getLongestWeekStreakInMonth(for: habit, weekStarts: weekStarts, monthStart: monthStart, monthEnd: monthEnd)

        return PeriodStatistics(
            completedDays: completedWeeks,
            totalValue: totalValue,
            completionRate: completionRate,
            longestStreak: longestStreak
        )
    }

    private func getLongestWeekStreakInMonth(for habit: Habit, weekStarts: [Date], monthStart: Date, monthEnd: Date) -> Int {
        let calendar = Calendar.current
        var weekCompletions: [Bool] = []

        for weekStart in weekStarts {
            guard let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
                continue
            }

            let logs = getLogs(for: habit).filter { log in
                log.date >= max(weekStart, monthStart) &&
                log.date < min(calendar.date(byAdding: .day, value: 1, to: weekEnd)!, monthEnd) &&
                log.date >= monthStart && log.date < monthEnd
            }

            let weekTotal = logs.reduce(0) { $0 + $1.value }
            weekCompletions.append(weekTotal >= habit.targetValue)
        }

        guard !weekCompletions.isEmpty else { return 0 }

        var maxStreak = 0
        var currentStreak = 0

        for completed in weekCompletions {
            if completed {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }

        return maxStreak
    }

    private func getLongestWeekStreakInPeriod(for habit: Habit, weeksToShow: Int) -> Int {
        let calendar = Calendar.current
        let today = Date()

        guard let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return 0
        }

        var weekCompletions: [Bool] = []

        // Check each week in the period
        for weekOffset in (0..<weeksToShow).reversed() {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: currentWeekStart),
                  let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
                continue
            }

            let logs = getLogs(for: habit).filter { log in
                log.date >= weekStart && log.date <= calendar.startOfDay(for: weekEnd)
            }

            let weekTotal = logs.reduce(0) { $0 + $1.value }
            weekCompletions.append(weekTotal >= habit.targetValue)
        }

        // Calculate longest streak of consecutive true values
        guard !weekCompletions.isEmpty else { return 0 }

        var maxStreak = 0
        var currentStreak = 0

        for completed in weekCompletions {
            if completed {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }

        return maxStreak
    }

    private func getLongestStreakInPeriod(for habit: Habit, startDate: Date) -> Int {
        let logs = getLogs(for: habit)
            .filter { $0.completed && $0.date >= startDate }
            .sorted { $0.date < $1.date }

        guard !logs.isEmpty else { return 0 }

        let calendar = Calendar.current
        var maxStreak = 1
        var currentStreak = 1

        for i in 1..<logs.count {
            let previousDate = logs[i - 1].date
            let currentDate = logs[i].date

            if let daysBetween = calendar.dateComponents([.day], from: previousDate, to: currentDate).day,
               daysBetween == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }

        return maxStreak
    }

    // MARK: - 12-week streak data

    func getLast12Weeks(for habit: Habit) -> [WeekData] {
        let calendar = Calendar.current
        let today = Date()
        var weeks: [WeekData] = []

        for weekOffset in (0..<12).reversed() {
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today)!
            let weekStartDay = calendar.startOfDay(for: weekStart)

            var days: [DayData] = []

            for dayOffset in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStartDay) {
                    let log = getLog(for: habit, date: date)
                    let intensity = calculateIntensity(habit: habit, log: log)
                    let isToday = calendar.isDateInToday(date)

                    days.append(DayData(date: date, intensity: intensity, isToday: isToday, log: log, isCurrentMonth: true))
                }
            }

            weeks.append(WeekData(days: days))
        }

        return weeks
    }

    private func calculateIntensity(habit: Habit, log: HabitLog?) -> IntensityLevel {
        guard let log = log else { return .none }

        // For times/hours per week, use completion status (binary: completed or not)
        if habit.frequencyType == .timesPerWeek || habit.frequencyType == .hoursPerWeek {
            return log.completed ? .veryHigh : .none
        }

        // For daily habits, use percentage-based intensity
        guard log.value > 0 else { return .none }
        let percentage = log.value / habit.targetValue

        if percentage >= 1.5 {
            return .veryHigh
        } else if percentage >= 1.0 {
            return .high
        } else if percentage >= 0.5 {
            return .medium
        } else {
            return .low
        }
    }
}

// MARK: - Supporting Types

struct WeekData: Identifiable {
    let id = UUID()
    let days: [DayData]
}

struct DayData: Identifiable {
    let id = UUID()
    let date: Date
    let intensity: IntensityLevel
    let isToday: Bool
    let log: HabitLog?
    let isCurrentMonth: Bool

    init(date: Date, intensity: IntensityLevel, isToday: Bool, log: HabitLog?, isCurrentMonth: Bool = true) {
        self.date = date
        self.intensity = intensity
        self.isToday = isToday
        self.log = log
        self.isCurrentMonth = isCurrentMonth
    }
}

enum IntensityLevel {
    case none
    case low
    case medium
    case high
    case veryHigh
}

struct WeeklyStatistic: Identifiable {
    let id = UUID()
    let weekLabel: String
    let dateRange: String
    let totalValue: Double
    let targetValue: Double
    let isComplete: Bool
    let completionText: String
}
