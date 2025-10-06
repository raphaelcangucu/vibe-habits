//
//  Item.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
