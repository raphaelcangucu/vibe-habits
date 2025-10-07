//
//  EditLogView.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditLogView: View {
    @Environment(\.dismiss) private var dismiss
    let habit: Habit
    let store: HabitStore
    let date: Date
    let existingLog: HabitLog?

    @State private var progressValue = ""
    @State private var note = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showingPhotoOptions = false
    @State private var showingCamera = false
    @FocusState private var isProgressFocused: Bool

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
                        // Daily habit: Update or Delete
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
                    } else {
                        // Times/Hours per week: Update notes/photo or Delete
                        if existingLog != nil {
                            Button {
                                updateProgress()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.body)
                                    Text("Save Changes")
                                        .fontWeight(.semibold)
                                }
                                .font(.body)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }

                            Button(role: .destructive) {
                                deleteProgress()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.body)
                                    Text("Unmark as Completed")
                                        .fontWeight(.semibold)
                                }
                                .font(.body)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(12)
                            }
                        } else {
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
                            note = log.note ?? ""
                            photoData = log.photoData
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

    private func updateProgress() {
        let noteToSave = note.isEmpty ? nil : note

        if habit.frequencyType == .daily {
            guard let value = Double(progressValue) else { return }
            store.logProgress(for: habit, date: date, value: value, note: noteToSave, photoData: photoData)
        } else {
            // For times/hours per week, update note and photo, keep value as 1
            let value = existingLog?.value ?? 1.0
            store.logProgress(for: habit, date: date, value: value, note: noteToSave, photoData: photoData)
        }
        dismiss()
    }

    private func markComplete() {
        let noteToSave = note.isEmpty ? nil : note
        store.logProgress(for: habit, date: date, value: 1.0, note: noteToSave, photoData: photoData)
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
