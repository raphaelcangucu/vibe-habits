//
//  TimePeriod.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 06/10/25.
//

import Foundation

enum TimePeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"

    var displayName: String {
        switch self {
        case .week:
            return String(localized: "Week")
        case .month:
            return String(localized: "Month")
        case .year:
            return String(localized: "Year")
        }
    }
}

struct PeriodStatistics {
    let completedDays: Int
    let totalValue: Double
    let completionRate: Double
    let longestStreak: Int
}
