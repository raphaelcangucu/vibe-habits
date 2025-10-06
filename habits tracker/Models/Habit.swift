//
//  Habit.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var frequencyType: FrequencyType
    var targetValue: Double
    var createdAt: Date

    init(name: String, frequencyType: FrequencyType, targetValue: Double) {
        self.id = UUID()
        self.name = name
        self.frequencyType = frequencyType
        self.targetValue = targetValue
        self.createdAt = Date()
    }

    // Computed properties for display
    var subtitle: String {
        let targetString = formatValue(targetValue)
        return "\(frequencyType.description): \(targetString)"
    }

    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }
}
