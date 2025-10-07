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

    @State private var progressValue = ""
    @State private var note = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showingPhotoOptions = false
    @State private var showingCamera = false
    @FocusState private var isProgressFocused: Bool

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
                    VStack(spacing: 12) {
                        Text("Enter Progress")
                            .font(.headline)

                        ZStack {
                            // Large tappable background
                            Color(.systemGray6)
                                .frame(height: 100)
                                .cornerRadius(12)
                                .onTapGesture {
                                    isProgressFocused = true
                                }

                            // Display text
                            if progressValue.isEmpty {
                                Text("Tap to enter")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.secondary.opacity(0.5))
                                    .allowsHitTesting(false)
                            } else {
                                Text(progressValue)
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.primary)
                                    .allowsHitTesting(false)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.bottom, 8)

                    // Hidden TextField for actual input
                    TextField("", text: $progressValue)
                        .keyboardType(.decimalPad)
                        .focused($isProgressFocused)
                        .frame(width: 0, height: 0)
                        .opacity(0)

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
                    }
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
            }
            .padding(.horizontal, 24)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
        .onAppear {
            // Auto-focus the text field when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isProgressFocused = true
            }
        }
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
        store.logProgress(for: habit, value: value, note: noteToSave, photoData: photoData)
        dismiss()
    }
}

#Preview {
    @Previewable @State var habit = Habit(name: "100 Push-ups", frequencyType: .daily, targetValue: 100)
    @Previewable @State var store: HabitStore? = nil

    ProgressLogView(habit: habit, store: store ?? HabitStore(modelContext: ModelContext(try! ModelContainer(for: Habit.self, HabitLog.self))))
        .modelContainer(for: [Habit.self, HabitLog.self], inMemory: true)
}
