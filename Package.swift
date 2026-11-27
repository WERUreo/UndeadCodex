// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UndeadCodex",
    products: [
        .executable(
            name: "undead-codex",
            targets: ["UndeadCodex"]
        ),
    ],
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
            name: "UndeadCodex",
            dependencies: ["CLibXML2"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
        .testTarget(
            name: "UndeadCodexTests",
            dependencies: ["UndeadCodex"],
            resources: [
                .copy("Fixtures")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
    ]
)
