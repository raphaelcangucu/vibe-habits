//
//  ProgressLogView.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ProgressLogView: View {
    @Environment(\.dismiss) private var dismiss
    let habit: Habit
    let store: HabitStore
    let date: Date

    @State private var progressValue = ""
    @State private var note = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showingPhotoOptions = false
    @State private var showingCamera = false
    @FocusState private var isProgressFocused: Bool

    init(habit: Habit, store: HabitStore, date: Date = Date()) {
        self.habit = habit
        self.store = store
        self.date = date
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(Color(.systemGray4))
                            .frame(width: 36, height: 5)
                            .padding(.top, 8)

                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(habit.name)
                                    .font(.title3)
                                    .fontWeight(.semibold)

                                Text("Target: \(formatValue(habit.targetValue))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text(formatDate(date))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                    }
                    .padding(.bottom, 16)

                    // Progress Input for Daily Habits (outside ScrollView)
                    if habit.frequencyType == .daily {
                        VStack(spacing: 4) {
                            Text("Enter Progress")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Button {
                                isProgressFocused = true
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemGray6))
                                        .frame(width: 180, height: 100)

                                    if progressValue.isEmpty {
                                        Text("0")
                                            .font(.system(size: 52, weight: .semibold, design: .rounded))
                                            .foregroundColor(.secondary.opacity(0.5))
                                    } else {
                                        Text(progressValue)
                                            .font(.system(size: 52, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.bottom, 8)
                    }

                    // Input Section
                    ScrollView {
                        VStack(spacing: 16) {

                        // Photo Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Add Photo (Optional)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if let data = photoData, let uiImage = UIImage(data: data) {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 150)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                        .cornerRadius(12)

                                    Button {
                                        photoData = nil
                                        selectedPhoto = nil
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .background(Circle().fill(Color.black.opacity(0.5)))
                                    }
                                    .padding(8)
                                }
                            } else {
                                HStack(spacing: 12) {
                                    Button {
                                        showingCamera = true
                                    } label: {
                                        VStack(spacing: 8) {
                                            Image(systemName: "camera.fill")
                                                .font(.title2)
                                            Text("Camera")
                                                .font(.caption)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 30)
                                        .background(Color(.systemGray6))
                                        .foregroundColor(.primary)
                                        .cornerRadius(12)
                                    }

                                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                        VStack(spacing: 8) {
                                            Image(systemName: "photo.fill")
                                                .font(.title2)
                                            Text("Gallery")
                                                .font(.caption)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 30)
                                        .background(Color(.systemGray6))
                                        .foregroundColor(.primary)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .sheet(isPresented: $showingCamera) {
                            ImagePicker(photoData: $photoData, sourceType: .camera)
                        }
                        .onChange(of: selectedPhoto) { _, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                    photoData = data
                                }
                            }
                        }

                        // Note Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Add Note (Optional)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            TextField("How did it go?", text: $note, axis: .vertical)
                                .textFieldStyle(.plain)
                                .lineLimit(3...6)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 16)

                Spacer()

                // Action Buttons
                VStack(spacing: 10) {
                    if habit.frequencyType == .daily {
                        // Daily habit: Log progress
                        Button {
                            logProgress()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.body)
                                Text("Log Progress")
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
                    } else {
                        // Times/Hours per week: Mark complete
                        Button {
                            markComplete()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.body)
                                Text("Mark Complete")
                                    .fontWeight(.semibold)
                            }
                            .font(.body)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
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
                        // Auto-focus for daily habits
                        if habit.frequencyType == .daily {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isProgressFocused = true
                            }
                        }
                    }

                // Hidden TextField for keyboard input
                TextField("", text: $progressValue)
                    .keyboardType(.decimalPad)
                    .focused($isProgressFocused)
                    .frame(width: 0, height: 0)
                    .opacity(0)
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

    private func logProgress() {
        guard let value = Double(progressValue) else { return }
        let noteToSave = note.isEmpty ? nil : note
        store.logProgress(for: habit, date: date, value: value, note: noteToSave, photoData: photoData)
        dismiss()
    }

    private func markComplete() {
        let noteToSave = note.isEmpty ? nil : note
        store.logProgress(for: habit, date: date, value: 1.0, note: noteToSave, photoData: photoData)
        dismiss()
    }
}

#Preview {
    @Previewable @State var habit = Habit(name: "100 Push-ups", frequencyType: .daily, targetValue: 100)
    @Previewable @State var store: HabitStore? = nil

    ProgressLogView(habit: habit, store: store ?? HabitStore(modelContext: ModelContext(try! ModelContainer(for: Habit.self, HabitLog.self))))
        .modelContainer(for: [Habit.self, HabitLog.self], inMemory: true)
}
