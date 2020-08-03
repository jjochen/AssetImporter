//
//  main.swift
//  AssetImporter
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

    @Option(name: .shortAndLong, help: "Default icon scale.")
    var scale: Float = 0.5

    @Flag(help: "Force import.")
    var force = false


    mutating func run() throws {
        let importer = AssetImporter()
        try importer.importFiles(origin: originPath,
                                 intermediate: pdfPath,
                                 destination: destinationPath,
                                 new: newPath,
                                 scale: scale,
                                 force: force)
    }
}

AssetImport.main()


