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
        self.rawValue
    }

    var unit: String {
        switch self {
        case .daily:
            return "per day"
        case .timesPerWeek:
            return "times/week"
        case .hoursPerWeek:
            return "hours/week"
        }
    }
}
