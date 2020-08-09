//
//  TestFolder.swift
//  ArgumentParser
//
//  Created by Jochen on 06.08.20.
//

import Files
import Foundation

struct Resource {
    let fileName: String
    let size: CGSize
    let contents: Data?

    init(fileName: String, size: CGSize, contents: Data?) {
        self.fileName = fileName
        self.size = size
        self.contents = contents
    }

    init(fileName: String, size: CGSize, svgString: String) {
        let data = svgString.data(using: .utf8)
        self.init(fileName: fileName, size: size, contents: data)
    }

    init(fileName: String, size: CGSize, base64String: String) {
        let data = Data(base64Encoded: base64String)
        self.init(fileName: fileName, size: size, contents: data)
    }

    static var add16ptSVG: Resource {
        let fileName = "add_16pt.svg"
        let size = CGSize(width: 16, height: 16)
        let svgString = "<svg xmlns='http://www.w3.org/2000/svg' width='32' height='32' viewBox='0 0 32 32'><title>c-add</title><g stroke-linecap='square' stroke-linejoin='miter' stroke-width='2' fill='#444444' stroke='#444444'><line fill='none' stroke-miterlimit='10' x1='16' y1='9' x2='16' y2='23'></line> <line fill='none' stroke-miterlimit='10' x1='23' y1='16' x2='9' y2='16'></line> <circle fill='none' stroke='#444444' stroke-miterlimit='10' cx='16' cy='16' r='15'></circle></g></svg>"
        return Resource(fileName: fileName, size: size, svgString: svgString)
    }

    static var add16ptRoundedSVG: Resource {
        let fileName = "add_16pt_rounded.svg"
        let size = CGSize(width: 16, height: 16)
        let svgString = "<svg xmlns='http://www.w3.org/2000/svg' width='32' height='32' viewBox='0 0 32 32'><title>c-add</title><g stroke-linecap='square' stroke-linejoin='miter' stroke-width='2' fill='#444444' stroke='#444444'><line fill='none' stroke-miterlimit='10' x1='16' y1='9' x2='16' y2='23'></line> <line fill='none' stroke-miterlimit='10' x1='23' y1='16' x2='9' y2='16'></line> <circle fill='none' stroke='#444444' stroke-miterlimit='10' cx='16' cy='16' r='15'></circle></g></svg>"
        return Resource(fileName: fileName, size: size, svgString: svgString)
    }

    static var add16ptRoundedPDF: Resource {
        let fileName = "add_16pt_rounded.pdf"
        let size = CGSize(width: 16, height: 16)
        let base64String = "JVBERi0xLjUKJbXtrvsKNCAwIG9iago8PCAvTGVuZ3RoIDUgMCBSCiAgIC9GaWx0ZXIgL0ZsYXRlRGVjb2RlCj4+CnN0cmVhbQp4nHWOQQrCQAxF9znFv4BjUmfqeAKh4KK6FBcygiJ2Ubrw+o2J2EJxQpI//JcQAWusRIvUKB31xKGq9W2xFMc91lfGfSDBW7PRfNL5ogTjRsI4oIfYTq+6MSOGhA4ZIipeOKGlBWVeVixa/0elL2VCqiBRfs09awWbkNPOPzyhbEghE454dYNtdMba/GyVzuIxXfG5saURXPU+zgplbmRzdHJlYW0KZW5kb2JqCjUgMCBvYmoKICAgMTU1CmVuZG9iagozIDAgb2JqCjw8CiAgIC9FeHRHU3RhdGUgPDwKICAgICAgL2EwIDw8IC9DQSAxIC9jYSAxID4+CiAgID4+Cj4+CmVuZG9iagoyIDAgb2JqCjw8IC9UeXBlIC9QYWdlICUgMQogICAvUGFyZW50IDEgMCBSCiAgIC9NZWRpYUJveCBbIDAgMCAxNiAxNiBdCiAgIC9Db250ZW50cyA0IDAgUgogICAvR3JvdXAgPDwKICAgICAgL1R5cGUgL0dyb3VwCiAgICAgIC9TIC9UcmFuc3BhcmVuY3kKICAgICAgL0kgdHJ1ZQogICAgICAvQ1MgL0RldmljZVJHQgogICA+PgogICAvUmVzb3VyY2VzIDMgMCBSCj4+CmVuZG9iagoxIDAgb2JqCjw8IC9UeXBlIC9QYWdlcwogICAvS2lkcyBbIDIgMCBSIF0KICAgL0NvdW50IDEKPj4KZW5kb2JqCjYgMCBvYmoKPDwgL1Byb2R1Y2VyIChjYWlybyAxLjE2LjAgKGh0dHBzOi8vY2Fpcm9ncmFwaGljcy5vcmcpKQogICAvQ3JlYXRpb25EYXRlIChEOjIwMjAwODA1MTE0NjM3KzAyJzAwKQo+PgplbmRvYmoKNyAwIG9iago8PCAvVHlwZSAvQ2F0YWxvZwogICAvUGFnZXMgMSAwIFIKPj4KZW5kb2JqCnhyZWYKMCA4CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwMDU1NyAwMDAwMCBuIAowMDAwMDAwMzQxIDAwMDAwIG4gCjAwMDAwMDAyNjkgMDAwMDAgbiAKMDAwMDAwMDAxNSAwMDAwMCBuIAowMDAwMDAwMjQ3IDAwMDAwIG4gCjAwMDAwMDA2MjIgMDAwMDAgbiAKMDAwMDAwMDczOCAwMDAwMCBuIAp0cmFpbGVyCjw8IC9TaXplIDgKICAgL1Jvb3QgNyAwIFIKICAgL0luZm8gNiAwIFIKPj4Kc3RhcnR4cmVmCjc5MAolJUVPRgo="
        return Resource(fileName: fileName, size: size, base64String: base64String)
    }

    static var allResources: [Resource] {
        return [
            .add16ptSVG,
            .add16ptRoundedSVG,
            .add16ptRoundedPDF,
        ]
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
    func createFiles() throws {
        try Resource.allResources.forEach { resource in
            try create(resource: resource)
        }
    }

    func create(resource: Resource) throws {
        try resourceFolder.createFile(named: resource.fileName, contents: resource.contents)
    }
}
