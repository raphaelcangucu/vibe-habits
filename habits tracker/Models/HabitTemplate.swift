import Foundation

struct HabitTemplate: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let colorName: String
    let frequencyType: FrequencyType
    let targetValue: Double

    static let featured: [HabitTemplate] = [
        HabitTemplate(
            id: "water",
            name: String(localized: "Drink water"),
            icon: "drop.fill",
            colorName: "blue",
            frequencyType: .daily,
            targetValue: 8
        ),
        HabitTemplate(
            id: "walk",
            name: String(localized: "Morning walk"),
            icon: "figure.walk",
            colorName: "green",
            frequencyType: .daily,
            targetValue: 30
        ),
        HabitTemplate(
            id: "read",
            name: String(localized: "Read every day"),
            icon: "book.fill",
            colorName: "indigo",
            frequencyType: .daily,
            targetValue: 20
        ),
        HabitTemplate(
            id: "exercise",
            name: String(localized: "Exercise"),
            icon: "figure.strengthtraining.traditional",
            colorName: "orange",
            frequencyType: .timesPerWeek,
            targetValue: 3
        )
    ]
}
