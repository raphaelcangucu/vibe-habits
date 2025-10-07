//
//  FeedView.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 06/10/25.
//

import SwiftUI
import SwiftData

struct FeedView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var store: HabitStore?
    @State private var allLogs: [HabitLog] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if allLogs.isEmpty {
                        EmptyFeedView()
                    } else {
                        ForEach(allLogs) { log in
                            if let habit = store?.getHabit(for: log) {
                                FeedItemView(log: log, habit: habit, store: store!)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Feed")
            .onAppear {
                if store == nil {
                    store = HabitStore(modelContext: modelContext)
                }
                loadLogs()
            }
            .refreshable {
                loadLogs()
            }
        }
    }

    private func loadLogs() {
        allLogs = store?.getAllLogs() ?? []
    }
}

// MARK: - Feed Item View

struct FeedItemView: View {
    let log: HabitLog
    let habit: Habit
    let store: HabitStore
    @State private var showingEditLog = false
    @State private var showingFullImage = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text(formatDate(log.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Completion badge
                if log.completed {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("\(formatValue(log.value))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }

            // Photo if available
            if let photoData = log.photoData,
               let uiImage = UIImage(data: photoData) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)

                    Button {
                        showingFullImage = true
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Circle().fill(Color.black.opacity(0.6)))
                    }
                    .padding(8)
                }
                .fullScreenCover(isPresented: $showingFullImage) {
                    FullScreenImageView(image: uiImage)
                }
            }

            // Note if available
            if let note = log.note, !note.isEmpty {
                Text(note)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.vertical, 4)
            }

            // Stats
            HStack(spacing: 16) {
                Label("\(formatValue(log.value))", systemImage: "chart.bar.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if log.completed {
                    Label("Completed", systemImage: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .onTapGesture {
            showingEditLog = true
        }
        .sheet(isPresented: $showingEditLog) {
            EditLogView(habit: habit, store: store, date: log.date, existingLog: log)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }
}

// MARK: - Empty Feed View

struct EmptyFeedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Activity Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start logging your habits to see them here!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .padding(.top, 100)
    }
}

// MARK: - Full Screen Image View

struct FullScreenImageView: View {
    @Environment(\.dismiss) private var dismiss
    let image: UIImage
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = lastScale * value
                        }
                        .onEnded { _ in
                            lastScale = scale
                            if scale < 1.0 {
                                withAnimation {
                                    scale = 1.0
                                    lastScale = 1.0
                                }
                            }
                        }
                )
                .gesture(
                    TapGesture(count: 2)
                        .onEnded {
                            withAnimation {
                                if scale > 1.0 {
                                    scale = 1.0
                                    lastScale = 1.0
                                } else {
                                    scale = 2.0
                                    lastScale = 2.0
                                }
                            }
                        }
                )

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    FeedView()
        .modelContainer(for: [Habit.self, HabitLog.self], inMemory: true)
}
