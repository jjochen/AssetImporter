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

        let svgFiles = try filePathMapping(forFolder: originFolder, fileExtension: fileExtensionSVG)
        let existingAssets = try filePathMapping(forFolder: destinationFolder, fileExtension: fileExtensionPDF)

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

        guard force || !asset(existingAsset, isEqual: newAsset) else {
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

    static func asset(_ asset1: File, isEqual asset2: File) -> Bool {
        return CommandLineTask.image(at: asset1.path,
                                     isEqualToImageAt: asset2.path)
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

        guard !mapping.isEmpty else {
            throw AssetImporterError.noFilesFound(extension: fileExtension, path: folder.path)
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
