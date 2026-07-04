// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SwiftDBServer",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(
            url: "https://github.com/vapor/vapor.git",
            from: "4.100.0"
        ),
        .package(
            url: "https://github.com/vapor/fluent-kit.git",
            from: "1.49.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "SwiftDBServer",
            dependencies: [
                .product(
                    name: "Vapor",
                    package: "vapor"
                ),
                .product(
                    name: "FluentKit",
                    package: "fluent-kit"
                )
            ]
        )
    ]
)
