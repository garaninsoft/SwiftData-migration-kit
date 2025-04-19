//
//  TestMgrationApp.swift
//  TestMgration
//
//  Created by alexandergaranin on 17.04.2025.
//

import SwiftUI
import SwiftData

@main
struct TestMgrationApp: App {
    var container: ModelContainer
       init() {
           do {
               container = try ModelContainer(
                for: Item.self,
                configurations: ModelConfiguration(
                    schema: Schema([Item.self]),
                    isStoredInMemoryOnly: false
                )
               )
           } catch {
               fatalError("Failed to configure container: \(error)")
           }
       }

    var body: some Scene {
        WindowGroup {
            if let storeURL = container.configurations.first?.url {
                Text( storeURL.path)
                    .textSelection(.enabled)
            }
            ContentView()
        }
        .modelContainer(container)
        .commands {
            CommandGroup(replacing: .textEditing) {
                Button("Delete") {
                    NSApp.sendAction(#selector(NSText.delete(_:)), to: nil, from: nil)
                }
                .keyboardShortcut(.delete, modifiers: []) // Просто клавиша Delete
            }
        }
    }
}
