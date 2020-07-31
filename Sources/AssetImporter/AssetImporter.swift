//
//  AssetImporter.swift
//  assets-import
//
//  Created by Jochen on 08.06.20.
//  Copyright © 2020 Jochen Pfeiffer. All rights reserved.
//

import Foundation

class AssetImporter {

    init(origin: URL, intermediate: URL, destination: URL, new: URL) {
        originDirectory = origin
        intermediateDirectory = intermediate
        destinationDirectory = destination
        newItemsDirectory = new
    }


    private let fileExtensionPDF = "pdf"
    private let fileExtensionSVG = "svg"
    private let launchPathImageMagick = "/usr/local/bin/magick"
    private let launchPathRSVG = "/usr/local/bin/rsvg-convert"

    private var originDirectory: URL
    private var intermediateDirectory: URL
    private var destinationDirectory: URL
    private var newItemsDirectory: URL
    private var svgFiles: [String: URL] = [:]
    private var existingAssets: [String: URL] = [:]

    public func importFiles(all: Bool = false) -> Bool {

        svgFiles = filePathMapping(forDirectoryAt: originDirectory, fileExtension: fileExtensionSVG)
        guard !svgFiles.isEmpty  else {
            print("no files of type '\(fileExtensionSVG)' found at '\(originDirectory.path)'")
            return false
        }

        existingAssets = filePathMapping(forDirectoryAt: destinationDirectory, fileExtension: fileExtensionPDF)
        guard !existingAssets.isEmpty  else {
            print("no files of type '\(fileExtensionPDF)' found at '\(destinationDirectory.path)'")
            return false
        }

        var numberOfNewItems = 0
        var numberOfImportedItems = 0
        var numberOfSkippedItems = 0

        do {
            let fileManager = FileManager.default
            try fileManager.createDirectory(at: intermediateDirectory, withIntermediateDirectories: true)
            try svgFiles.forEach { (fileName: String, svgURL: URL) in
                print(" \(fileName): ", terminator : "")
                let pdfURL = intermediateURL(forFile: fileName)
                let size = iconSize(forFile: fileName)
                scaleSVG(at: svgURL, destination: pdfURL, size: size)
                if let assetURL = existingAssets[fileName] {
                    if all || !image(at: pdfURL, isEqualToImageAt: assetURL) {
                        let log = all ? "imported (forced)" : " imported"
                        print(log)
                        try fileManager.removeItem(at: assetURL)
                        try fileManager.copyItem(at: pdfURL, to: assetURL)
                        numberOfImportedItems += 1
                    } else {
                        print(" skipped")
                        numberOfSkippedItems += 1
                    }
                } else {
                    print("new")
                    try fileManager.createDirectory(at: newItemsDirectory, withIntermediateDirectories: true)
                    let newFileURL = newItemURL(forFile: fileName)
                    try fileManager.copyItem(at: pdfURL, to: newFileURL)
                    numberOfNewItems += 1
                }
            }
        } catch {
            print("Error copying file: ", error)
            return false
        }

        print("\n")
        print("Imported: \(numberOfImportedItems)")
        print("Skipped: \(numberOfSkippedItems)")
        print("New: \(numberOfNewItems)")
        print("\n")

        return true
    }

}

private extension AssetImporter {

    func filePathMapping(forDirectoryAt directoryURL: URL, fileExtension: String) -> [String: URL] {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(at: directoryURL,
                                                      includingPropertiesForKeys: nil,
                                                      options: [.skipsHiddenFiles],
                                                      errorHandler: { (url, error) -> Bool in
                                                          print("directoryEnumerator error at \(url): ", error)
                                                          return true
        }) else {
            return [:]
        }

        var mapping: [String: URL] = [:]
        for case let fileURL as URL in enumerator {
            guard fileURL.pathExtension == fileExtension else {
                continue
            }
            let fileName = fileURL.deletingPathExtension().lastPathComponent
            guard mapping[fileName] == nil else {
                print("WARNING: multiple files called '\(fileName)' found at '\(directoryURL.path)!")
                continue
            }
            mapping[fileName] = fileURL
        }

        return mapping
    }

    func intermediateURL(forFile fileName: String) -> URL {
        return intermediateDirectory.appendingPathComponent(fileName).appendingPathExtension(fileExtensionPDF)
    }

    func newItemURL(forFile fileName: String) -> URL {
        return newItemsDirectory.appendingPathComponent(fileName).appendingPathExtension(fileExtensionPDF)
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

    func image(at origin: URL, isEqualToImageAt destination: URL) -> Bool {
        let task = Process()
        task.launchPath = launchPathImageMagick
        task.arguments = ["compare", "-metric", "AE", "\(origin.path)", "\(destination.path)", "/tmp/difference.pdf"]
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus == 0
    }

    func scaleSVG(at origin: URL, destination: URL, size: CGSize? = nil, scale: CGFloat = 0.5) {
        let task = Process()
        task.launchPath = launchPathRSVG
        var arguments: [String] = []
        arguments.append("\(origin.path)")
        arguments.append("--output=\(destination.path)")
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
