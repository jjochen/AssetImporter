// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "AssetImporter",
    products: [
        .executable(
            name: "asset-import",
            targets: ["AssetImporter"]
        ),
    ],
    dependencies: [
        .package(
            name: "swift-argument-parser",
            url: "https://github.com/apple/swift-argument-parser",
            from: "0.2.0"
        ),
        .package(
            name: "Files",
            url: "https://github.com/johnsundell/files",
            from: "4.0.0"
        ),
    ],
    targets: [
        .target(
            name: "AssetImporter",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Files",
            ]
        ),
        .testTarget(
            name: "AssetImporterTests",
            dependencies: ["AssetImporter"]
        ),
    ]
)
