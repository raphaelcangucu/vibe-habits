//
//  HabitsListView.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import SwiftUI
import SwiftData

struct HabitsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt, order: .forward) private var habits: [Habit]

    @State private var showingAddHabit = false

    private var habitStore: HabitStore {
        HabitStore(modelContext: modelContext)
    }

    var body: some View {
        NavigationStack {
            Group {
                if habits.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(habits) { habit in
                                HabitCardView(habit: habit, store: habitStore)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Vibe Habits")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView(store: habitStore)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)

            Text("Start Your Journey")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Create your first habit and build consistency one day at a time")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                showingAddHabit = true
            } label: {
                Label("Add Habit", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
    }
}

#Preview {
    HabitsListView()
        .modelContainer(for: [Habit.self, HabitLog.self], inMemory: true)
}
