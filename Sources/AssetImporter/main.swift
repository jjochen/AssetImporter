//
//  main.swift
//  AssetImporter
//
//  Created by Jochen on 05.06.20.
//  Copyright © 2020 Jochen Pfeiffer. All rights reserved.
//


import Foundation
import ArgumentParser
import Files


struct AssetImporter: ParsableCommand {

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

    
    private let fileExtensionPDF = "pdf"
    private let fileExtensionSVG = "svg"
    private let launchPathImageMagick = "/usr/local/bin/magick"
    private let launchPathRSVG = "/usr/local/bin/rsvg-convert"

    mutating func run() throws {

        let originFolder = try Folder(path: originPath)
        let destinationFolder = try Folder(path: destinationPath)
        let pdfFolder = try Folder(path: pdfPath, createIfNeeded: true)
        let newItemFolder = try Folder(path: newPath, createIfNeeded: true)

        let svgFiles = try filePathMapping(forFolder: originFolder, fileExtension: fileExtensionSVG)
        guard !svgFiles.isEmpty  else {
            print("No files of type '\(fileExtensionSVG)' found at '\(originFolder.path)'")
            return
        }

        let existingAssets = try filePathMapping(forFolder: destinationFolder, fileExtension: fileExtensionPDF)
        guard !existingAssets.isEmpty  else {
            print("No files of type '\(fileExtensionPDF)' found at '\(destinationFolder.path)'")
            return
        }

        var numberOfNewItems = 0
        var numberOfImportedItems = 0
        var numberOfSkippedItems = 0

        try svgFiles.forEach { (fileName: String, svgFile: File) in
            print(" \(fileName): ", terminator : "")
            let pdfFilePath = pdfFolder.filePath(forFileWithName: fileName, fileExtension: fileExtensionPDF)
            let size = iconSize(forFile: fileName)
            scaleSVG(at: svgFile.path, destination: pdfFilePath, size: size, scale: scale)
            let pdfFile = try File(path: pdfFilePath)
            if let assetFile = existingAssets[fileName] {
                if force || !image(at: pdfFilePath, isEqualToImageAt: assetFile.path) {
                    let log = force ? "imported (forced)" : " imported"
                    print(log)
                    guard let assetSubfolder = assetFile.parent else {
                        return
                    }
                    try assetFile.delete()
                    try pdfFile.copy(to: assetSubfolder)
                    numberOfImportedItems += 1
                } else {
                    print(" skipped")
                    numberOfSkippedItems += 1
                }
            } else {
                print("new")
                try pdfFile.copy(to: newItemFolder)
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

private extension Folder {
    init(path: String, createIfNeeded: Bool) throws {
        if createIfNeeded {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
        }
        try self.init(path: path)
    }

    func filePath(forFileWithName fileName: String, fileExtension: String) -> String {
        return self.url.appendingPathComponent(fileName).appendingPathExtension(fileExtension).path
    }
}

private extension AssetImporter {

    func filePathMapping(forFolder folder: Folder, fileExtension: String) throws -> [String: File] {
        var mapping: [String: File] = [:]
        folder.files.recursive.enumerated().forEach { (index, file) in
            guard file.extension == fileExtension else {
                return
            }
            let fileName = file.nameExcludingExtension
            guard mapping[fileName] == nil else {
                print("WARNING: multiple files called '\(fileName)' found at '\(folder.path)!")
                return
            }
            mapping[fileName] = file
        }
        return mapping
    }

    func iconSize(forFile fileName: String) -> CGSize? {
        guard let range = fileName.range(of: #"_(\d+)pt$"#,
                                         options: .regularExpression), !range.isEmpty else
        {
            return nil
        }

        let startIndex = fileName.index(range.lowerBound, offsetBy: 1)
        let endIndex = fileName.index(range.upperBound, offsetBy: -2)
        let sizeString = fileName[startIndex..<endIndex]
        guard let size = Int(sizeString), size > 0 else {
            return nil
        }
        return CGSize(width: size, height: size)
    }

    func image(at origin: String, isEqualToImageAt destination: String) -> Bool {
        let task = Process()
        task.launchPath = launchPathImageMagick
        task.arguments = ["compare", "-metric", "AE", "\(origin)", "\(destination)", "/tmp/difference.pdf"]
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus == 0
    }

    func scaleSVG(at origin: String, destination: String, size: CGSize? = nil, scale: Float) {
        let task = Process()
        task.launchPath = launchPathRSVG
        var arguments: [String] = []
        arguments.append("\(origin)")
        arguments.append("--output=\(destination)")
        arguments.append("--keep-aspect-ratio")
        arguments.append("--format=pdf")
        if let size = size {
            arguments.append("--width=\(Int(size.width))")
            arguments.append("--height=\(Int(size.height))")
        }
        else
        {
            arguments.append("--zoom=\(scale)")
        }
        task.arguments = arguments
        task.launch()
        task.waitUntilExit()
    }
}


AssetImporter.main()


