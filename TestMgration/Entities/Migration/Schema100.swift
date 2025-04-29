//
//  Schema100.swift
//  TestMgration
//
//  Created by alexandergaranin on 29.04.2025.
//

import Foundation
import SwiftData

enum Schema100: VersionedSchema {
    static var models: [any PersistentModel.Type] = [Order.self]
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    
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
}
