//
//  Order.swift
//  TestMgration
//
//  Created by alexandergaranin on 21.04.2025.
//

import SwiftData
import Foundation

@Model
final class Order {
    var user: User?
    var title: String
    var timestamp: Date
    
    init(user: User? = nil, title: String, timestamp: Date) {
        self.user = user
        self.title = title
        self.timestamp = timestamp
    }
}
