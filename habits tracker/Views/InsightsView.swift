//
//  InsightsView.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import SwiftUI
import SwiftData

struct InsightsView: View {
    @Environment(\.dismiss) private var dismiss
    let habit: Habit
    let store: HabitStore
    @State private var selectedPeriod: TimePeriod = .week
    @State private var refreshID = UUID()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(habit.name)
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Progress Insights")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.top, 8)

                    // Period Picker
                    Picker("Time Period", selection: $selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)

                    // Streak Grid for Selected Period
                    VStack(spacing: 8) {
                        if selectedPeriod == .week {
                            // Single week row view
                            let weeks = store.getWeeksForPeriod(for: habit, period: selectedPeriod)
                            HStack(spacing: 4) {
                                ForEach(weeks.first?.days ?? []) { day in
                                    VStack(spacing: 4) {
                                        Text(dayLabel(for: day.date))
                                            .font(.caption2)
                                            .foregroundColor(.secondary)

                                        DaySquareViewInsights(day: day, habit: habit, store: store, refreshTrigger: $refreshID)
                                            .frame(width: 40, height: 40)
                                    }
                                }
                            }
                            .id(refreshID)
                        } else if selectedPeriod == .month {
                            // Calendar view for current month
                            let weeks = store.getCurrentMonthCalendar(for: habit)

                            VStack(spacing: 8) {
                                // Month header
                                Text(currentMonthName())
                                    .font(.headline)
                                    .fontWeight(.semibold)

                                // Day labels (S M T W T F S)
                                HStack(spacing: 0) {
                                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                                        Text(day)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.bottom, 4)

                                // Calendar grid
                                VStack(spacing: 4) {
                                    ForEach(weeks) { week in
                                        HStack(spacing: 4) {
                                            ForEach(week.days) { day in
                                                CalendarDayView(day: day, habit: habit, store: store, refreshTrigger: $refreshID)
                                            }
                                        }
                                    }
                                }
                                .id(refreshID)
                            }
                        } else {
                            // Year view - GitHub style with scroll
                            let weeks = store.getWeeksForPeriod(for: habit, period: selectedPeriod)

                            VStack(alignment: .leading, spacing: 0) {
                                // Month labels
                                HStack(spacing: 0) {
                                    // Space for day labels
                                    Text("")
                                        .frame(width: 30)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 0) {
                                            ForEach(Array(weeks.enumerated()), id: \.offset) { index, week in
                                                if let firstDay = week.days.first,
                                                   Calendar.current.component(.day, from: firstDay.date) <= 7 {
                                                    Text(monthLabel(for: firstDay.date))
                                                        .font(.caption2)
                                                        .foregroundColor(.secondary)
                                                        .frame(width: CGFloat(weeksInMonth(for: firstDay.date)) * 15, alignment: .leading)
                                                } else {
                                                    Color.clear.frame(width: 15)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.bottom, 4)

                                // Grid with day labels
                                HStack(alignment: .top, spacing: 3) {
                                    // Day labels on the left
                                    VStack(spacing: 3) {
                                        Text("Mon")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .frame(height: 12)
                                        Spacer().frame(height: 12)
                                        Text("Wed")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .frame(height: 12)
                                        Spacer().frame(height: 12)
                                        Text("Fri")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .frame(height: 12)
                                        Spacer().frame(height: 24)
                                    }
                                    .frame(width: 30, alignment: .leading)

                                    // Scrollable grid
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(alignment: .top, spacing: 3) {
                                            ForEach(weeks) { week in
                                                VStack(spacing: 3) {
                                                    ForEach(week.days) { day in
                                                        DaySquareViewInsights(day: day, habit: habit, store: store, refreshTrigger: $refreshID)
                                                            .frame(width: 12, height: 12)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                            .id(refreshID)
                        }

                        // Color legend
                        ColorLegendView()
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                    // Metrics Grid
                    VStack(spacing: 12) {
                        let stats = store.getStatisticsForPeriod(for: habit, period: selectedPeriod)

                        HStack(spacing: 12) {
                            MetricCardCompact(
                                icon: "trophy.fill",
                                iconColor: .green,
                                title: "Longest Streak",
                                value: "\(stats.longestStreak)",
                                subtitle: "days"
                            )

                            MetricCardCompact(
                                icon: "calendar",
                                iconColor: .blue,
                                title: "Completed Days",
                                value: "\(stats.completedDays)",
                                subtitle: "in period"
                            )
                        }

                        HStack(spacing: 12) {
                            MetricCardCompact(
                                icon: "chart.line.uptrend.xyaxis",
                                iconColor: .purple,
                                title: "Completion Rate",
                                value: "\(Int(stats.completionRate * 100))%",
                                subtitle: "of period"
                            )

                            MetricCardCompact(
                                icon: "flame.fill",
                                iconColor: .orange,
                                title: "Total Value",
                                value: formatValue(stats.totalValue),
                                subtitle: "cumulative"
                            )
                        }
                    }

                    // Motivational Message
                    VStack(spacing: 12) {
                        Image(systemName: motivationIcon)
                            .font(.system(size: 40))
                            .foregroundStyle(motivationColor.gradient)

                        Text(motivationalMessage)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.large)
        }
        .presentationDetents([.large])
    }

    private var currentStreak: Int {
        store.getCurrentStreak(for: habit)
    }

    private var motivationalMessage: String {
        if currentStreak == 0 {
            return "Start today and build momentum! Every journey begins with a single step."
        } else if currentStreak < 7 {
            return "Great start! Keep going to build a strong foundation. Consistency is key!"
        } else if currentStreak < 30 {
            return "You're building a solid habit! Stay consistent and watch your progress grow."
        } else if currentStreak < 90 {
            return "Impressive dedication! You're well on your way to making this a lifestyle."
        } else {
            return "Outstanding! You've transformed this into a lasting habit. Keep up the amazing work!"
        }
    }

    private var motivationIcon: String {
        if currentStreak == 0 {
            return "figure.walk"
        } else if currentStreak < 7 {
            return "leaf.fill"
        } else if currentStreak < 30 {
            return "bolt.fill"
        } else if currentStreak < 90 {
            return "star.fill"
        } else {
            return "crown.fill"
        }
    }

    private var motivationColor: Color {
        if currentStreak == 0 {
            return .blue
        } else if currentStreak < 7 {
            return .green
        } else if currentStreak < 30 {
            return .orange
        } else if currentStreak < 90 {
            return .purple
        } else {
            return .yellow
        }
    }

    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }

    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(1))
    }

    private func currentMonthName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }

    private func monthLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }

    private func weeksInMonth(for date: Date) -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .weekOfMonth, in: .month, for: date)
        return range?.count ?? 4
    }
}

