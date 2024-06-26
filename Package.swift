// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "todo",
    products: [
        .executable(
            name: "todo",
            targets: ["todo"]),
    ],
    targets: [
        .executableTarget(
            name: "todo",
            sources: ["main.swift"]),
        .testTarget(
            name: "tests",
            dependencies: ["todo"]),
    ]
)