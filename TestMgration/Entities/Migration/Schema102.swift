//
//  Schema100.swift
//  TestMgration
//
//  Created by alexandergaranin on 29.04.2025.
//

import Foundation
import SwiftData

enum Schema102: VersionedSchema {
    static var models: [any PersistentModel.Type] = [Order.self]
    static var versionIdentifier: Schema.Version = .init(1, 0, 2)
}
