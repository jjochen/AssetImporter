import ArgumentParser
import AssetImporter
import Foundation

struct AssetImport: ParsableCommand {
    @Option(name: .shortAndLong, help: "Origin folder path.")
    var originPath: String

    @Option(name: .shortAndLong, help: "Destination folder path.")
    var destinationPath: String

    @Option(name: .shortAndLong, help: "Intermediate pdf folder path.")
    var pdfPath: String

    @Option(name: .shortAndLong, help: "New items folder path.")
    var newPath: String

    @Option(name: .shortAndLong, help: "Default icon scale.")
    var scale: Float = 0.5

    @Flag(help: "Force import.")
    var force = false

    mutating func run() throws {
        let importer = try AssetImporter(originSVGFolderPath: originPath,
                                         assetCatalogPath: destinationPath,
                                         intermediatePDFFolderPath: pdfPath,
                                         newAssetsFolderPath: newPath)
        try importer.importAssets(withDefaultScale: scale, importAll: force)
    }
}

AssetImport.main()
