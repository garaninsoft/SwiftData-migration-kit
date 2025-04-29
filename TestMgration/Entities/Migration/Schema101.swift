//
//  Schema100.swift
//  TestMgration
//
//  Created by alexandergaranin on 29.04.2025.
//

import Foundation
import SwiftData

enum Schema101: VersionedSchema {
    static var models: [any PersistentModel.Type] = [Order.self]
    static var versionIdentifier: Schema.Version = .init(1, 0, 1)
    
    @Model
    final class Order {
        var user: User?
        var title: String
        var timestamp: Date
        var isClosed: Bool
        var closed: Date?
        
        init(user: User? = nil, title: String, timestamp: Date, isClosed: Bool = false, closed: Date? = nil) {
            self.user = user
            self.title = title
            self.timestamp = timestamp
            self.isClosed = isClosed
            self.closed = closed
        }
    }
}
