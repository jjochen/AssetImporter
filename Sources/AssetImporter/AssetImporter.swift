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

    internal struct ImportStateCounter: CustomStringConvertible {
        var imported = 0
        var skipped = 0
        var new = 0

        mutating func increment(forState state: ImportState) {
            switch state {
            case .imported:
                imported += 1
            case .skipped:
                skipped += 1
            case .new:
                new += 1
            }
        }

        func currentCount(forState state: ImportState) -> Int {
            switch state {
            case .imported:
                return imported
            case .skipped:
                return skipped
            case .new:
                return new
            }
        }

        var description: String {
            var components: [String] = []
            components.append(description(forState: .imported))
            components.append(description(forState: .skipped))
            components.append(description(forState: .new))
            return components.joined(separator: "\n")
        }

        func description(forState state: ImportState) -> String {
            return "\(state.rawValue.capitalized): \(currentCount(forState: state))"
        }
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

        var counter = ImportStateCounter()
        try svgFiles.forEach { (fileName: String, svgFile: File) in
            let existingAsset = existingAssets[fileName]
            let newAsset = try convert(svgFile: svgFile, destination: pdfFolder, scale: scale)
            let state = try importAsset(newAsset,
                                        existingAsset: existingAsset,
                                        newAssetsFolder: newItemFolder,
                                        force: force)

            print("\(fileName): \(state)")
            counter.increment(forState: state)
        }
        print("\n\(counter)\n")
    }
}

internal extension AssetImporter {
    static func importAsset(_ newAsset: File,
                            existingAsset: File?,
                            newAssetsFolder: Folder,
                            force: Bool) throws -> ImportState {
        guard let existingAsset = existingAsset else {
            try newAsset.copy(to: newAssetsFolder)
            return .new
        }

        guard force || !imageFile(existingAsset, isEqual: newAsset) else {
            return .skipped
        }

        try existingAsset.replace(withFile: newAsset)
        return .imported
    }

    static func convert(svgFile: File, destination: Folder, scale: Float) throws -> File {
        let fileName = svgFile.nameExcludingExtension
        let pdfFilePath = destination.filePath(forFileWithName: fileName, fileExtension: fileExtensionPDF)
        let size = iconSize(forFile: svgFile.nameExcludingExtension)
        try CommandLineTask.scaleSVG(at: svgFile.path,
                                     destination: pdfFilePath,
                                     size: size,
                                     scale: scale)
        let pdfFile = try File(path: pdfFilePath)
        return pdfFile
    }

    static func imageFile(_ file1: File, isEqual file2: File) -> Bool {
        return CommandLineTask.image(at: file1.path,
                                     isEqualToImageAt: file2.path)
    }

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
