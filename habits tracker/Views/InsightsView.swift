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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(habit.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Progress Insights")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)

                    // Metrics Grid
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            MetricCardCompact(
                                icon: "trophy.fill",
                                iconColor: .green,
                                title: "Longest Streak",
                                value: "\(store.getLongestStreak(for: habit))",
                                subtitle: "days"
                            )

                            MetricCardCompact(
                                icon: "calendar",
                                iconColor: .blue,
                                title: "Total Days",
                                value: "\(store.getTotalDays(for: habit))",
                                subtitle: "completed"
                            )
                        }

                        HStack(spacing: 12) {
                            MetricCardCompact(
                                icon: "chart.line.uptrend.xyaxis",
                                iconColor: .purple,
                                title: "Completion Rate",
                                value: "\(Int(store.getCompletionRate(for: habit) * 100))%",
                                subtitle: "of all days"
                            )

                            MetricCardCompact(
                                icon: "star.fill",
                                iconColor: .yellow,
                                title: "Perfect Days",
                                value: "\(store.getPerfectDays(for: habit))",
                                subtitle: "completed"
                            )
                        }

                        MetricCard(
                            icon: "flame.fill",
                            iconColor: .orange,
                            title: "Total Completed",
                            value: formatValue(store.getTotalCompleted(for: habit)),
                            subtitle: "cumulative count"
                        )
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
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
