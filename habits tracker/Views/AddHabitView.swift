//
//  AddHabitView.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    let store: HabitStore

    @State private var habitName = ""
    @State private var selectedFrequency: FrequencyType = .daily
    @State private var targetValue = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("e.g., 100 Push-ups, Read a book", text: $habitName)
                } header: {
                    Text("Habit Name")
                }

                Section {
                    ForEach(FrequencyType.allCases, id: \.self) { frequency in
                        FrequencyCard(
                            frequency: frequency,
                            isSelected: selectedFrequency == frequency
                        ) {
                            selectedFrequency = frequency
                        }
                    }
                } header: {
                    Text("Frequency")
                }

                Section {
                    TextField(placeholderForFrequency, text: $targetValue)
                        .keyboardType(.decimalPad)
                } header: {
                    Text(labelForFrequency)
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Examples:")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        ExampleRow(icon: "figure.strengthtraining.traditional", text: "Daily: 100 Push-ups")
                        ExampleRow(icon: "book.fill", text: "2–3x/week: Read a book chapter")
                        ExampleRow(icon: "laptopcomputer", text: "6h/week: Work on side project")
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    Button {
                        createHabit()
                    } label: {
                        Text("Create Habit")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var isValid: Bool {
        !habitName.isEmpty && !targetValue.isEmpty && Double(targetValue) != nil
    }

    private var labelForFrequency: String {
        switch selectedFrequency {
        case .daily:
            return "Daily Target"
        case .timesPerWeek:
            return "Times per Week"
        case .hoursPerWeek:
            return "Hours per Week"
        }
    }

    private var placeholderForFrequency: String {
        switch selectedFrequency {
        case .daily:
            return "100"
        case .timesPerWeek:
            return "3"
        case .hoursPerWeek:
            return "6"
        }
    }

    private func createHabit() {
        guard let value = Double(targetValue) else { return }
        store.addHabit(name: habitName, frequencyType: selectedFrequency, targetValue: value)
        dismiss()
    }
}

// MARK: - Frequency Card

struct FrequencyCard: View {
    let frequency: FrequencyType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(frequency.description)
                        .font(.body)
                        .foregroundColor(.primary)

                    Text(frequency.unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Example Row

struct ExampleRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    @Previewable @State var store: HabitStore? = nil

    AddHabitView(store: store ?? HabitStore(modelContext: ModelContext(try! ModelContainer(for: Habit.self, HabitLog.self))))
}
