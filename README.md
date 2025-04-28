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
Автомиграция без проблем обработает преобразование поля в тот же, но опциональный тип: ```swift var age: Int ``` -> ```swift var age: Int? ```
Однако, при обратном преобразовании ```swift var age: Int? ``` -> ```swift var age: Int ``` нужно иметь в виду, что если в какой-либо записи было заначение **nil**,
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
💡 Рассмотрим здесь внимательно изменения:
> Поле **details** будет удалено
> Поле **fname** будет добавлено со значением по умолчанию пустая строка.
> Поле **age** - самое интересное. Оно изначально опциональное **Double?**. Поэтому,
>  - если были каки-либо значения, то они будут сохранены, но отброшена дробная часть при преобразовании в **Int**
>  - если в поле был **nil**, то вместо него будет записано значение по умолчанию равное 0.





## 🎯 Задача

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
   Если модель не участвует в связи один-много, то явный id можно не добавлять (_проверить_)
