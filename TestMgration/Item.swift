//
//  Item.swift
//  TestMgration
//
//  Created by alexandergaranin on 19.04.2025.
//
import SwiftData
import Foundation
@Model
final class Item {
    var timestamp: Date
    var anyStringField: String
    
    init(timestamp: Date, anyStringField: String) {
        self.timestamp = timestamp
        self.anyStringField = anyStringField
    }
}
