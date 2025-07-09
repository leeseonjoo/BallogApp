//
//  Item.swift
//  Ballog
//
//  Created by 이선주 on 7/8/25.
//

import SwiftUI
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
