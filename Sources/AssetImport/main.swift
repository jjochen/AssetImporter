import ArgumentParser
import AssetImporter
import Foundation
import Progress

struct AssetImport: ParsableCommand {
    @Option(name: .shortAndLong, help: "Origin folder path.")
    var originPath: String

    @Option(name: .shortAndLong, help: "Destination assets catalog path.")
    var destinationPath: String

    @Option(name: .shortAndLong, help: "Intermediate pdf folder path.")
    var pdfPath: String

    @Option(name: .shortAndLong, help: "New items subfolder name.")
    var newAssetsSubfolder: String

    @Option(name: .shortAndLong, help: "Default icon scale.")
    var scale: Float = 0.5

    @Flag(help: "Force import.")
    var force = false

    @Flag(help: "Verbose output.")
    var verbose = false

    mutating func run() throws {
        var importer = try AssetImporter(originSVGFolderPath: originPath,
                                         assetsCatalogPath: destinationPath,
                                         intermediatePDFFolderPath: pdfPath,
                                         newAssetsSubfolderName: newAssetsSubfolder)

        var progressBar: ProgressBar?
        importer.progress = { total, _ in
            if progressBar == nil {
                progressBar = ProgressBar(count: total)
            }
            progressBar?.next()
        }

        try importer.importAssets(withDefaultScale: scale, importAll: force, verbose: verbose)
    }
}

AssetImport.main()
