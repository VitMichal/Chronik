// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Entries",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Entries", targets: ["Entries"]),
    ],
    dependencies: [
        .package(path: "../Generic"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.9.1"),
    ],
    targets: [
        .target(
            name: "Entries",
            dependencies: [
                .product(name: "Generic", package: "Generic"),
                .product(name: "Swinject", package: "Swinject"),
            ]
        ),
        .testTarget(
            name: "EntriesTests",
            dependencies: [
                "Entries",
                .product(name: "Generic", package: "Generic"),
            ]
        ),
    ]
)
