//
//  main.swift
//  assets-import
//
//  Created by Jochen on 05.06.20.
//  Copyright © 2020 Jochen Pfeiffer. All rights reserved.
//


import Foundation

let options = UserDefaults.standard

guard let originPath = options.string(forKey: "o") else {
    print("origin folder path with '-o'")
    exit(1)
}
let originFolderURL = URL(fileURLWithPath: originPath, isDirectory: true)

guard let destinationPath = options.string(forKey: "d") else {
    print("destination folder path with '-d'")
    exit(1)
}
let destinationFolderURL = URL(fileURLWithPath: destinationPath, isDirectory: true)

guard let pdfPath = options.string(forKey: "p") else {
    print("pdf folder path with '-p'")
    exit(1)
}
let pdfFolderURL = URL(fileURLWithPath: pdfPath, isDirectory: true)

guard let newPath = options.string(forKey: "n") else {
    print("new items folder path with '-n'")
    exit(1)
}
let newItemsFolderURL = URL(fileURLWithPath: newPath, isDirectory: true)

let forceString = options.string(forKey: "f") ?? "false"
let force = forceString == "true"


let importer = AssetImporter(origin: originFolderURL,
                             intermediate: pdfFolderURL,
                             destination: destinationFolderURL,
                             new: newItemsFolderURL)

if !importer.importFiles(all: force) {
    exit(1)
}
