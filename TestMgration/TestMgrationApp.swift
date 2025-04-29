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
    let schema = Schema([User.self, Order.self])
    var modelContainer: ModelContainer
    init() {
        do {
            modelContainer = try ModelContainer(
                for: schema, // Берём всю схему, чтобы был доступ по @Environment(\.modelContext) ко всем моделям
                configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            )
        } catch {
            fatalError("Failed to configure container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if let storeURL = modelContainer.configurations.first?.url {
                // Выведем путь к БД, чтобы в Finder можно было визуально контролировать удаление/создание файлов БД
                Text( storeURL.path)
                    .textSelection(.enabled)
            }
            ContentView()
        }
        .modelContainer(modelContainer)
        .commands {
            // На backspace вешаем операцию delete
            CommandGroup(replacing: .textEditing) {
                Button("Delete") {
                    NSApp.sendAction(#selector(NSText.delete(_:)), to: nil, from: nil)
                }
                .keyboardShortcut(.delete, modifiers: [])
            }
        }
    }
}
