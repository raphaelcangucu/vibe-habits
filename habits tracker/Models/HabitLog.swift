//
//  HabitLog.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import Foundation
import SwiftData

@Model
final class HabitLog {
    var id: UUID
    var habitId: UUID
    var date: Date
    var value: Double
    var completed: Bool
    var note: String?
    var photoData: Data?

    init(habitId: UUID, date: Date, value: Double, completed: Bool = false, note: String? = nil, photoData: Data? = nil) {
        self.id = UUID()
        self.habitId = habitId
        self.date = date
        self.value = value
        self.completed = completed
        self.note = note
        self.photoData = photoData
    }

    var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
