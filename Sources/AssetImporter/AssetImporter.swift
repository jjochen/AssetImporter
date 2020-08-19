import Files
import Foundation

public struct AssetImporter {
    private let fileExtensionPDF = "pdf"
    private let fileExtensionSVG = "svg"

    private let originSVGFolder: Folder
    private let assetsCatalogFolder: Folder
    private let intermediatePDFFolder: Folder
    private let newAssetsSubfolderName: String

    public var progress: ((_ total: Int, _ count: Int) -> Void)?

    public init(originSVGFolderPath: String,
                assetsCatalogPath: String,
                intermediatePDFFolderPath: String,
                newAssetsSubfolderName: String) throws {
        originSVGFolder = try Folder(path: originSVGFolderPath)
        assetsCatalogFolder = try Folder(path: assetsCatalogPath)
        intermediatePDFFolder = try Folder(path: intermediatePDFFolderPath, createIfNeeded: true)
        self.newAssetsSubfolderName = newAssetsSubfolderName
    }

    @discardableResult
    public func importAssets(withDefaultScale scale: Float,
                             importAll: Bool = false,
                             verbose: Bool = false) throws -> ImportStateCounter {
        try CommandLineTask.checkExternalDependencies()

        let svgFiles = try originSVGFolder.fileMapping(forFilesWithExtension: fileExtensionSVG)
        let existingAssets = try assetsCatalogFolder.fileMapping(forFilesWithExtension: fileExtensionPDF)
        guard !svgFiles.isEmpty else {
            throw AssetImporterError.noFilesFound(extension: fileExtensionSVG, path: originSVGFolder.path)
        }

        let total = svgFiles.count

        var counter = ImportStateCounter()
        try svgFiles.forEach { (fileName: String, svgFile: File) in
            let existingAsset = existingAssets[fileName]
            let state = try importSVGFile(svgFile,
                                          existingAsset: existingAsset,
                                          defaultScale: scale,
                                          importAll: importAll)
            counter.increment(forState: state)
            self.progress?(total, counter.total)

            if verbose {
                print("\(fileName): \(state)")
            }
        }
        print("\n\(counter)\n")
        return counter
    }
}

internal extension AssetImporter {
    func importSVGFile(_ svgFile: File, existingAsset: File?, defaultScale: Float, importAll: Bool) throws -> ImportState {
        let newAsset = try convert(svgFile: svgFile, defaultScale: defaultScale)

        guard let existingAsset = existingAsset else {
            try createNewAssetsCatalogEntry(withAsset: newAsset)
            return .new
        }

        guard importAll || !asset(existingAsset, isEqual: newAsset) else {
            return .skipped
        }

        try existingAsset.replace(withFile: newAsset)
        return .replaced
    }

    func createNewAssetsCatalogEntry(withAsset asset: File) throws {
        let importFolder = try assetsCatalogFolder.createSubfolderIfNeeded(at: newAssetsSubfolderName)
        let imageSetFolder = try importFolder.createSubfolder(at: "\(asset.nameExcludingExtension).imageset")
        try asset.copy(to: imageSetFolder)
        let contents: [String: Any] = [
            "images": [
                [
                    "filename": asset.name,
                    "idiom": "universal",
                ],
            ],
            "info": [
                "author": "xcode",
                "version": 1,
            ],
            "properties": [
                "preserves-vector-representation": true,
                "template-rendering-intent": "template",
            ],
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: contents, options: .prettyPrinted)
        try imageSetFolder.createFile(at: "Contents.json", contents: jsonData)
    }

    func convert(svgFile: File, defaultScale: Float) throws -> File {
        let fileName = svgFile.nameExcludingExtension
        let pdfFilePath = intermediatePDFFolder.filePath(forFileWithName: fileName, fileExtension: fileExtensionPDF)
        let size = iconSize(forFile: fileName)
        try CommandLineTask.scaleSVG(at: svgFile.path,
                                     destination: pdfFilePath,
                                     size: size,
                                     scale: defaultScale)
        let pdfFile = try File(path: pdfFilePath)
        return pdfFile
    }

    func asset(_ asset1: File, isEqual asset2: File) -> Bool {
        return CommandLineTask.image(at: asset1.path, isEqualToImageAt: asset2.path)
    }

    func iconSize(forFile fileName: String) -> CGSize? {
        guard
            let range = fileName.range(of: #"_(\d+)pt"#, options: .regularExpression),
            !range.isEmpty
        else {
            return nil
        }

        let startIndex = fileName.index(range.lowerBound, offsetBy: 1)
        let endIndex = fileName.index(range.upperBound, offsetBy: -2)
        let sizeString = fileName[startIndex ..< endIndex]
        guard let size = Int(sizeString), size > 0 else {
            return nil
        }
        return CGSize(width: size, height: size)
    }
}
