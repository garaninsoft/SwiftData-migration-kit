//
//  User.swift
//  TestMgration
//
//  Created by alexandergaranin on 19.04.2025.
//

import SwiftData
import Foundation

@Model
final class User {
    var name: String
    var details: String
    var orders: [Order]?
    
    init(name: String, details: String, orders: [Order]? = nil) {
        self.name = name
        self.details = details
        self.orders = orders
    }
}
