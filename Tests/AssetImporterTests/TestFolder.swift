//
//  TestFolder.swift
//  ArgumentParser
//
//  Created by Jochen on 06.08.20.
//

import Files
import Foundation

enum Resource {
    case add16ptSVG
    case add16ptRoundedSVG

    var fileName: String {
        switch self {
            case .add16ptSVG:
                return "add_16pt.svg"
                case .add16ptRoundedSVG:
                    return "add_16pt_rounded.svg"
        }
    }

    var contents: Data? {
        let string: String
        switch self {
        case .add16ptSVG:
            string = "<svg xmlns='http://www.w3.org/2000/svg' width='32' height='32' viewBox='0 0 32 32'><title>c-add</title><g stroke-linecap='square' stroke-linejoin='miter' stroke-width='2' fill='#444444' stroke='#444444'><line fill='none' stroke-miterlimit='10' x1='16' y1='9' x2='16' y2='23'></line> <line fill='none' stroke-miterlimit='10' x1='23' y1='16' x2='9' y2='16'></line> <circle fill='none' stroke='#444444' stroke-miterlimit='10' cx='16' cy='16' r='15'></circle></g></svg>"
        case .add16ptRoundedSVG:
            string = "<svg xmlns='http://www.w3.org/2000/svg' width='32' height='32' viewBox='0 0 32 32'><title>c-add</title><g stroke-linecap='round' stroke-linejoin='round' stroke-width='2' fill='#444444' stroke='#444444'><line fill='none' stroke-miterlimit='10' x1='16' y1='9' x2='16' y2='23'></line> <line fill='none' stroke-miterlimit='10' x1='23' y1='16' x2='9' y2='16'></line> <circle fill='none' stroke='#444444' stroke-miterlimit='10' cx='16' cy='16' r='15'></circle></g></svg>"
        }

        return string.data(using: .utf8)
    }
}

struct TestFolder {
    let folder: Folder
    let resourceFolder: Folder
    let workFolder: Folder

    init() throws {
        let mainFolder = try Folder.temporary.createSubfolderIfNeeded(withName: "AssetImporter")
        folder = try mainFolder.createSubfolder(named: NSUUID().uuidString)
        resourceFolder = try folder.createSubfolder(named: "Resources")
        workFolder = try folder.createSubfolder(named: "Tests")
        try createFiles()
    }

    func file(forResource resource: Resource) throws -> File {
        return try resourceFolder.file(named: resource.fileName)
    }

    func filePath(forResource resource: Resource) throws -> String {
        return try file(forResource: resource).path
    }

    func filePathInWorkFolder(forFileNamed name: String) -> String {
        return workFolder.url.appendingPathComponent(name).path
    }

    func delete() throws {
        try folder.delete()
    }
}

private extension TestFolder {
    var resources: [Resource] {
        return [
            .add16ptSVG,
            .add16ptRoundedSVG,
        ]
    }

    func createFiles() throws {
        try resources.forEach { resource in
            try create(resource: resource)
        }
    }

    func create(resource: Resource) throws {
        try resourceFolder.createFile(named: resource.fileName, contents: resource.contents)
    }
}
