import Foundation

internal enum AssetImporterError: Error {
    case noFilesFound(extension: String, path: String)
    case multipleFilesWithName(name: String, path: String)
    case commandLineError(message: String)
    case unknown(message: String)
}

extension AssetImporterError: CustomStringConvertible {
    public var description: String {
        var description: String
        switch self {
        case let .noFilesFound(extension: fileExtension, path: path):
            description = "No files of type '\(fileExtension)' found at '\(path)'."
        case let .multipleFilesWithName(name: fileName, path: path):
            description = "Multiple files called '\(fileName)' found at '\(path)'."
        case let .commandLineError(message):
            description = message
        case let .unknown(message):
            description = message
        }
        return description
    }
}
