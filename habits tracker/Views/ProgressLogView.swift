//
//  ProgressLogView.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import SwiftUI
import SwiftData

struct ProgressLogView: View {
    @Environment(\.dismiss) private var dismiss
    let habit: Habit
    let store: HabitStore

    @State private var progressValue = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 50))
                        .foregroundStyle(.blue.gradient)

                    Text(habit.name)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Target: \(formatValue(habit.targetValue))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)

                VStack(spacing: 16) {
                    Text("Enter Progress")
                        .font(.headline)

                    TextField("0", text: $progressValue)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 48, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .frame(maxWidth: 200)
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        logProgress()
                    } label: {
                        Text("Log Progress")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(progressValue.isEmpty || Double(progressValue) == nil)

                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }

    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }

    private func logProgress() {
        guard let value = Double(progressValue) else { return }
        store.logProgress(for: habit, value: value)
        dismiss()
    }
}

#Preview {
    @Previewable @State var habit = Habit(name: "100 Push-ups", frequencyType: .daily, targetValue: 100)
    @Previewable @State var store: HabitStore? = nil

    ProgressLogView(habit: habit, store: store ?? HabitStore(modelContext: ModelContext(try! ModelContainer(for: Habit.self, HabitLog.self))))
        .modelContainer(for: [Habit.self, HabitLog.self], inMemory: true)
}
