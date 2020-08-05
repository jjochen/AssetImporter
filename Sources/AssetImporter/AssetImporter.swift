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
    public var originPath: String
    public var destinationPath: String
    public var pdfPath: String
    public var newPath: String
    public var scale: Float
    public var force: Bool

    private let fileExtensionPDF = "pdf"
    private let fileExtensionSVG = "svg"

    public init(originPath: String, destinationPath: String, pdfPath: String, newPath: String, scale: Float, force: Bool) {
        self.originPath = originPath
        self.destinationPath = destinationPath
        self.pdfPath = pdfPath
        self.newPath = newPath
        self.scale = scale
        self.force = force
    }

    public func importAssets() throws {
        let originFolder = try Folder(path: originPath)
        let destinationFolder = try Folder(path: destinationPath)
        let pdfFolder = try Folder(path: pdfPath, createIfNeeded: true)
        let newItemFolder = try Folder(path: newPath, createIfNeeded: true)

        let svgFiles = try filePathMapping(forFolder: originFolder, fileExtension: fileExtensionSVG)
        guard !svgFiles.isEmpty else {
            throw AssetImporterError.noFilesFound(extension: fileExtensionSVG, path: originFolder.path)
        }

        let existingAssets = try filePathMapping(forFolder: destinationFolder, fileExtension: fileExtensionPDF)
        guard !existingAssets.isEmpty else {
            throw AssetImporterError.noFilesFound(extension: fileExtensionPDF, path: destinationFolder.path)
        }

        var numberOfNewItems = 0
        var numberOfImportedItems = 0
        var numberOfSkippedItems = 0

        try svgFiles.forEach { (fileName: String, svgFile: File) in
            print("\(fileName): ", terminator: "")
            let pdfFilePath = pdfFolder.filePath(forFileWithName: fileName, fileExtension: fileExtensionPDF)
            let size = iconSize(forFile: fileName)
            let scaleSuccess = Tasks.scaleSVG(at: svgFile.path, destination: pdfFilePath, size: size, scale: scale)
            if !scaleSuccess {
                print("error")
                return
            }
            let pdfFile = try File(path: pdfFilePath)
            if let assetFile = existingAssets[fileName] {
                if force || !Tasks.image(at: pdfFilePath, isEqualToImageAt: assetFile.path) {
                    let log = force ? "imported (forced)" : "imported"
                    print(log)
                    guard let assetSubfolder = assetFile.parent else {
                        throw AssetImporterError.unknown
                    }
                    try assetFile.delete()
                    try pdfFile.copy(to: assetSubfolder)
                    numberOfImportedItems += 1
                } else {
                    print("no changes")
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

// MARK: - Extensions

private extension AssetImporter {
    func filePathMapping(forFolder folder: Folder, fileExtension: String) throws -> [String: File] {
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

    func iconSize(forFile fileName: String) -> CGSize? {
        guard let range = fileName.range(of: #"_(\d+)pt$"#,
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

private extension Folder {
    init(path: String, createIfNeeded: Bool) throws {
        if createIfNeeded {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
        }
        try self.init(path: path)
    }

    func filePath(forFileWithName fileName: String, fileExtension: String) -> String {
        return url.appendingPathComponent(fileName).appendingPathExtension(fileExtension).path
    }
}

// MARK: - Tasks

struct Tasks {
    private static let launchPathImageMagick = "/usr/local/bin/magick"
    private static let launchPathRSVG = "/usr/local/bin/rsvg-convert"

    static func image(at origin: String, isEqualToImageAt destination: String) -> Bool {
        let arguments = ["compare", "-metric", "AE", "\(origin)", "\(destination)", "/tmp/difference.pdf"]
        let result = runProcess(withExecutablePath: launchPathImageMagick, arguments: arguments)
        return result.success && Int(result.error) == 0
    }

    static func scaleSVG(at origin: String, destination: String, size: CGSize? = nil, scale: Float) -> Bool {
        var arguments: [String] = []
        arguments.append("\(origin)")
        arguments.append("--output=\(destination)")
        arguments.append("--keep-aspect-ratio")
        arguments.append("--format=pdf")
        if let size = size {
            arguments.append("--width=\(Int(size.width))")
            arguments.append("--height=\(Int(size.height))")
        } else {
            arguments.append("--zoom=\(scale)")
        }
        let result = runProcess(withExecutablePath: launchPathRSVG, arguments: arguments)
        return result.success
    }

    private static func runProcess(withExecutablePath path: String,
                                   arguments: [String]?) -> (success: Bool, output: String, error: String) {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.launch()
        process.waitUntilExit()
        let success = process.terminationStatus == 0
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let error = String(decoding: errorData, as: UTF8.self)
        return (success, output, error)
    }
}

// MARK: - Errors

enum AssetImporterError: Error {
    case noFilesFound(extension: String, path: String)
    case multipleFilesWithName(name: String, path: String)
    case unknown
}

extension AssetImporterError: CustomStringConvertible {
    public var description: String {
        var message: String
        switch self {
        case let .noFilesFound(extension: fileExtension, path: path):
            message = "No files of type '\(fileExtension)' found at '\(path)'."
        case let .multipleFilesWithName(name: fileName, path: path):
            message = "Multiple files called '\(fileName)' found at '\(path)'."
        case .unknown:
            message = "Unknown."
        }
        return message
    }
}