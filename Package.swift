// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "AssetImporter",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .executable(
            name: "asset-import",
            targets: ["AssetImporter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.2.0"),
    ],
    targets: [
        .target(
            name: "AssetImporter",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "AssetImporterTests",
            dependencies: ["AssetImporter"]),
    ]
)
