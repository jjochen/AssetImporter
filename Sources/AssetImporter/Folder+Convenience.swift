//
//  Folder+Convenience.swift
//  AssetImporter
//
//  Created by Jochen on 06.08.20.
//

import Files
import Foundation

internal extension Folder {
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
