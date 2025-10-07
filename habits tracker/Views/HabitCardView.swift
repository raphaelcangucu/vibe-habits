//
//  HabitCardView.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import SwiftUI
import SwiftData

struct HabitCardView: View {
    let habit: Habit
    let store: HabitStore

    @State private var isEditingName = false
    @State private var editedName = ""
    @State private var showingProgressLog = false
    @State private var showingEditLog = false
    @State private var showingInsights = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                if isEditingName {
                    TextField("Habit name", text: $editedName, onCommit: saveName)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .textFieldStyle(.plain)
                } else {
                    Text(habit.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .onTapGesture {
                            isEditingName = true
                            editedName = habit.name
                        }
                }

                Text(habit.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                todayWeekSummary
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Current Week View (for daily, timesPerWeek, hoursPerWeek)
            if habit.frequencyType != .daily || true {
                VStack(alignment: .leading, spacing: 8) {
                    Text("This Week")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        ForEach(store.getCurrentWeek(for: habit)) { day in
                            VStack(spacing: 4) {
                                Text(dayLabel(for: day.date))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)

                                DaySquareView(day: day, habit: habit, store: store)
                                    .frame(width: 32, height: 32)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            // Action Button
            HStack(spacing: 12) {
                Button {
                    let todayLog = store.getLog(for: habit, date: Date())

                    if habit.frequencyType == .daily {
                        // For daily habits: open edit if exists, otherwise log new
                        if todayLog != nil {
                            showingEditLog = true
                        } else {
                            showingProgressLog = true
                        }
                    } else {
                        // Toggle completion for times/hours per week
                        if todayLog != nil {
                            store.deleteLog(for: habit, date: Date())
                        } else {
                            store.markComplete(for: habit)
                        }
                    }
                } label: {
                    let todayLog = store.getLog(for: habit, date: Date())
                    let hasProgress = todayLog != nil

                    HStack(spacing: 8) {
                        if habit.frequencyType == .daily {
                            Image(systemName: hasProgress ? "pencil.circle.fill" : "plus.circle.fill")
                                .font(.body)
                            Text(hasProgress ? "Edit Progress" : "Log Progress")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        } else {
                            Image(systemName: hasProgress ? "xmark.circle.fill" : "checkmark.circle.fill")
                                .font(.body)
                            Text(hasProgress ? "Unmark as Completed" : "Mark Complete")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(hasProgress && habit.frequencyType != .daily ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                    .foregroundColor(hasProgress && habit.frequencyType != .daily ? .red : .blue)
                    .cornerRadius(8)
                }

                Button {
                    showingInsights = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chart.bar.fill")
                            .font(.body)
                        Text("Details")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color(.systemGray6))
                    .foregroundColor(.secondary)
                    .cornerRadius(8)
                }
            }

            // Stats bar
            HStack(spacing: 16) {
                StatItem(label: "This Week", value: formatValue(store.getWeekValue(for: habit)))
                StatItem(label: "Total Days", value: "\(store.getTotalDays(for: habit))")
                StatItem(label: "Best Streak", value: "\(store.getLongestStreak(for: habit))")
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showingProgressLog) {
            ProgressLogView(habit: habit, store: store)
        }
        .sheet(isPresented: $showingEditLog) {
            if let todayLog = store.getLog(for: habit, date: Date()) {
                EditLogView(habit: habit, store: store, date: Date(), existingLog: todayLog)
            }
        }
        .sheet(isPresented: $showingInsights) {
            InsightsView(habit: habit, store: store)
        }
    }

    private var todayWeekSummary: some View {
        Text("Today: \(formatValue(store.getTodayValue(for: habit))) | This week: \(formatValue(store.getWeekValue(for: habit)))")
    }

    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }

    private func saveName() {
        if !editedName.isEmpty {
            store.updateHabitName(habit: habit, newName: editedName)
        }
        isEditingName = false
    }

    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(1))
    }
}

// MARK: - Streak Grid View

struct StreakGridView: View {
    let weeks: [WeekData]
    let habit: Habit
    let store: HabitStore

    var body: some View {
        HStack(spacing: 3) {
            ForEach(weeks) { week in
                VStack(spacing: 3) {
                    ForEach(week.days) { day in
                        DaySquareView(day: day, habit: habit, store: store)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 4)
    }
}

struct DaySquareView: View {
    let day: DayData
    let habit: Habit
    let store: HabitStore
    @State private var showingEditLog = false

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            RoundedRectangle(cornerRadius: 2)
                .fill(colorForIntensity(day.intensity))
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(day.isToday ? Color.blue : Color.clear, lineWidth: 1.5)
                )
                .onTapGesture {
                    if day.log != nil {
                        showingEditLog = true
                    }
                }
                .sheet(isPresented: $showingEditLog) {
                    EditLogView(habit: habit, store: store, date: day.date, existingLog: day.log)
                }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func colorForIntensity(_ intensity: IntensityLevel) -> Color {
        switch intensity {
        case .none:
            return Color(.systemGray5)
        case .low:
            return Color.green.opacity(0.3)
        case .medium:
            return Color.green.opacity(0.6)
        case .high:
            return Color.green
        case .veryHigh:
            return Color.green.opacity(1.0)
        }
    }
}

// MARK: - Stats Item

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .foregroundColor(.secondary)
            Text(value)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Color Legend

struct ColorLegendView: View {
    var body: some View {
        HStack(spacing: 8) {
            Text("Less")
                .font(.caption2)
                .foregroundColor(.secondary)

            HStack(spacing: 4) {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 12, height: 12)
                    .cornerRadius(2)

                Rectangle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: 12, height: 12)
                    .cornerRadius(2)

                Rectangle()
                    .fill(Color.green.opacity(0.6))
                    .frame(width: 12, height: 12)
                    .cornerRadius(2)

                Rectangle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                    .cornerRadius(2)

                Rectangle()
                    .fill(Color.green.opacity(1.0))
                    .frame(width: 12, height: 12)
                    .cornerRadius(2)
            }

            Text("More")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    @Previewable @State var habit = Habit(name: "100 Push-ups", frequencyType: .daily, targetValue: 100)
    @Previewable @State var store: HabitStore? = nil

    HabitCardView(habit: habit, store: store ?? HabitStore(modelContext: ModelContext(try! ModelContainer(for: Habit.self, HabitLog.self))))
        .padding()
        .modelContainer(for: [Habit.self, HabitLog.self], inMemory: true)
}
