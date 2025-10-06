//
//  EditLogView.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import SwiftUI
import SwiftData

struct EditLogView: View {
    @Environment(\.dismiss) private var dismiss
    let habit: Habit
    let store: HabitStore
    let date: Date
    let existingLog: HabitLog?

    @State private var progressValue = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(.systemGray4))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)

                    VStack(spacing: 6) {
                        Text(habit.name)
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text(formatDate(date))
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("Target: \(formatValue(habit.targetValue))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                .padding(.bottom, 24)

                // Input Section
                VStack(spacing: 12) {
                    Text("Enter Progress")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    TextField("0", text: $progressValue)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 52, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .frame(maxWidth: 180)
                }
                .padding(.bottom, 32)

                Spacer()

                // Action Buttons
                VStack(spacing: 10) {
                    Button {
                        updateProgress()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.body)
                            Text("Update Progress")
                                .fontWeight(.semibold)
                        }
                        .font(.body)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(progressValue.isEmpty || Double(progressValue) == nil)
                    .opacity((progressValue.isEmpty || Double(progressValue) == nil) ? 0.5 : 1.0)

                    Button(role: .destructive) {
                        deleteProgress()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.fill")
                                .font(.body)
                            Text("Delete Entry")
                                .fontWeight(.medium)
                        }
                        .font(.body)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray6))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let log = existingLog {
                    progressValue = formatValue(log.value)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }

    private func updateProgress() {
        guard let value = Double(progressValue) else { return }
        store.logProgress(for: habit, date: date, value: value)
        dismiss()
    }

    private func deleteProgress() {
        store.deleteLog(for: habit, date: date)
        dismiss()
    }
}

#Preview {
    let habit = Habit(name: "100 Push-ups", frequencyType: .daily, targetValue: 100)
    let log = HabitLog(habitId: habit.id, date: Date(), value: 75, completed: false)
    let store = HabitStore(modelContext: ModelContext(try! ModelContainer(for: Habit.self, HabitLog.self)))

    return EditLogView(habit: habit, store: store, date: Date(), existingLog: log)
        .modelContainer(for: [Habit.self, HabitLog.self], inMemory: true)
}
