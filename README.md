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
    .package(url: "https://github.com/garaninsoft/SwiftDataMigrationKit.git", from: "1.0.0")
]
```

## 🔄 Основные принципы миграции БД в SwiftData
Основной принцип заключается в том, что **SwiftData** старается провести миграцию автоматически. Примеры:
#### 1. Автомиграция при добавлении нового поля
```swift
// Исходная модель
@Model
final class User {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

// Новая модель
@Model
final class User {
    var name: String
    var details: String = ""
    
    init(name: String, details: String) {
        self.name = name
        self.details = details
    }
}
```
Данная миграция не требует обработки и будет проведена автоматически.
Ключевым моментом является добавление в поле **details** значения по умолчанию:
```swift
var details: String = ""
```
Это добавление является 💡 **обязательным условием**. Если по умолчанию требуется вычисляемое значение, то нужна уже обработка миграции.
И это будет рассмотрено в примере.
> 💡 **Возможно, полезный момент**  
> после запуска приложения с изменной моделью, в дальнейшем присвоение значение по умолчанию в строке
> ```swift
> var details: String = ""
> ```
> можно будет убрать. 

Так же возможно добавление опционального поля:
```swift
// Новая модель
@Model
final class User {
    var name: String
    var details: String?
    
    init(name: String, details: String) {
        self.name = name
        self.details = details
    }
}
```
В этом случае **SwiftData** при отсутствии значения по умолчанию установит во всех записях нового поля значение **nil**

#### 2. Автомиграция при удалении поля
```swift
// Исходная модель
@Model
final class User {
    var name: String
    var details: String
    
    init(name: String, details: String) {
        self.name = name
        self.details = details
    }
}

// Новая модель
@Model
final class User {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}
```
Данная миграция удалит поле **details** с потерей всех данных.

#### 3. Автомиграция при изменении типа данных поля
Если в поле меняется тип данных, то при автомиграции **SwiftData** будет пытаться сделать преобразование по правилам преобразования типов в языке программирования **Swift**
Например:
```swift
// Исходная модель
@Model
final class User {
    var name: String
    var age: Double
    
    init(name: String, age: Double) {
        self.name = name
        self.age = age
    }
}

// Новая модель
@Model
final class User {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}
```
В поле **age** произойдёт отбрасывание дробной части. 
Добавим, что автомиграция сможет без проблем обработать преобразование в опциональный тип данных: `var age: Int` -> `var age: Int?`
Однако, при обратном преобразовании `var age: Int?` -> `var age: Int` нужно иметь в виду, что если в какой-либо записи было заначение **nil**,
то **SwiftData** не сможет это обработать. Будет выдано исключение. И нужно будет поставить значение по умолчанию: 
```swift
// Новая модель
@Model
final class User {
    var name: String
    var age: Int = 0
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}
```
В этом примере есть интересный момент, который рассмотрим ниже.

#### 4. Автомиграция при изменении нескольких полей
Описанные выше автомиграции можно комбинировать. Например:
```swift
// Исходная модель
@Model
final class User {
    var name: String
    var details: String
    var age: Double?
    
    init(name: String, details: String, age: Double?) {
        self.name = name
        self.details = details
        self.age = age
    }
}

// Новая модель
@Model
final class User {
    var name: String
    var fname: String = ""
    var age: Int = 0
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}
```
💡 Рассмотрим здесь внимательно изменения при миграции:
> Поле **details** будет удалено
> Поле **fname** будет добавлено со значением по умолчанию пустая строка.
> Поле **age** - самое интересное. Оно изначально опциональное **Double?**. Поэтому,
>  - если были каки-либо значения, то они будут сохранены, но отброшена дробная часть при преобразовании в **Int**
>  - если в поле был **nil**, то вместо него будет записано значение по умолчанию равное 0.


## 🔄 Пример обработки миграции БД в SwiftData
Сформулируем небольшую задачу по миграции.
### 🎯 Задача
В **Branch** 🌿 main
Собрано простое приложение, где есть связанные таблицы:
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
    var isClosed: Bool
    
    init(user: User? = nil, title: String, timestamp: Date, isClosed: Bool) {
        self.user = user
        self.title = title
        self.timestamp = timestamp
        self.isClosed = isClosed
    }
}

```
Предстоит написать миграцию, которая сделает следующие изменения:
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
    var closed: Date?
    
