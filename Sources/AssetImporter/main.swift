//
//  main.swift
//  assets-import
//
//  Created by Jochen on 05.06.20.
//  Copyright © 2020 Jochen Pfeiffer. All rights reserved.
//


import Foundation
import ArgumentParser


struct AssetImport: ParsableCommand {

    @Option(name: .shortAndLong, help: "Origin folder path.")
    var originPath: String

    @Option(name: .shortAndLong, help: "Destination folder path.")
    var destinationPath: String

    @Option(name: .shortAndLong, help: "Intermediate pdf folder path.")
    var pdfPath: String

    @Option(name: .shortAndLong, help: "New items folder path.")
    var newPath: String

    @Flag(help: "Force import.")
    var force = false


    mutating func run() throws {
        let originFolderURL = URL(fileURLWithPath: originPath, isDirectory: true)
        let destinationFolderURL = URL(fileURLWithPath: destinationPath, isDirectory: true)
        let pdfFolderURL = URL(fileURLWithPath: pdfPath, isDirectory: true)
        let newItemsFolderURL = URL(fileURLWithPath: newPath, isDirectory: true)

        let importer = AssetImporter(origin: originFolderURL,
                                     intermediate: pdfFolderURL,
                                     destination: destinationFolderURL,
                                     new: newItemsFolderURL)
        _ = importer.importFiles(all: force)
    }
}

AssetImport.main()


