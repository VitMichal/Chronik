// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Generic",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Generic", targets: ["Generic"]),
    ],
    targets: [
        .target(name: "Generic"),
        .testTarget(name: "GenericTests", dependencies: ["Generic"]),
    ]
)
