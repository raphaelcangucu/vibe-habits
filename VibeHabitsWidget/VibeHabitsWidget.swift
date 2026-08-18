import SwiftUI
import WidgetKit

private struct WidgetHabitSnapshot: Codable {
    let habitName: String?
    let completedToday: Int
    let totalHabits: Int
    let updatedAt: Date
}

private struct VibeHabitsEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetHabitSnapshot
}

private struct VibeHabitsProvider: TimelineProvider {
    private let appGroup = "group.app.vibehabits.ios"
    private let snapshotKey = "widgetHabitSnapshot"

    func placeholder(in context: Context) -> VibeHabitsEntry {
        VibeHabitsEntry(date: Date(), snapshot: .init(
            habitName: String(localized: "Morning walk"),
            completedToday: 2,
            totalHabits: 3,
            updatedAt: Date()
        ))
    }

    func getSnapshot(in context: Context, completion: @escaping (VibeHabitsEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VibeHabitsEntry>) -> Void) {
        let current = entry()
        let refresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [current], policy: .after(refresh)))
    }

    private func entry() -> VibeHabitsEntry {
        let fallback = WidgetHabitSnapshot(habitName: nil, completedToday: 0, totalHabits: 0, updatedAt: Date())
        guard
            let defaults = UserDefaults(suiteName: appGroup),
            let data = defaults.data(forKey: snapshotKey),
            let snapshot = try? JSONDecoder().decode(WidgetHabitSnapshot.self, from: data)
        else {
            return VibeHabitsEntry(date: Date(), snapshot: fallback)
        }
        return VibeHabitsEntry(date: Date(), snapshot: snapshot)
    }
}

private struct VibeHabitsWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: VibeHabitsEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
                Text("Vibe Habits")
                    .font(.headline)
                Spacer()
            }

            if entry.snapshot.totalHabits == 0 {
                Text("Start your first habit")
                    .font(.title3.bold())
                Text("A small step today builds momentum.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Today")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("\(entry.snapshot.completedToday)")
                        .font(.system(size: family == .systemSmall ? 38 : 46, weight: .bold, design: .rounded))
                    Text("of \(entry.snapshot.totalHabits) complete")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if family != .systemSmall, let habitName = entry.snapshot.habitName {
                    Label(habitName, systemImage: "arrow.right.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.blue)
                }
            }

            Spacer(minLength: 0)
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color.blue.opacity(0.12), Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .accessibilityElement(children: .combine)
    }
}

struct VibeHabitsWidget: Widget {
    let kind = "VibeHabitsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VibeHabitsProvider()) { entry in
            VibeHabitsWidgetView(entry: entry)
        }
        .configurationDisplayName("Vibe Habits")
        .description("See today's momentum at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct VibeHabitsWidgetBundle: WidgetBundle {
    var body: some Widget {
        VibeHabitsWidget()
    }
}
