Hi! This is the SwiftData Migration Kit in English. [Русская версия →](README.ru.md)

# SwiftData Migration Kit 🧰

[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![SwiftData](https://img.shields.io/badge/SwiftData-✓-blue.svg)](https://developer.apple.com/documentation/swiftdata)
[![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

**Solving real SwiftData migration problems** — proven practices that Apple hasn't documented. Based on rigorous experiments and past bugs.

## 🔥 Features

✅ Working migrations for Xcode 16.3+  
✅ Data preservation during model updates  
✅ Workarounds for errors like _"Cannot use staged migration with an unknown model version"_  
✅ Support for complex data transformations  

## 🛠 Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/garaninsoft/SwiftDataMigrationKit.git", from: "1.0.0")
]
```

## 🔄 Core Principles of SwiftData DB Migration
The main principle is that **SwiftData** tries to perform migration automatically. Examples:
#### 1. Automatic migration when adding a new field
```swift
// Original model
@Model
final class User {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

// New model
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
This migration does not require manual handling and will be applied automatically.
The key point is adding a default value to the **details** field:
```swift
var details: String = ""
```
This addition is 💡 **mandatory**. If a computed default is required, manual migration is needed.
We'll cover this in an example.
> 💡 **Helpful note**  
> After running the app with the modified model, the default assignment
> ```swift
> var details: String = ""
> ```
> can later be removed.

You can also add an optional field:
```swift
// New model
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
In this case, **SwiftData** will set all new field entries to **nil** if no default value is provided.

#### 2. Automatic migration when removing a field
```swift
// Original model
@Model
final class User {
    var name: String
    var details: String
    
    init(name: String, details: String) {
        self.name = name
        self.details = details
    }
}

// New model
@Model
final class User {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}
```
This migration will remove the **details** field and all its data.

#### 3. Automatic migration when changing a field type
If a field's data type changes, **SwiftData** will try to convert it according to **Swift**'s type conversion rules.
Example:
```swift
// Original model
@Model
final class User {
    var name: String
    var age: Double
    
    init(name: String, age: Double) {
        self.name = name
        self.age = age
    }
}

// New model
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
The **age** field will have its fractional part truncated. 
Automatic migration can also handle conversion to optional types: `var age: Int` -> `var age: Int?`
However, the reverse `var age: Int?` -> `var age: Int` will throw an exception if any record has **nil**, so a default value is required: 
```swift
// New model
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
This example contains an important nuance, discussed below.

#### 4. Automatic migration with multiple field changes
The above migrations can be combined. Example:
```swift
// Original model
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

// New model
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
💡 Migration details:
> Field **details** бwill be removed.
> Field **fname** will be added with default empty string.
> Field **age** was originally optional **Double?**:
>  - Existing values are preserved, fractional part truncated for **Int** conversion
>  - **nil** values will be replaced with default 0.


## 🔄 Example of SwiftData DB Migration Handling
Let's formulate a small migration task.
### 🎯 Task
In **Branch** 🌿 main
a simple app has linked tables:
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
We want to migrate **Order**:
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
Replace `var isClosed: Bool` with `var closed: Date?` using rules:
- `isClosed == false` → `closed = nil`
- `isClosed == true` → `closed = current date`

ℹ️ **Info:**
For convenience, the test app interface shows the paths to the database files (the default database is named **default**): 
- default.store (main db file)
- default.store-shm
- default.store-wal

For easier tracking of database changes during migration experiments, it’s recommended to use a client like **DB Browser for SQLite**.  
You should open the **default.store** file in the client.

---
To implement the planned change in the **User** model, it is necessary to add the field `var closed: Date?` and remove the field `var isClosed: Bool`.
An auto-migration could have handled this task if not for the dependency of the **closed** field on the **isClosed** field.
The manual migration can be performed in two ways. The methods do not differ significantly and are located in the **migration1** and **migration2** branches.

## Branch 🔧 migration1
Three transitional schemas are created that implement the `VersionedSchema` protocol:

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
        var closed: Date? //  Note that if this were a non-optional field, it would require a default value, as in an auto-migration.
        
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
💡 Key points:
> 1. `static var models: [any PersistentModel.Type] = [Order.self]` should only include the models that will be modified.
> 2. Schemas implementing the `VersionedSchema` protocol are better suited for describing intermediate states of the modified model. Whereas the final schema
>    for the actual model itself should be stored in its designated predefined location.
> 3. Version numbers must always be unique `static var versionIdentifier: Schema.Version = .init(1, 0, 1)`. The name of `enum Schema101: VersionedSchema {...}`
>    can be arbitrary, but should obviously be clear and understandable for developers.

Next, a migration plan is created that implements the `SchemaMigrationPlan` protocol:

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
💡 Key points:
> 1. This migration approach uses `didMigrate`. That is, after adding the field `var closed: Date?`, data will be populated into it based on `isClosed`.
> 2. In the final `stage101to102`, the `isClosed` field is removed. Essentially, this is an auto-migration. Therefore, a simple `MigrationStage.lightweight(...)` is used.
> 3. The order of migration steps within `static var stages: [MigrationStage] = [ stage100to101, stage101to102 ]` must be sequential.

## Branch 🔧 migration2
The difference from the first approach lies only in the implementation of the `SchemaMigrationPlan` protocol:

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
💡 Key points:
> 1. This migration approach uses `willMigrate`. That is, before removing the `isClosed` field, its data will be used to populate the `closed` field.
> 2. `stage100to101` uses a lightweight migration since it only adds the field `var closed: Date?`.

"If this code saved you a week of work — buy me a coffee!"

**Support via PayPal:**  
 `garaninsoft@gmail.com`
