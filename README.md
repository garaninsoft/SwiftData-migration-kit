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

🔄 Core Principles of SwiftData DB Migration
The main principle is that SwiftData tries to perform migration automatically. Examples:
1. Automatic migration when adding a new field
