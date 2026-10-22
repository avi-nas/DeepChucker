// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "DeepChucker",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "DeepChucker",
            targets: ["DeepChucker"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DeepChucker",
            dependencies: [],
            path: "Sources/DeepChucker",
            exclude: [
                "Models/Postman/Postman_demo_collection.json"
            ],
            resources: [
                .process("Resources/Assets.xcassets")
            ]
        ),
        .testTarget(
            name: "DeepChuckerTests",
            dependencies: [
                "DeepChucker"
            ],
            path: "Tests/DeepChuckerTests"
        ),
    ]
)
