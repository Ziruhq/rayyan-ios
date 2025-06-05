// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "RayyanIOS",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12),
    ],
    products: [
        .library(
            name: "RayyanIOS",
            targets: ["RayyanIOS"]
        ),
        .library(
            name: "SystemControl",
            targets: ["SystemControl"]
        ),
    ],
    targets: [
        // Client Libraries
        .target(
            name: "RayyanIOS",
            dependencies: ["SystemControl"]
        ),
        .target(name: "SystemControl"),

        // Tests
        .testTarget(
            name: "RayyanIOSTests",
            dependencies: ["RayyanIOS"]
        ),
        .testTarget(
            name: "SystemControlTests",
            dependencies: ["SystemControl"]
        ),
    ]
)
