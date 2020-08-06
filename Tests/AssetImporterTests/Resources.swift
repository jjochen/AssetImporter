//
//  Resources.swift
//  ArgumentParser
//
//  Created by Jochen on 06.08.20.
//

import Files
import Foundation

struct ResourcesFolder {
    let folder: Folder

    init() throws {
        folder = try Folder.temporary.createSubfolderIfNeeded(at: "AssetImporter/\(NSUUID().uuidString)")
        try createFiles()
    }

    func delete() throws {
        try delete()
    }
}

extension ResourcesFolder {
    enum Resource {
        case add16ptRoundedSVG

        var fileName: String {
            switch self {
            case .add16ptRoundedSVG:
                return "add_16pt_rounded.svg"
            }
        }

        var contents: Data? {
            let string: String
            switch self {
            case .add16ptRoundedSVG:
                string = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32' width='32' height='32'><title>add_16pt</title><g class='nc-icon-wrapper' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' fill='#444444' stroke='#444444'><line data-color='color-2' fill='none' stroke-miterlimit='10' x1='16' y1='9' x2='16' y2='23'/> <line data-color='color-2' fill='none' stroke-miterlimit='10' x1='23' y1='16' x2='9' y2='16'/> <circle fill='none' stroke='#444444' stroke-miterlimit='10' cx='16' cy='16' r='15'/></g></svg>"
            }

            return string.data(using: .utf8)
        }
    }

    var resources: [Resource] {
        return [
            .add16ptRoundedSVG,
        ]
    }

    func createFiles() throws {
        try resources.forEach { resource in
            try create(resource: resource)
        }
    }

    func create(resource: Resource) throws {
        try folder.createFile(named: resource.fileName, contents: resource.contents)
    }
}
