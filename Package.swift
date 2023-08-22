// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let packageName = "RoomPlan 2D" // <-- Change this to yours


let package = Package(
    name: "",
    platforms: [.iOS("16.3")],
    products: [
        .library(name: packageName, targets: [packageName])
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: packageName,
            path: packageName),
    ]
)
