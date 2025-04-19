//
//  ContentView.swift
//  TestMgration
//
//  Created by alexandergaranin on 17.04.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ItemSchema.Item]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        VStack{
                            Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                            Text(item.anyStringField)
//                            Text("\(item.anyIntField)")
                        }
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
//            let newItem = ItemSchema.Item(timestamp: Date(), anyStringField: "any string from rnd: \(Int.random(in: 0..<32))", anyIntField: Int.random(in: 32..<256))
            let newItem = ItemSchema.Item(timestamp: Date(), anyStringField: "any string from rnd: \(Int.random(in: 0..<32))")
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ItemSchema.Item.self, inMemory: true)
}
