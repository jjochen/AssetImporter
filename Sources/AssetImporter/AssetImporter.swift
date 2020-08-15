//
//  main.swift
//  AssetImport
//
//  Created by Jochen on 05.06.20.
//  Copyright © 2020 Jochen Pfeiffer. All rights reserved.
//

import Files
import Foundation

public struct AssetImporter {
    private static let fileExtensionPDF = "pdf"
    private static let fileExtensionSVG = "svg"

    internal enum ImportState: String {
        case imported
        case skipped
        case new
    }

    public static func importAssets(originPath: String,
                                    destinationPath: String,
                                    pdfPath: String,
                                    newPath: String,
                                    scale: Float,
                                    force: Bool) throws {
        let originFolder = try Folder(path: originPath)
        let destinationFolder = try Folder(path: destinationPath)
        let pdfFolder = try Folder(path: pdfPath, createIfNeeded: true)
        let newItemFolder = try Folder(path: newPath, createIfNeeded: true)

        let svgFiles = try filePathMapping(forFolder: originFolder,
                                           fileExtension: fileExtensionSVG)
        guard !svgFiles.isEmpty else {
            throw AssetImporterError.noFilesFound(extension: fileExtensionSVG, path: originFolder.path)
        }

        let existingAssets = try filePathMapping(forFolder: destinationFolder,
                                                 fileExtension: fileExtensionPDF)
        guard !existingAssets.isEmpty else {
            throw AssetImporterError.noFilesFound(extension: fileExtensionPDF, path: destinationFolder.path)
        }

        var numberOfNewItems = 0
        var numberOfImportedItems = 0
        var numberOfSkippedItems = 0

        // TODO: needs refactoring
        try svgFiles.forEach { (fileName: String, svgFile: File) in
            var state: ImportState
            let pdfFilePath = pdfFolder.filePath(forFileWithName: fileName, fileExtension: fileExtensionPDF)
            let size = iconSize(forFile: fileName)
            try CommandLineTask.scaleSVG(at: svgFile.path,
                                         destination: pdfFilePath,
                                         size: size,
                                         scale: scale)
            let pdfFile = try File(path: pdfFilePath)
            if let assetFile = existingAssets[fileName] {
                if force || !CommandLineTask.image(at: pdfFilePath,
                                                   isEqualToImageAt: assetFile.path) {
                    guard let assetParent = assetFile.parent else {
                        throw AssetImporterError.unknown(message: "file has no no parent")
                    }
                    try assetFile.delete()
                    try pdfFile.copy(to: assetParent)
                    state = .imported
                } else {
                    state = .skipped
                }
            } else {
                try pdfFile.copy(to: newItemFolder)
                state = .new
            }

            print("\(fileName): \(state)")
            switch state {
            case .imported:
                numberOfImportedItems += 1
            case .skipped:
                numberOfSkippedItems += 1
            case .new:
                numberOfNewItems += 1
            }
        }

        print("\n")
        print("Imported: \(numberOfImportedItems)")
        print("Skipped: \(numberOfSkippedItems)")
        print("New: \(numberOfNewItems)")
        print("\n")
    }
}

internal extension AssetImporter {
    static func filePathMapping(forFolder folder: Folder, fileExtension: String) throws -> [String: File] {
        var mapping: [String: File] = [:]
        try folder.files.recursive.enumerated().forEach { _, file in
            guard file.extension == fileExtension else {
                return
            }
            let fileName = file.nameExcludingExtension
            guard mapping[fileName] == nil else {
                throw AssetImporterError.multipleFilesWithName(name: fileName, path: folder.path)
            }
            mapping[fileName] = file
        }
        return mapping
    }

    static func iconSize(forFile fileName: String) -> CGSize? {
        guard let range = fileName.range(of: #"_(\d+)pt"#,
                                         options: .regularExpression), !range.isEmpty
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
