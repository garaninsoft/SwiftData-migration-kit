//
//  MigrationPlan.swift
//  TestMgration
//
//  Created by alexandergaranin on 29.04.2025.
//

import Foundation
import SwiftData

struct MigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] = [Schema100.self, Schema101.self, Schema102.self]
    static var stages: [MigrationStage] = [ stage100to101, stage101to102 ]
    
    static let stage100to101 = MigrationStage.lightweight(
        fromVersion: Schema100.self,
        toVersion: Schema101.self
    )
    
    static let stage101to102: MigrationStage = MigrationStage.custom(
        fromVersion: Schema101.self,
        toVersion: Schema102.self,
        willMigrate: { context in
            let orders = try context.fetch(FetchDescriptor<Schema101.Order>())
            for order in orders{
                order.closed = order.isClosed ? Date() : nil
            }
            try context.save()
        },
        didMigrate: nil
    )
}