// MARK: - Calendar Day View

struct CalendarDayView: View {
    let day: DayData
    let habit: Habit
    let store: HabitStore
    @Binding var refreshTrigger: UUID
    @State private var showingEditLog = false
    @State private var showingProgressLog = false

    var body: some View {
        VStack(spacing: 2) {
            Text("\(Calendar.current.component(.day, from: day.date))")
                .font(.caption)
                .fontWeight(day.isToday ? .bold : .regular)
                .foregroundColor(day.isCurrentMonth ? .primary : .secondary.opacity(0.3))

            RoundedRectangle(cornerRadius: 4)
                .fill(colorForIntensity(day.intensity))
                .frame(height: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(day.isToday ? Color.blue : Color.clear, lineWidth: 2)
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(day.isToday ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .opacity(day.isCurrentMonth ? 1.0 : 0.3)
        .onTapGesture {
            if day.log != nil {
                showingEditLog = true
            } else {
                // Allow logging for past days
                if habit.frequencyType == .daily {
                    showingProgressLog = true
                } else {
                    // For times/hours per week, just mark complete
                    store.markComplete(for: habit, date: day.date)
                    refreshTrigger = UUID()
                }
            }
        }
        .sheet(isPresented: $showingEditLog, onDismiss: {
            refreshTrigger = UUID()
        }) {
            EditLogView(habit: habit, store: store, date: day.date, existingLog: day.log)
        }
        .sheet(isPresented: $showingProgressLog, onDismiss: {
            refreshTrigger = UUID()
        }) {
            ProgressLogView(habit: habit, store: store, date: day.date)
        }
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

// MARK: - Day Square View for Insights

struct DaySquareViewInsights: View {
    let day: DayData
    let habit: Habit
    let store: HabitStore
    @Binding var refreshTrigger: UUID
    @State private var showingEditLog = false
    @State private var showingProgressLog = false

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(colorForIntensity(day.intensity))
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(day.isToday ? Color.blue : Color.clear, lineWidth: 1.5)
            )
            .onTapGesture {
                if day.log != nil {
                    showingEditLog = true
                } else {
                    // Allow logging for past days
                    if habit.frequencyType == .daily {
                        showingProgressLog = true
                    } else {
                        // For times/hours per week, just mark complete
                        store.markComplete(for: habit, date: day.date)
                        refreshTrigger = UUID()
                    }
                }
            }
            .sheet(isPresented: $showingEditLog, onDismiss: {
                refreshTrigger = UUID()
            }) {
                EditLogView(habit: habit, store: store, date: day.date, existingLog: day.log)
            }
            .sheet(isPresented: $showingProgressLog, onDismiss: {
                refreshTrigger = UUID()
            }) {
                ProgressLogView(habit: habit, store: store, date: day.date)
            }
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

// MARK: - Metric Cards

struct MetricCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 44, height: 44)
                .background(iconColor.opacity(0.15))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct MetricCardCompact: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.15))
                .cornerRadius(10)

            VStack(spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    @Previewable @State var habit = Habit(name: "100 Push-ups", frequencyType: .daily, targetValue: 100)
    @Previewable @State var store: HabitStore? = nil

    InsightsView(habit: habit, store: store ?? HabitStore(modelContext: ModelContext(try! ModelContainer(for: Habit.self, HabitLog.self))))
        .modelContainer(for: [Habit.self, HabitLog.self], inMemory: true)
}
