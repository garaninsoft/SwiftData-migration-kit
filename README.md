# SwiftData Migration Kit 🧰

[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![SwiftData](https://img.shields.io/badge/SwiftData-✓-blue.svg)](https://developer.apple.com/documentation/swiftdata)
[![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

**Решение реальных проблем миграций в SwiftData** — проверенные практики, которые Apple не документировала. Основано на жестких экспериментах и пройденных багах.

## 🔥 Особенности

✅ Рабочие миграции для Xcode 16.3+  
✅ Сохранение данных при обновлении модели  
✅ Обход ошибок типа _"Cannot use staged migration with an unknown model version"_  
✅ Поддержка сложных преобразований данных  

## 🛠 Установка

Добавьте в ваш `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ВАШ_НИК/SwiftDataMigrationKit.git", from: "1.0.0")
]
```
---
## Branch 🌿 main
Начальное приложение, где есть связанные таблицы:
```swift
@Model
final class User {
    var name: String
    var details: String
    var orders: [Order]?
    
    init(name: String, details: String, orders: [Order]? = nil) {
        self.name = name
        self.details = details
        self.orders = orders
    }
}

@Model
final class Order {
    var user: User?
    var title: String
    var timestamp: Date
    
    init(user: User? = nil, title: String, timestamp: Date) {
        self.user = user
        self.title = title
        self.timestamp = timestamp
    }
}
```
При попытке провести миграции будем получать ошибку: **"Cannot use staged migration with an unknown model version"**
Требуется обёртка всех **@Models** в протокол **VersionedSchema**

---
## Branch 🔧 step1-add-version
Этот шаг понадобится, если уже есть база со сначительным количеством данных, которые необходимо сохранить. 
Если не жалко бд, то переходим к следующей ветке, предварительно удалив три файла из папки, которая показана в верхней части интерфейса

1. Добавляем в модели явные id-ки, которые потом можно будет оставить. 
