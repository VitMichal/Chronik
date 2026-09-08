// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Generic",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Generic", targets: ["Generic"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.9.1"),
    ],
    targets: [
        .target(
            name: "Generic",
            dependencies: [
                .product(name: "Swinject", package: "Swinject"),
            ]
        ),
        .testTarget(name: "GenericTests", dependencies: ["Generic"]),
    ]
)
