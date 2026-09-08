// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SupabaseCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SupabaseCore", targets: ["SupabaseCore"]),
    ],
    dependencies: [
        .package(path: "../Generic"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.9.1"),
        // Only the `Supabase` product: it deliberately does not re-export
        // PostgrestMacros, so swift-syntax stays out of the build.
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.55.0"),
    ],
    targets: [
        .target(
            name: "SupabaseCore",
            dependencies: [
                .product(name: "Generic", package: "Generic"),
                .product(name: "Swinject", package: "Swinject"),
                .product(name: "Supabase", package: "supabase-swift"),
            ]
        ),
    ]
)
