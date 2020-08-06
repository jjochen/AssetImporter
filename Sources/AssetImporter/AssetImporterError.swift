//
//  AssetImporterError.swift
//  ArgumentParser
//
//  Created by Jochen on 06.08.20.
//

import Foundation

internal enum AssetImporterError: Error {
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
