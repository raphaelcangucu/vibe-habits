//
//  FrequencyType.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import Foundation

enum FrequencyType: String, Codable, CaseIterable {
    case daily = "Daily Goal"
    case timesPerWeek = "Times per Week"
    case hoursPerWeek = "Hours per Week"

    var description: String {
        switch self {
        case .daily:
            String(localized: "Daily Goal")
        case .timesPerWeek:
            String(localized: "Times per Week")
        case .hoursPerWeek:
            String(localized: "Hours per Week")
        }
    }

    var unit: String {
        switch self {
        case .daily:
            return String(localized: "per day")
        case .timesPerWeek:
            return String(localized: "times/week")
        case .hoursPerWeek:
            return String(localized: "hours/week")
        }
    }
}
