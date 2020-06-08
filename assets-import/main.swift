//
//  main.swift
//  assets-import
//
//  Created by Jochen on 05.06.20.
//  Copyright © 2020 Jochen Pfeiffer. All rights reserved.
//


import Foundation

let fileExtensionPDF = "pdf"
let fileExtensionSVG = "svg"
let launchPathImageMagick = "/usr/local/bin/magick"
let launchPathRSVG = "/usr/local/bin/rsvg-convert"

let fileManager = FileManager.default
let options = UserDefaults.standard

guard let originPath = options.string(forKey: "o") else {
    print("origin folder path with '-o'")
    exit(1)
}

guard let destinationPath = options.string(forKey: "d") else {
    print("destination folder path with '-d'")
    exit(1)
}

guard let newPath = options.string(forKey: "n") else {
    print("new items folder path with '-n'")
    exit(1)
}
let newItemsFolderURL = URL(fileURLWithPath: newPath, isDirectory: true)

guard let pdfPath = options.string(forKey: "p") else {
    print("pdf folder path with '-p'")
    exit(1)
}
let pdfFolderURL = URL(fileURLWithPath: pdfPath, isDirectory: true)

let forceString = options.string(forKey: "f") ?? "false"
let force = forceString == "true"


guard let originMapping = filePathMapping(forDirectoryAt: originPath, fileExtension: fileExtensionSVG) else {
    print("no files of type '\(fileExtensionPDF)' found at '\(originPath)'")
    exit(1)
}

guard let destinationMapping = filePathMapping(forDirectoryAt: destinationPath, fileExtension: fileExtensionPDF) else {
    print("no files of type '\(fileExtensionPDF)' found at '\(originPath)'")
    exit(1)
}

importFiles(from: originMapping, to: destinationMapping, pdfFolderURL: pdfFolderURL, newItemsFolderURL: newItemsFolderURL, force: force)



func filePathMapping(forDirectoryAt path: String, fileExtension: String) -> [String: URL]? {
    let fileManager = FileManager.default
    let assetsURL = URL(fileURLWithPath: path, isDirectory: true)
    guard let enumerator = fileManager.enumerator(at: assetsURL,
                                                  includingPropertiesForKeys: nil,
                                                  options: [.skipsHiddenFiles],
                                                  errorHandler: { (url, error) -> Bool in
                                                      print("directoryEnumerator error at \(url): ", error)
                                                      return true
    }) else {
        return nil
    }

    var mapping: [String: URL] = [:]
    for case let fileURL as URL in enumerator {
        guard fileURL.pathExtension == fileExtension else {
            continue
        }
        let fileName = fileURL.deletingPathExtension().lastPathComponent
        guard mapping[fileName] == nil else {
            print("multiple files called '\(fileName)' found at '\(path)!")
            continue
        }
        mapping[fileName] = fileURL
    }
    if mapping.isEmpty {
        return nil
    }

    return mapping
}

func importFiles(from originMapping: [String: URL], to destinationMapping: [String: URL], pdfFolderURL: URL, newItemsFolderURL: URL, force: Bool) {
    var numberOfNewItems = 0
    var numberOfImportedItems = 0
    var numberOfSkippedItems = 0

    do {
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: pdfFolderURL, withIntermediateDirectories: true)
        try originMapping.forEach { (fileName: String, svgURL: URL) in
            print(" \(fileName): ", terminator : "")
            let pdfURL = pdfFolderURL.appendingPathComponent(fileName).appendingPathExtension(fileExtensionPDF)
            scaleSVG(at: svgURL, destination: pdfURL)
            if let assetURL = destinationMapping[fileName] {
                if force || !image(at: pdfURL, isEqualToImageAt: assetURL) {
                    let log = force ? "imported (forced)" : " imported"
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
                try fileManager.createDirectory(at: newItemsFolderURL, withIntermediateDirectories: true)
                let newFileURL = newItemsFolderURL.appendingPathComponent(fileName).appendingPathExtension(fileExtensionPDF)
                try fileManager.copyItem(at: pdfURL, to: newFileURL)
                numberOfNewItems += 1
            }
        }
    } catch {
        print("Error copying file: ", error)
    }
    print("\n")
    print("Imported: \(numberOfImportedItems)")
    print("Skipped: \(numberOfSkippedItems)")
    print("New: \(numberOfNewItems)")
    print("\n")
}

func image(at origin: URL, isEqualToImageAt destination: URL) -> Bool {
    let task = Process()
    task.launchPath = launchPathImageMagick
    task.arguments = ["compare", "-metric", "AE", "\(origin.path)", "\(destination.path)", "/tmp/difference.pdf"]
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus == 0
}

func scaleSVG(at origin: URL, destination: URL, scale: CGFloat = 0.5) {
    let task = Process()
    task.launchPath = launchPathRSVG
    task.arguments = ["\(origin.path)", "--keep-aspect-ratio", "--zoom=\(scale)", "--format=pdf", "--output=\(destination.path)"]
    task.launch()
    task.waitUntilExit()
}