    init(user: User? = nil, title: String, timestamp: Date, closed: Date? = nil) {
        self.user = user
        self.title = title
        self.timestamp = timestamp
        self.closed = closed
    }
}
```
То есть, нужно в модели **Order** 
заменить поле `var isClosed: Bool` на `var closed: Date?`
при этом, замену булевого типа в **Date** проведём по правилам:
- если **isClosed == false**, то **closed = nil**
- если **isClosed == true**, то **closed** получит просто текущую дату.
модель **User** не затрагивается

ℹ️ **Информация:**
Для удобства на интерфейсе тестового приложения показан путь к файлам БД (по умолчанию название базы данных **default**): 
- default.store (это основной файл БД)
- default.store-shm
- default.store-wal

Для удобства отслеживания изменений в бд во время экспериментов над миграцией лучше пользоваться ещё клиентом типа
**DB Browser for SQLite**. При этом надо открыть файл **default.store**

---
Для проведения задуманного изменения в модели **User** необходимо добавить поле `var closed: Date?` и удалить поле `var isClosed: Bool`
С этой задачей вполне бы справилась автомиграция, если бы не было зависимости поля **closed** от поля **isClosed**

При этом, ручная миграция может быть проведена двумя способами. Способы не сильно отличаются, и расположены в ветках **migration1** и **migration2**

## Branch 🔧 migration1
Создаётся три переходных схемы, реализующих протокол `VersionedSchema`:

```swift
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

enum Schema101: VersionedSchema {
    static var models: [any PersistentModel.Type] = [Order.self]
    static var versionIdentifier: Schema.Version = .init(1, 0, 1)
    
    @Model
    final class Order {
        var user: User?
        var title: String
        var timestamp: Date
        var isClosed: Bool
        var closed: Date? // Обращаю внимание, что если бы это было не опциональное поле, то требовалось бы значение по умолчанию. Как в автомиграции
        
        init(user: User? = nil, title: String, timestamp: Date, isClosed: Bool = false, closed: Date? = nil) {
            self.user = user
            self.title = title
            self.timestamp = timestamp
            self.isClosed = isClosed
            self.closed = closed
        }
    }
}

enum Schema102: VersionedSchema {
    static var models: [any PersistentModel.Type] = [Order.self]
    static var versionIdentifier: Schema.Version = .init(1, 0, 2)
}
```
💡 Ключевые моменты:
> 1. В `static var models: [any PersistentModel.Type] = [Order.self]` следует указывать только те модели, которые будут изменены.
> 2. В схемах, реализующих протокол `VersionedSchema` лучше описывать промежуточные состояния изменяемой модели. Тогда как, в последней схеме
>    сама актуальная модель храниться в предназначенном для неё заранее месте.
> 3. Номера версий должны быть всегда уникальны `static var versionIdentifier: Schema.Version = .init(1, 0, 1)`. Название же `enum Schema101: VersionedSchema {...}`
>    может быть произвольным, но, понятное дело, понятным дла разработчиков.

Далее создаётся план миграции, реализующий протокол `SchemaMigrationPlan`:

```swift
import Foundation
import SwiftData

struct MigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] = [Schema100.self, Schema101.self, Schema102.self]
    static var stages: [MigrationStage] = [ stage100to101, stage101to102 ]
    
    static let stage100to101: MigrationStage = MigrationStage.custom(
        fromVersion: Schema100.self,
        toVersion: Schema101.self,
        willMigrate: nil,
        didMigrate: { context in
            let orders = try context.fetch(FetchDescriptor<Schema101.Order>())
            for order in orders{
                order.closed = order.isClosed ? Date() : nil
            }
            
            try context.save()
        }
    )
    
    static let stage101to102 = MigrationStage.lightweight(
        fromVersion: Schema101.self,
        toVersion: Schema102.self
    )
}
```
💡 Ключевые моменты:
> 1. В данном варианте миграции используется `didMigrate`. То есть, после добавления поля `var closed: Date?` в него будут заноситься данные относительно `isClosed` 
> 2. В последнем `stage101to102` удаляется поле `isClosed`. По сути - это автомиграция. Поэтому используется простой MigrationStage.lightweight(...)
> 3. Порядок выполнения шагов миграции внутри `static var stages: [MigrationStage] = [ stage100to101, stage101to102 ]` должен соответствовать. 

## Branch 🔧 migration2
Отличием от первого варианта будет только реализация протокола `SchemaMigrationPlan`:

```swift
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
```
💡 Ключевые моменты:
> 1. В данном варианте миграции используется `willMigrate`. То есть, перед удалением поля `isClosed` данные из него будут использованы для формирования данных для `closed` 
> 2. `stage100to101` имеет облегчённый вариант миграции, так как там просто добавляется поле `var closed: Date?`

«Если этот код спас вам неделю работы — купите мне кофе!»

**Поддержать через СБП:**  
📱 `+7 (925) 502-27-41` 
