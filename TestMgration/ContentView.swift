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
    @Query private var users: [User]

    @State var selectedUser: User?
    @State var selectedOrder: Order?
    
    var body: some View {
        NavigationSplitView {
            // Список users
            List(selection: $selectedUser) {
                ForEach(users) { user in
                    NavigationLink (user.name, value: user)
                }
                .onDelete(perform: deleteUsers)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                // Только кнопка "добавить". Кнопка "удалить" в стандарном меню или backspace
                ToolbarItem {
                    Button(action: addUser) {
                        Label("Add User", systemImage: "plus")
                    }
                }
            }
        } content:{
            NavigationStack{
                if let user = selectedUser {
                    let orders = user.orders ?? []
                    // Список orders для выбранного user-а
                    List(orders, selection: $selectedOrder) { order in
                        NavigationLink(order.title, value: order)
                    }
                }
            }
            .navigationTitle("Orders")
            .toolbar {
                ToolbarItem {
                    Button(action: {addOrder()}) {
                        Label("Add Order", systemImage: "plus")
                    }
                }
                ToolbarItem {
                    Button(action: {deleteOrder()}) {
                        Label("Delete Order", systemImage: "trash")
                    }
                }
            }
        }detail: {
            if let user = selectedUser{
                VStack{
                    Text("User name: \(user.name)")
                    Text("User details: \(user.details)")
                }
                if let order = selectedOrder {
                    Divider()
                    VStack{
                        Text("Order: \(order.title)")
                        Text("timestamp: \(order.timestamp.formatted(date: .numeric, time: .standard)))")
                    }
                }
            }else{
                Text("Select an user")
            }
        }
    }

    // имя и детали для user генерим из текущего Date()
    private func addUser() {
        withAnimation {
            let formatter = DateFormatter()
            formatter.dateFormat = "SSS"
            let name = "User created at \(formatter.string(from: Date())) milliseconds"
            let details = "Details \(Date().formatted(date: .numeric, time: .standard))"
            let newUser = User(name: name, details: details)
            modelContext.insert(newUser)
        }
    }
    
    // для order так же генерим из текущего Date()
    private func addOrder() {
        if let user = selectedUser{
            withAnimation {
                let formatter = DateFormatter()
                formatter.dateFormat = "SSS"
                let title = "Order created at \(formatter.string(from: Date())) milliseconds"
                let newOrder = Order(title: title, timestamp: Date())
                user.orders?.append(newOrder)
            }
        }
    }

    private func deleteUsers(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(users[index])
            }
            selectedUser = nil
            selectedOrder = nil
        }
    }
    
    private func deleteOrder() {
        if let order = selectedOrder{
            withAnimation {
                modelContext.delete(order)
                try? modelContext.save()
            }
            selectedOrder = nil
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: User.self, inMemory: true)
}
