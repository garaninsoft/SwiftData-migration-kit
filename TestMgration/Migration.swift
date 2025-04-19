//
//  Migration.swift
//  TestMgration
//
//  Created by alexandergaranin on 17.04.2025.
//

import SwiftData
import Foundation

enum ItemSchema: VersionedSchema {
    static var models: [any PersistentModel.Type] = [Item.self]
    static var versionIdentifier: Schema.Version = .init(2, 0, 1)
    
    @Model
    final class Item {
        var timestamp: Date
        var anyStringField: String
        
        init(timestamp: Date, anyStringField: String) {
            self.timestamp = timestamp
            self.anyStringField = anyStringField
        }
    }
}

enum OldItemSchema: VersionedSchema {
    static var models: [any PersistentModel.Type] = [Item.self]
    static var versionIdentifier: Schema.Version = .init(2, 0, 0)
    
    @Model
    final class Item {
        var timestamp: Date
        var anyStringField: String
        var anyIntField: Int = 0
        
        init(timestamp: Date, anyStringField: String, anyIntField: Int) {
            self.timestamp = timestamp
            self.anyStringField = anyStringField
            self.anyIntField = anyIntField
        }
    }
}


//struct ItemMigrationPlan: SchemaMigrationPlan {
//    static var schemas: [any VersionedSchema.Type] = [OldItemSchema.self, ItemSchema.self]
//    
//    static var stages: [MigrationStage] = [
//        MigrationStage.custom(
//            fromVersion: OldItemSchema.self,
//            toVersion: ItemSchema.self,
//            willMigrate: { context in
//                let oldItems = try context.fetch(FetchDescriptor<OldItemSchema.Item>())
//                for item in oldItems {
//                    let newItem = OldItemSchema.Item(
//                        timestamp: item.timestamp,
//                        anyField: "new text",
//                        newField: item.newField
//                    )
//                    context.insert(newItem)
//                }
//                try context.save()
//            },
//            didMigrate: { context in
//                let oldItems = try context.fetch(FetchDescriptor<ItemSchema.Item>())
//                for item in oldItems {
//                    let newItem = ItemSchema.Item(
//                        timestamp: item.timestamp,
//                        anyField: item.anyField,
//                        newField: Int(item.anyField.suffix(2)) ?? 0
//                    )
//                    context.insert(newItem)
//                }
//                try context.save()
//            }
//        )
//    ]
//}
