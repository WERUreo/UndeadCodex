// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LootGoblin",
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .systemLibrary(
            name: "CLibXML2",
            pkgConfig: "libxml-2.0",
            providers: [
                .apt(["libxml2-dev"])
            ]
        ),
        .executableTarget(
            name: "LootGoblin",
            dependencies: ["CLibXML2"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
        .testTarget(
            name: "LootGoblinTests",
            dependencies: ["LootGoblin"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
    ]
)
