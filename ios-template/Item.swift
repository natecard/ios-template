//
//  Item.swift
//  ios-template
//
//  Created by Nate Card on 2025-11-06.
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
