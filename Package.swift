// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "AssetImporter",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(
            name: "asset-import",
            targets: ["AssetImport"]
        ),
        .library(
            name: "AssetImporter",
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
            name: "AssetImport",
            dependencies: [
                "AssetImporter",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "AssetImporter",
            dependencies: [
                "Files",
            ]
        ),
        .testTarget(
            name: "AssetImporterTests",
            dependencies: [
                "AssetImporter",
            ]
        ),
    ]
)
