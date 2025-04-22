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
    var isClosed: Bool
    
    init(user: User? = nil, title: String, timestamp: Date, isClosed: Bool) {
        self.user = user
        self.title = title
        self.timestamp = timestamp
        self.isClosed = isClosed
    }
}
